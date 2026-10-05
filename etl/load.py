"""
load.py — Chargement dans la table cible bi_{entite_name}.balance_analytique (Oracle BI).

Modes de chargement :
    - delete_insert (défaut, sécurisé) : Purge ciblée par SOURCE et DATE_COMPTABLE >= start_date
    - truncate (optionnel) : TRUNCATE complet de la table
"""

import logging
import math
from datetime import datetime
import pandas as pd
import numpy as np
from etl.config import AppConfig
from etl.connections import oracle_connection

logger = logging.getLogger(__name__)

# Ordre strict des colonnes pour l'INSERT Oracle
COLUMNS_ORDER = [
    "NUM_PIECE", "COMPTE", "SENS", "AXE_CENTRE", "AXE_ENTITE",
    "AXE_BLINE", "AXE_SITE", "MONTANT", "TIERS_CODE", "ARTICLE_CODE",
    "DATE_COMPTABLE", "SOURCE", "TYPE_LIGNE",
]

# Mapping colonne → type Oracle attendu (pour le cast Python)
# 'str' = VARCHAR2, 'int' = NUMBER entier, 'float' = NUMBER décimal, 'date' = DATE
COLUMN_TYPES = {
    "NUM_PIECE":      "str",
    "COMPTE":         "str",
    "SENS":           "int",
    "AXE_CENTRE":     "str",
    "AXE_ENTITE":     "str",
    "AXE_BLINE":      "str",
    "AXE_SITE":       "str",
    "MONTANT":        "float",
    "TIERS_CODE":     "str",
    "ARTICLE_CODE":   "str",
    "DATE_COMPTABLE": "date",
    "SOURCE":         "str",
    "TYPE_LIGNE":     "str",
}

BATCH_SIZE = 1000


def _is_null(val) -> bool:
    """Vérifie si une valeur est considérée comme NULL pour Oracle."""
    if val is None:
        return True
    if isinstance(val, float) and (math.isnan(val) or math.isinf(val)):
        return True
    if isinstance(val, str) and val.strip().lower() in ("", "none", "nan", "nat"):
        return True
    try:
        if pd.isna(val):
            return True
    except (ValueError, TypeError):
        pass
    return False


def _cast_value(val, target_type: str):
    """
    Convertit une valeur Python vers le type natif attendu par Oracle.
    Retourne None pour les valeurs NULL.
    """
    if _is_null(val):
        return None

    if target_type == "str":
        return str(val).strip()

    elif target_type == "int":
        try:
            return int(float(val))
        except (ValueError, TypeError):
            return None

    elif target_type == "float":
        try:
            return float(val)
        except (ValueError, TypeError):
            return None

    elif target_type == "date":
        if isinstance(val, datetime):
            return val
        if isinstance(val, pd.Timestamp):
            return val.to_pydatetime()
        try:
            return pd.to_datetime(val).to_pydatetime()
        except Exception:
            return None

    return val


def _sanitize_rows(df: pd.DataFrame) -> list:
    """
    Convertit le DataFrame en liste de listes avec les types Python natifs
    correspondant aux colonnes Oracle cibles. Élimine les NaN/NaT parasites.
    """
    col_types = [COLUMN_TYPES[col] for col in COLUMNS_ORDER]
    rows = []
    for _, row in df.iterrows():
        sanitized = []
        for i, col in enumerate(COLUMNS_ORDER):
            sanitized.append(_cast_value(row[col], col_types[i]))
        rows.append(sanitized)
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

    # Préparation des données
    df_load = df[COLUMNS_ORDER].copy()
    df_load["COMPTE"] = df_load["COMPTE"].astype(str).str.strip()
    df_load["DATE_COMPTABLE"] = pd.to_datetime(df_load["DATE_COMPTABLE"])

    start_date = config.start_date
    if isinstance(start_date, str):
        start_date = datetime.strptime(start_date[:10], "%d/%m/%Y")

    # Conversion en types Python natifs (fix DPY-3013)
    rows = _sanitize_rows(df_load)

    with oracle_connection(config.bi_oracle) as conn:
        cursor = conn.cursor()

        # ── 1. PURGE PRÉALABLE ──
        if mode == "truncate":
            logger.info(f"[{config.entite_name}] TRUNCATE TABLE {table}")
            cursor.execute(f"TRUNCATE TABLE {table}")

        elif mode == "delete_insert":
            # Si source_name n'est pas spécifié, purger pour toutes les sources du DataFrame
            sources_to_delete = [source_name] if source_name else df_load["SOURCE"].dropna().unique().tolist()
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

