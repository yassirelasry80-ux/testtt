import time
import pandas as pd
import datetime
from db import get_connection, execute_batch, get_central_schema, get_engine
from config import TARGET_TABLE_CONSO
from metrics import CENTRALIZATION_LAST_ROWS

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 5


def _execute_batch_with_retry(conn, sql, data, label):

    last_error = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            count = execute_batch(conn, sql, data)
            return count
        except Exception as e:
            last_error = e
            print(f"[CRM][{label}] Attempt {attempt}/{MAX_RETRIES} failed: {e}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY_SECONDS * attempt)

    # all retries exhausted — critical failure
    print(f"[CRM][{label}] Failed after {MAX_RETRIES} attempts: {last_error}")
    if last_error is not None:
        raise last_error
    else:
        raise Exception(f"[CRM][{label}] Failed after {MAX_RETRIES} attempts")


def apply_centralization(config_crm, df_source):

    if df_source.empty:
        print("No source data to centralize.")
        return 0, 0, 0

    schema_crm = get_central_schema(config_crm)
    table_crm = f"{schema_crm}.{TARGET_TABLE_CONSO}"

    conn = None
    try:
        conn = get_connection(config_crm)

        #check initial load is table empty
        count_query = f"SELECT COUNT(1) FROM {table_crm}"
        cursor = conn.cursor()
        cursor.execute(count_query)
        total_crm_rows = cursor.fetchone()[0]
        cursor.close()

        sync_date = datetime.datetime.now()
        df_source['SYNC_DATE'] = sync_date

        if total_crm_rows == 0:
            print("CRM is empty. Performing Initial Load (Bulk Insert).")
            df_source = df_source.where(pd.notnull(df_source), None)

            insert_sql = f"""
                INSERT INTO {table_crm} (
                    ACCDAT_0, BPR_0, NOMCLT_0, NUM_0, MNTGLB_0, 
                    MNTREG_0, SITE_0, DES_0, MOTIF_0, BANQUE_0, 
                    REP_0, EMAIL_0, DOSSIER_0, BPCGRU_0, SYNC_DATE
                ) VALUES (
                    :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15
                )
            """

            ordered_cols = ['ACCDAT_0', 'BPR_0', 'NOMCLT_0', 'NUM_0', 'MNTGLB_0',
                            'MNTREG_0', 'SITE_0', 'DES_0', 'MOTIF_0', 'BANQUE_0',
                            'REP_0', 'EMAIL_0', 'DOSSIER_0', 'BPCGRU_0', 'SYNC_DATE']
            data_to_insert = df_source[ordered_cols].values.tolist()
            inserted = _execute_batch_with_retry(
                conn, insert_sql, data_to_insert,
                label="Initial Load"
            )
            CENTRALIZATION_LAST_ROWS.labels(operation="Chargement initial").set(inserted)
            print(f"Initial Load Complete: {inserted} rows inserted.")
            return inserted, 0, 0

        else:
            print("CRM has data. Performing Delta Comparison...")
            source_dossiers = df_source['DOSSIER_0'].unique().tolist()
            dossiers_str = "', '".join(source_dossiers)
        
            crm_query = f"""
                SELECT NUM_0, DOSSIER_0, MNTGLB_0, MNTREG_0 
                FROM {table_crm}
                WHERE DOSSIER_0 IN ('{dossiers_str}')
            """
                #AND MNTREG_0 < MNTGLB_0 , la vue retourne des impayés déja disparaitre et mentionneee comme solde pour les faires comparer avec la source au cas de revenir re apparaitre de ce solde la

            df_crm = pd.read_sql(crm_query, get_engine(config_crm))
            df_crm.columns = df_crm.columns.str.upper()


            #merge to compare
            df_merged = pd.merge(
                df_source,
                df_crm,
                on=['NUM_0', 'DOSSIER_0'],
                how='outer',
                suffixes=('_SRC', '_CRM'),
                indicator=True
            )

            #nouvelles factures insert
            df_new = df_merged[df_merged['_merge'] == 'left_only'].copy()

            #paiements partiels updates
            df_both = df_merged[df_merged['_merge'] == 'both'].copy()

            # df_partial_payments = df_both[df_both['MNTREG_0_SRC'] > df_both['MNTREG_0_CRM']].copy()
            df_partial_payments = df_both[df_both['MNTREG_0_SRC'] != df_both['MNTREG_0_CRM']].copy()  #le cas de modification de re open d'un impaye

            #soldes totaux dettes payees update
            # df_paid = df_merged[df_merged['_merge'] == 'right_only'].copy()

            df_paid = df_merged[(df_merged['_merge'] == 'right_only') & (df_merged['MNTREG_0_CRM'] != df_merged['MNTGLB_0_CRM'])].copy() #le cas on recuperer meme les elements soldes de la crm ,et eviter de faire updater tout les soldes passifs inexsitance dans la source

            inserts_count = 0
            updates_partial_count = 0
            updates_paid_count = 0

            #execute inserts
            if not df_new.empty:
                df_new = df_new.rename(columns={
                    'MNTGLB_0_SRC': 'MNTGLB_0',
                    'MNTREG_0_SRC': 'MNTREG_0'
                })
                cols_to_drop = [c for c in df_new.columns if c.endswith('_CRM') or c == '_merge']
                df_new = df_new.drop(columns=cols_to_drop)
                df_new = df_new.where(pd.notnull(df_new), None)

                insert_sql = f"""
                    INSERT INTO {table_crm} (
                        ACCDAT_0, BPR_0, NOMCLT_0, NUM_0, MNTGLB_0, 
                        MNTREG_0, SITE_0, DES_0, MOTIF_0, BANQUE_0, 
                        REP_0, EMAIL_0, DOSSIER_0, BPCGRU_0, SYNC_DATE
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15
                    )
                """
                ordered_cols = ['ACCDAT_0', 'BPR_0', 'NOMCLT_0', 'NUM_0', 'MNTGLB_0',
                                'MNTREG_0', 'SITE_0', 'DES_0', 'MOTIF_0', 'BANQUE_0',
                                'REP_0', 'EMAIL_0', 'DOSSIER_0', 'BPCGRU_0', 'SYNC_DATE']
                data_to_insert = df_new[ordered_cols].values.tolist()
                inserts_count = _execute_batch_with_retry(
                    conn, insert_sql, data_to_insert,
                    label="Delta Inserts"
                )
                CENTRALIZATION_LAST_ROWS.labels(operation="Nouvel impaye").set(inserts_count)

            # execute updates reglement partiel
            if not df_partial_payments.empty:
                print(f"[CRM] UPDATE type: Règlement Partiel ({len(df_partial_payments)} lignes)")
                df_partial_payments = df_partial_payments.where(pd.notnull(df_partial_payments), None)

                update_sql = f"""
                    UPDATE {table_crm}
                    SET MNTREG_0 = :1, 
                        SYNC_DATE = :2
                    WHERE NUM_0 = :3 AND DOSSIER_0 = :4
                """
                data_to_update = df_partial_payments[['MNTREG_0_SRC', 'SYNC_DATE', 'NUM_0', 'DOSSIER_0']].values.tolist()
                updates_partial_count = _execute_batch_with_retry(
                    conn, update_sql, data_to_update,
                    label="Règlement Partiel"
                )
                CENTRALIZATION_LAST_ROWS.labels(operation="Reglement partiel").set(updates_partial_count)

            # execute updates reglement total
            if not df_paid.empty:
                print(f"[CRM] UPDATE type: Règlement Total ({len(df_paid)} lignes)")
                df_paid = df_paid.where(pd.notnull(df_paid), None)

                update_paid_sql = f"""
                    UPDATE {table_crm}
                    SET MNTREG_0 = :1, 
                        SYNC_DATE = :2
                    WHERE NUM_0 = :3 AND DOSSIER_0 = :4
                """
                df_paid['NEW_MNTREG_0'] = df_paid['MNTGLB_0_CRM']
                df_paid['SYNC_DATE'] = sync_date

                data_to_update_paid = df_paid[['NEW_MNTREG_0', 'SYNC_DATE', 'NUM_0', 'DOSSIER_0']].values.tolist()
                updates_paid_count = _execute_batch_with_retry(
                    conn, update_paid_sql, data_to_update_paid,
                    label="Règlement Total"
                )
                CENTRALIZATION_LAST_ROWS.labels(operation="Reglement total").set(updates_paid_count)

            print(f"Delta Centralization Complete: {inserts_count} Inserts, "
                  f"{updates_partial_count} Règlements Partiels, {updates_paid_count} Règlements Totaux.")
            return inserts_count, updates_partial_count, updates_paid_count

    except Exception as e:
        print(f"Error during centralization: {e}")
        return False
    finally:
        if conn:
            conn.close()

