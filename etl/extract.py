"""
extract.py — Extraction multi-sources (Sage X3, AGIRH, Oracle BI).
"""

import logging
from pathlib import Path
from datetime import datetime
from calendar import monthrange
import pandas as pd

from etl.config import AppConfig
from etl.connections import oracle_connection, sqlserver_connection

logger = logging.getLogger(__name__)
SQL_DIR = Path(__file__).resolve().parent.parent / "sql"


def load_sql_file(filename: str) -> str:
    """Charge le contenu d'un fichier .sql depuis le dossier sql/."""
    file_path = SQL_DIR / filename
    if not file_path.exists():
        raise FileNotFoundError(f"Fichier SQL introuvable : {file_path}")
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read()


def _get_start_date(config: AppConfig) -> datetime:
    """Convertit config.start_date en datetime."""
    start_date = config.start_date
    return start_date if isinstance(start_date, datetime) else datetime.strptime(str(start_date)[:10], "%d/%m/%Y")


def _extract_oracle(db_cfg, sql_file: str, start_date, entite: str, label: str) -> pd.DataFrame:
    """Helper factorisé pour les extractions Oracle simples avec paramètre start_date."""
    with oracle_connection(db_cfg) as conn:
        df = pd.read_sql(load_sql_file(sql_file), conn, params={"start_date": start_date})
    logger.info(f"[{entite}] {label} — {len(df)} lignes extraites")
    return df


# ── 1. Sage X3 ODP (Paie) ──
def extract_x3(config: AppConfig) -> pd.DataFrame:
    """Extrait les écritures analytiques ODP depuis Sage X3 (Oracle)."""
    query = load_sql_file("extract_x3_odp.sql").format(entite_name=config.entite_name.lower())
    start_date = _get_start_date(config)
    end_date = datetime.now().replace(day=1)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date, "end_date": end_date})

    nb_pieces = df["NUM_0"].nunique() if not df.empty else 0
    logger.info(f"[{config.entite_name}] X3 ODP — {len(df)} lignes extraites (pièces : {nb_pieces})")
    return df


# ── 2. AGIRH (SQL Server) ──
def extract_agirh(config: AppConfig) -> pd.DataFrame:
    """Extrait le détail de la paie analytique depuis AGIRH (SQL Server)."""
    start_date = _get_start_date(config)
    today = datetime.now()
    premier_jour_mois = today.replace(day=1)

    dates_fin_mois = []
    curr = start_date.replace(day=1)
    while curr < premier_jour_mois:
        last_d = monthrange(curr.year, curr.month)[1]
        dates_fin_mois.append(curr.replace(day=last_d).strftime("%Y%m%d"))
        curr = curr.replace(year=curr.year + 1, month=1) if curr.month == 12 else curr.replace(month=curr.month + 1)

    placeholders = ",".join(["?" for _ in dates_fin_mois])
    query = load_sql_file("extract_agirh.sql").format(placeholders=placeholders)

    with sqlserver_connection(config.agirh_sqlserver) as conn:
        df = pd.read_sql(query, conn, params=dates_fin_mois)

    logger.info(f"[{config.entite_name}] AGIRH — {len(df)} lignes extraites sur {len(dates_fin_mois)} mois")
    df["DT_COMPTA"] = pd.to_datetime(df["DT_COMPTA"], errors="coerce")
    return df


# ── 3 à 8. Extractions Oracle Directes ──
def extract_commercial02(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.bi_oracle, "extract_commercial02.sql", _get_start_date(config), config.entite_name, "Commercial02")


def extract_stojou_p(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.x3_oracle, "extract_stojou_p.sql", _get_start_date(config), config.entite_name, "Stojou P")


def extract_stojou_d(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.x3_oracle, "extract_stojou_d.sql", _get_start_date(config), config.entite_name, "Stojou D")


def extract_commercial04_remise(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.x3_oracle, "extract_commercial04_remise.sql", _get_start_date(config), config.entite_name, "Commercial04 (Remises)")


def extract_commercial06_af(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.x3_oracle, "extract_commercial06_af.sql", _get_start_date(config), config.entite_name, "Commercial06 (AF)")


def extract_datamart_analytique(config: AppConfig) -> pd.DataFrame:
    return _extract_oracle(config.bi_oracle, "extract_datamart_analytique.sql", _get_start_date(config), config.entite_name, "Datamart Analytique")


# ── 9. Moovapps (Oracle) ──
def extract_moovapps(config: AppConfig) -> pd.DataFrame:
    """Extrait les données depuis la base Oracle Moovapps."""
    if not config.moovapps_oracle.host or not config.moovapps_oracle.user:
        logger.warning(
            f"[{config.entite_name}] Moovapps Oracle non configuré (host ou user manquant dans .env). Extraction ignorée."
        )
        return pd.DataFrame()
    return _extract_oracle(
        config.moovapps_oracle,
        "extract_moovapps.sql",
        _get_start_date(config),
        config.entite_name,
        "Moovapps",
    )

