import time
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from db import get_connection, execute_batch, get_central_schema, get_engine
from config import TARGET_TABLE_CONSO, TARGET_TABLE_LOCAL, DB_CONFIG_1, DB_CONFIG_2
from metrics import DISPATCH_LAST_ROWS

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 5


def _execute_batch_with_retry(conn, sql, data, label, schema):
    """
    Wraps execute_batch with retry logic (MAX_RETRIES attempts).
    Returns count of rows executed, or 0 on failure.
    """
    last_error = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            count = execute_batch(conn, sql, data)
            return count
        except Exception as e:
            last_error = e
            print(f"[{schema}][{label}] Tentative {attempt}/{MAX_RETRIES} échouée: {e}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY_SECONDS * attempt)

    # all retries exhausted — critical failure
    print(f"[{schema}][{label}] Échec après {MAX_RETRIES} tentatives: {last_error}")
    if last_error is not None:
        raise last_error
    else:
        raise Exception(f"[{schema}][{label}] Échec après {MAX_RETRIES} tentatives")


def dispatch_data(config_crm):

    local_targets = []
    dispatch_success = True

    # collect all local targets
    for config in [DB_CONFIG_1, DB_CONFIG_2]:
        for schema in config['schemas']:
            local_targets.append({
                "config": config,
                "schema": schema,
                "table": f"{schema}.{TARGET_TABLE_LOCAL}"
            })

    # get max sync dates for populated tables
    max_sync_dates = []
    empty_targets = []
    populated_targets = []

    for target in local_targets:
        date, is_empty = get_max_sync_date(target)
        if is_empty is None :
            dispatch_success = False
            continue
        elif is_empty:
            empty_targets.append(target)
        else:
            populated_targets.append(target)
            if date:
                max_sync_dates.append(date)

    if empty_targets:
        print(f"Found {len(empty_targets)} empty targets for Initial Dispatch.")
        crm_schema = get_central_schema(config_crm)
        try:
            query_all = f"SELECT * FROM {crm_schema}.{TARGET_TABLE_CONSO}"
            df_all_crm = pd.read_sql(query_all, get_engine(config_crm))
            df_all_crm.columns = df_all_crm.columns.str.upper()

            if not df_all_crm.empty:
                with ThreadPoolExecutor(max_workers=len(empty_targets)) as executor:
                    futures = [executor.submit(do_initial_dispatch, target, df_all_crm) for target in empty_targets]
                    for f in futures:
                        try:
                            if f.result() is False:
                                dispatch_success = False
                        except Exception as e:
                            print(f"Initial Dispatch worker failed: {e}")
                            dispatch_success = False
        except Exception as e:
            print(f"Critical error during Initial Dispatch source reading: {e}")
            dispatch_success = False

    # dispatching differentiel for populated targets
    if populated_targets and max_sync_dates:
        min_of_max_dates = min(max_sync_dates)
        print(f"Differential Dispatching starting from overall MIN(MAX_SYNC_DATE): {min_of_max_dates}")

        crm_schema = get_central_schema(config_crm)
        try:
            query_delta = f"SELECT * FROM {crm_schema}.{TARGET_TABLE_CONSO} WHERE SYNC_DATE > :sync_date"
            df_delta_crm = pd.read_sql(query_delta, get_engine(config_crm), params={"sync_date": min_of_max_dates})
            df_delta_crm.columns = df_delta_crm.columns.str.upper()

            if not df_delta_crm.empty:
                print(f"Found {len(df_delta_crm)} modified/new rows in CRM. Broadcasting to populated targets.")
                with ThreadPoolExecutor(max_workers=len(populated_targets)) as executor:
                    futures = [executor.submit(do_differential_dispatch, target, df_delta_crm) for target in populated_targets]
                    for f in futures:
                        try:
                            if f.result() is False:
                                dispatch_success = False
                        except Exception as e:
                            print(f"Differential Dispatch worker failed: {e}")
                            dispatch_success = False
            else:
                print("No delta found for populated targets.")
        except Exception as e:
            print(f"Critical error during Differential Dispatch source reading: {e}")
            dispatch_success = False

    return dispatch_success


def get_max_sync_date(target):
    """
    Returns (max_date, is_empty boolean)
    """
    conn = None
    try:
        conn = get_connection(target['config'])
        cursor = conn.cursor()

        count_query = f"SELECT COUNT(1) FROM {target['table']}"
        cursor.execute(count_query)
        total_rows = cursor.fetchone()[0]

        if total_rows == 0:
            cursor.close()
            return None, True

        max_query = f"SELECT MAX(SYNC_DATE) FROM {target['table']}"
        cursor.execute(max_query)
        max_date = cursor.fetchone()[0]
        cursor.close()

        return max_date, False

    except Exception as e:
        print(f"[{target['schema']}] Error getting max sync date: {e}")
        return None, False
    finally:
        if conn:
            conn.close()


def do_initial_dispatch(target, df_data):
    """
    Bulk insert all data into an empty local schema.
    """
    schema = target['schema']
    print(f"[{schema}] Running Initial Dispatch ({len(df_data)} rows)...")
    df_data = df_data.where(pd.notnull(df_data), None)

    insert_sql = f"""
        INSERT INTO {target['table']} (
            ACCDAT_0, BPR_0, NOMCLT_0, NUM_0, MNTGLB_0, 
            MNTREG_0, BPCGRU_0, DES_0, MOTIF_0, BANQUE_0, 
            REP_0, EMAIL_0, DOSSIER_0, SYNC_DATE
        ) VALUES (
            :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14
        )
    """
    ordered_cols = ['ACCDAT_0', 'BPR_0', 'NOMCLT_0', 'NUM_0', 'MNTGLB_0',
                    'MNTREG_0', 'BPCGRU_0', 'DES_0', 'MOTIF_0', 'BANQUE_0',
                    'REP_0', 'EMAIL_0', 'DOSSIER_0', 'SYNC_DATE']
    data_to_insert = df_data[ordered_cols].values.tolist()

    conn = None
    try:
        conn = get_connection(target['config'])
        inserted = _execute_batch_with_retry(
            conn, insert_sql, data_to_insert,
            label="Initial Dispatch",
            schema=schema
        )
        DISPATCH_LAST_ROWS.labels(schema=schema).inc(inserted)
        print(f"[{schema}] Initial Dispatch complete: {inserted} rows inserted.")
    except Exception as e:
        print(f"[{schema}] Error during Initial Dispatch: {e}")
        return False
    finally:
        if conn:
            conn.close()
    return True


def do_differential_dispatch(target, df_delta):

    schema = target['schema']
    print(f"[{schema}] Running Differential Dispatch ({len(df_delta)} rows)...")

    conn = None
    try:
        conn = get_connection(target['config'])

        delta_dossiers = df_delta['DOSSIER_0'].unique().tolist()
        dossiers_str = "', '".join(delta_dossiers)
        
        existing_query = f"""
            SELECT NUM_0, DOSSIER_0 
            FROM {target['table']} 
            WHERE DOSSIER_0 IN ('{dossiers_str}')
        """
        # AND MNTREG_0 < MNTGLB_0 de meme ,probleme de revenir d'un disparaitre
        # pas de traitement de right only un simple updating 

        df_existing = pd.read_sql(existing_query, get_engine(target['config']))
        df_existing.columns = df_existing.columns.str.upper()
        df_existing['EXISTS'] = True

        df_merged = pd.merge(
            df_delta,
            df_existing,
            on=['NUM_0', 'DOSSIER_0'],
            how='left'
        )


        df_insert = df_merged[df_merged['EXISTS'].isna()].copy()
        df_update = df_merged[df_merged['EXISTS'] == True].copy()

        # inserts
        if not df_insert.empty:
            print(f"[{schema}] Dispatching - Operation: INSERT ({len(df_insert)} lignes)")
            df_insert = df_insert.where(pd.notnull(df_insert), None)
            insert_sql = f"""
                INSERT INTO {target['table']} (
                    ACCDAT_0, BPR_0, NOMCLT_0, NUM_0, MNTGLB_0, 
                    MNTREG_0, BPCGRU_0, DES_0, MOTIF_0, BANQUE_0, 
                    REP_0, EMAIL_0, DOSSIER_0, SYNC_DATE
                ) VALUES (
                    :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14
                )
            """
            ordered_cols = ['ACCDAT_0', 'BPR_0', 'NOMCLT_0', 'NUM_0', 'MNTGLB_0',
                            'MNTREG_0', 'BPCGRU_0', 'DES_0', 'MOTIF_0', 'BANQUE_0',
                            'REP_0', 'EMAIL_0', 'DOSSIER_0', 'SYNC_DATE']
            data_to_insert = df_insert[ordered_cols].values.tolist()
            inserted = _execute_batch_with_retry(
                conn, insert_sql, data_to_insert,
                label="Delta INSERT",
                schema=schema
            )
            DISPATCH_LAST_ROWS.labels(schema=schema).inc(inserted)

        # updates
        if not df_update.empty:
            print(f"[{schema}] Dispatching - Operation: UPDATE ({len(df_update)} lignes)")
            df_update = df_update.where(pd.notnull(df_update), None)
            update_sql = f"""
                UPDATE {target['table']}
                SET MNTREG_0 = :1, SYNC_DATE = :2
                WHERE NUM_0 = :3 AND DOSSIER_0 = :4
            """
            data_to_update = df_update[['MNTREG_0', 'SYNC_DATE', 'NUM_0', 'DOSSIER_0']].values.tolist()
            updated = _execute_batch_with_retry(
                conn, update_sql, data_to_update,
                label="Delta UPDATE",
                schema=schema
            )
            DISPATCH_LAST_ROWS.labels(schema=schema).inc(updated)

    except Exception as e:
        print(f"[{schema}] Error during Differential Dispatch: {e}")
        return False
    finally:
        if conn:
            conn.close()
    return True
