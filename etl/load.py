"""
load.py — Chargement ultra-rapide et vectorisé dans bi_{entite}.balance_analytique.

Modes de chargement :
    - delete_insert (défaut, sécurisé) : Purge ciblée par SOURCE et DATE_COMPTABLE >= start_date
    - truncate (optionnel) : TRUNCATE complet de la table
"""

import logging
from datetime import datetime
import pandas as pd
from etl.config import AppConfig
from etl.connections import oracle_connection

logger = logging.getLogger(__name__)

# Ordre strict des colonnes pour l'INSERT Oracle
COLUMNS_ORDER = [
    "NUM_PIECE", "COMPTE", "SENS", "AXE_CENTRE", "AXE_ENTITE",
    "AXE_BLINE", "AXE_SITE", "MONTANT", "TIERS_CODE", "ARTICLE_CODE",
    "DATE_COMPTABLE", "SOURCE", "TYPE_LIGNE",
]

BATCH_SIZE = 5000


def load(
    df: pd.DataFrame,
    config: AppConfig,
    source_name: str = None,
    mode: str = "delete_insert",
) -> int:
    """
    Charge le DataFrame dans bi_{entite}.balance_analytique de façon vectorisée.
    """
    if df is None or df.empty:
        logger.warning(f"[{config.entite_name}] Aucune ligne à charger pour la source '{source_name}'.")
        return 0

    schema = f"bi_{config.entite_name.lower()}"
    table = f"{schema}.balance_analytique"

    start_date = config.start_date
    if isinstance(start_date, str):
        start_date = datetime.strptime(start_date[:10], "%d/%m/%Y").date()
    elif isinstance(start_date, datetime):
        start_date = start_date.date()

    end_date = config.end_date
    if end_date:
        if isinstance(end_date, str):
            end_date = datetime.strptime(end_date[:10], "%d/%m/%Y").date()
        elif isinstance(end_date, datetime):
            end_date = end_date.date()

    # ── 1. Transformation vectorisée instantanée (0.2s pour 75k lignes) ──
    df_load = df[COLUMNS_ORDER].copy()
    df_load["COMPTE"] = df_load["COMPTE"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_load["DATE_COMPTABLE"] = pd.to_datetime(df_load["DATE_COMPTABLE"]).dt.date
    df_load = df_load.astype(object).where(pd.notnull(df_load), None)
    rows = df_load.values.tolist()

    with oracle_connection(config.bi_oracle) as conn:
        cursor = conn.cursor()

        # ── 2. Purge ciblée ou Truncate ──
        if mode == "truncate":
            logger.info(f"[{config.entite_name}] TRUNCATE TABLE {table}")
            cursor.execute(f"TRUNCATE TABLE {table}")

        elif mode == "delete_insert":
            sources_to_delete = [source_name] if source_name else list({r[11] for r in rows if r[11]})
            for src in sources_to_delete:
                if end_date:
                    delete_sql = f"DELETE FROM {table} WHERE SOURCE = :1 AND DATE_COMPTABLE >= :2 AND DATE_COMPTABLE <= :3"
                    cursor.execute(delete_sql, [src, start_date, end_date])
                    logger.info(
                        f"[{config.entite_name}] Purge ciblée : DELETE FROM {table} "
                        f"WHERE SOURCE = '{src}' AND DATE_COMPTABLE >= {start_date.strftime('%d/%m/%Y')} "
                        f"AND DATE_COMPTABLE <= {end_date.strftime('%d/%m/%Y')} "
                        f"({cursor.rowcount} lignes supprimées)"
                    )
                else:
                    delete_sql = f"DELETE FROM {table} WHERE SOURCE = :1 AND DATE_COMPTABLE >= :2"
                    cursor.execute(delete_sql, [src, start_date])
                    logger.info(
                        f"[{config.entite_name}] Purge ciblée : DELETE FROM {table} "
                        f"WHERE SOURCE = '{src}' AND DATE_COMPTABLE >= {start_date.strftime('%d/%m/%Y')} "
                        f"({cursor.rowcount} lignes supprimées)"
                    )

        # ── 3. Insertion en batch haute performance ──
        insert_sql = f"""
            INSERT INTO {table} (
                NUM_PIECE, COMPTE, SENS, AXE_CENTRE, AXE_ENTITE,
                AXE_BLINE, AXE_SITE, MONTANT, TIERS_CODE, ARTICLE_CODE,
                DATE_COMPTABLE, SOURCE, TYPE_LIGNE, DATE_INSERTION
            ) VALUES (
                :1, :2, :3, :4, :5,
                :6, :7, :8, :9, :10,
                :11, :12, :13, SYSTIMESTAMP
            )
        """

        total_inserted = 0
        for i in range(0, len(rows), BATCH_SIZE):
            batch = rows[i : i + BATCH_SIZE]
            cursor.executemany(insert_sql, batch)
            total_inserted += len(batch)

        conn.commit()
        logger.info(
            f"[{config.entite_name}] [SUCCÈS] {total_inserted} lignes insérées dans {table} "
            f"(Source : {source_name or 'MULTI'})"
        )
        cursor.close()

    return total_inserted
