"""
load.py — Chargement dans la table cible bi_{entite_name}.balance_analytique (Oracle BI).

Modes de chargement :
    - delete_insert (défaut, sécurisé) : Purge ciblée par SOURCE et DATE_COMPTABLE >= start_date
    - truncate (optionnel) : TRUNCATE complet de la table
"""

import logging
import math
from datetime import datetime, date
import pandas as pd
import oracledb
from etl.config import AppConfig
from etl.connections import oracle_connection

logger = logging.getLogger(__name__)

# Ordre strict des colonnes pour l'INSERT Oracle
COLUMNS_ORDER = [
    "NUM_PIECE", "COMPTE", "SENS", "AXE_CENTRE", "AXE_ENTITE",
    "AXE_BLINE", "AXE_SITE", "MONTANT", "TIERS_CODE", "ARTICLE_CODE",
    "DATE_COMPTABLE", "SOURCE", "TYPE_LIGNE",
]

BATCH_SIZE = 1000


def _clean_str(val):
    """Convertit en str propre ou None si vide/null/NaN."""
    if val is None:
        return None
    if isinstance(val, float) and (math.isnan(val) or math.isinf(val)):
        return None
    s = str(val).strip()
    if s.lower() in ("", "none", "nan", "nat", "<na>"):
        return None
    return s


def _clean_int(val, default: int = 1) -> int:
    """Convertit en int Python natif."""
    if val is None:
        return default
    try:
        if isinstance(val, float) and (math.isnan(val) or math.isinf(val)):
            return default
        return int(float(val))
    except (ValueError, TypeError):
        return default


def _clean_float(val, default: float = 0.0) -> float:
    """Convertit en float Python natif positif (arrondi à 2 décimales)."""
    if val is None:
        return default
    try:
        f = float(val)
        if math.isnan(f) or math.isinf(f):
            return default
        return round(abs(f), 2)
    except (ValueError, TypeError):
        return default


def _clean_date(val):
    """Convertit en datetime.datetime Python natif."""
    if val is None:
        return None
    if isinstance(val, pd.Timestamp):
        if pd.isna(val):
            return None
        return val.to_pydatetime()
    if isinstance(val, datetime):
        return val
    if isinstance(val, date):
        return datetime(val.year, val.month, val.day)
    try:
        dt = pd.to_datetime(val)
        if pd.isna(dt):
            return None
        return dt.to_pydatetime()
    except Exception:
        return None


def sanitize_dataframe_for_oracle(df: pd.DataFrame) -> list:
    """
    Transforme un DataFrame en liste de listes avec des types Python natifs purs.
    Garantit l'absence de np.nan, float('nan'), pd.Timestamp ou str invalides.
    """
    rows = []
    # Index des colonnes dans COLUMNS_ORDER
    # 0: NUM_PIECE (str)
    # 1: COMPTE (str)
    # 2: SENS (int)
    # 3: AXE_CENTRE (str)
    # 4: AXE_ENTITE (str)
    # 5: AXE_BLINE (str)
    # 6: AXE_SITE (str)
    # 7: MONTANT (float)
    # 8: TIERS_CODE (str)
    # 9: ARTICLE_CODE (str)
    # 10: DATE_COMPTABLE (datetime)
    # 11: SOURCE (str)
    # 12: TYPE_LIGNE (str)

    # Récupération sous forme de tuples pour une performance maximale
    raw_tuples = df[COLUMNS_ORDER].itertuples(index=False, name=None)

    for r in raw_tuples:
        clean_row = [
            _clean_str(r[0]),                                  # NUM_PIECE
            _clean_str(r[1]),                                  # COMPTE
            _clean_int(r[2], default=1),                       # SENS
            _clean_str(r[3]),                                  # AXE_CENTRE
            _clean_str(r[4]),                                  # AXE_ENTITE
            _clean_str(r[5]),                                  # AXE_BLINE
            _clean_str(r[6]),                                  # AXE_SITE
            _clean_float(r[7]),                                # MONTANT
            _clean_str(r[8]),                                  # TIERS_CODE
            _clean_str(r[9]),                                  # ARTICLE_CODE
            _clean_date(r[10]),                                # DATE_COMPTABLE
            _clean_str(r[11]) or "INCONNU",                    # SOURCE
            _clean_str(r[12]) or "DETAIL",                     # TYPE_LIGNE
        ]
        rows.append(clean_row)

    return rows


def load(
    df: pd.DataFrame,
    config: AppConfig,
    source_name: str = None,
    mode: str = "delete_insert",
) -> int:
    """
    Charge le DataFrame dans bi_{entite}.balance_analytique.
    
    Args:
        df: DataFrame standardisé prêt à insérer.
        config: Configuration de l'entité.
        source_name: Nom de la source (ex: 'commercial02', 'AGIRH', 'stojou_cmgp_global_p').
        mode: 'delete_insert' (recommandé) ou 'truncate'.
    
    Returns:
        Nombre de lignes insérées.
    """
    if df is None or df.empty:
        logger.warning(f"[{config.entite_name}] Aucune ligne à charger pour la source '{source_name}'.")
        return 0

    schema = f"bi_{config.entite_name.lower()}"
    table = f"{schema}.balance_analytique"

    start_date = config.start_date
    if isinstance(start_date, str):
        start_date = datetime.strptime(start_date[:10], "%d/%m/%Y")

    # Assainissement strict des types Python natifs (résout les erreurs DPY-3013)
    rows = sanitize_dataframe_for_oracle(df)

    with oracle_connection(config.bi_oracle) as conn:
        cursor = conn.cursor()

        # ── 1. PURGE PRÉALABLE ──
        if mode == "truncate":
            logger.info(f"[{config.entite_name}] TRUNCATE TABLE {table}")
            cursor.execute(f"TRUNCATE TABLE {table}")

        elif mode == "delete_insert":
            sources_to_delete = [source_name] if source_name else list({r[11] for r in rows if r[11]})
            for src in sources_to_delete:
                delete_sql = f"DELETE FROM {table} WHERE SOURCE = :1 AND DATE_COMPTABLE >= :2"
                cursor.execute(delete_sql, [src, start_date])
                logger.info(
                    f"[{config.entite_name}] Purge ciblée : DELETE FROM {table} "
                    f"WHERE SOURCE = '{src}' AND DATE_COMPTABLE >= {start_date.strftime('%d/%m/%Y')} "
                    f"({cursor.rowcount} lignes supprimées)"
                )

        # ── 2. INSERTION PAR BATCH ──
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

        # Définition explicite des 13 types de bind pour l'INSERT (fix DPY-3013)
        cursor.setinputsizes(
            oracledb.DB_TYPE_VARCHAR,  # 1. NUM_PIECE
            oracledb.DB_TYPE_VARCHAR,  # 2. COMPTE
            oracledb.DB_TYPE_NUMBER,   # 3. SENS
            oracledb.DB_TYPE_VARCHAR,  # 4. AXE_CENTRE
            oracledb.DB_TYPE_VARCHAR,  # 5. AXE_ENTITE
            oracledb.DB_TYPE_VARCHAR,  # 6. AXE_BLINE
            oracledb.DB_TYPE_VARCHAR,  # 7. AXE_SITE
            oracledb.DB_TYPE_NUMBER,   # 8. MONTANT
            oracledb.DB_TYPE_VARCHAR,  # 9. TIERS_CODE
            oracledb.DB_TYPE_VARCHAR,  # 10. ARTICLE_CODE
            oracledb.DB_TYPE_DATE,     # 11. DATE_COMPTABLE
            oracledb.DB_TYPE_VARCHAR,  # 12. SOURCE
            oracledb.DB_TYPE_VARCHAR,  # 13. TYPE_LIGNE
        )

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

