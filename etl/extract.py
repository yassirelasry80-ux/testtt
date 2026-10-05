"""
extract.py — Extraction multi-sources pour l'alimentation de balance_analytique.

Sources gérées :
    1. X3 ODP : Sage X3 Prod (Oracle) — Écritures de paie ODP
    2. AGIRH : AGIRH (SQL Server) — Détail analytique paie
    3. Commercial02 : Oracle BI — Chiffre d'Affaires lignes ventes
    4. Stojou P : Sage X3 Prod (Oracle) — Coût des ventes / Stocks P
    5. Stojou D : Sage X3 Prod (Oracle) — Coût des ventes / Stocks D
    6. Commercial04 : Sage X3 Prod (Oracle) — Remises Exceptionnelles de pied
    7. Commercial06 : Sage X3 Prod (Oracle) — Avoirs Financiers AF
"""

import logging
from pathlib import Path
from datetime import datetime
from calendar import monthrange
import pandas as pd

from etl.config import AppConfig
from etl.connections import oracle_connection, sqlserver_connection

logger = logging.getLogger(__name__)

# Dossier des fichiers SQL
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
    if isinstance(start_date, datetime):
        return start_date
    return datetime.strptime(str(start_date)[:10], "%d/%m/%Y")


# ── 1. Sage X3 ODP (Paie) ──
def extract_x3(config: AppConfig) -> pd.DataFrame:
    """Extrait les écritures analytiques ODP depuis Sage X3 (Oracle)."""
    raw_query = load_sql_file("extract_x3_odp.sql")
    query = raw_query.format(entite_name=config.entite_name.lower())

    start_date = _get_start_date(config)
    today = datetime.now()
    end_date = today.replace(day=1)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date, "end_date": end_date})

    logger.info(
        f"[{config.entite_name}] X3 ODP — {len(df)} lignes extraites "
        f"(pièces : {df['NUM_0'].nunique() if not df.empty else 0})"
    )
    return df


# ── 2. AGIRH (SQL Server) ──
def extract_agirh(config: AppConfig) -> pd.DataFrame:
    """Extrait le détail de la paie analytique depuis AGIRH (SQL Server)."""
    start_date = _get_start_date(config)
    today = datetime.now()
    premier_jour_mois_courant = today.replace(day=1)
    
    dates_fin_mois = []
    current = start_date.replace(day=1)
    while current < premier_jour_mois_courant:
        last_day = monthrange(current.year, current.month)[1]
        date_str = current.replace(day=last_day).strftime("%Y%m%d")
        dates_fin_mois.append(date_str)
        if current.month == 12:
            current = current.replace(year=current.year + 1, month=1)
        else:
            current = current.replace(month=current.month + 1)

    placeholders = ",".join(["?" for _ in dates_fin_mois])
    raw_query = load_sql_file("extract_agirh.sql")
    query = raw_query.format(placeholders=placeholders)

    with sqlserver_connection(config.agirh_sqlserver) as conn:
        df = pd.read_sql(query, conn, params=dates_fin_mois)

    logger.info(
        f"[{config.entite_name}] AGIRH — {len(df)} lignes extraites "
        f"sur {len(dates_fin_mois)} mois"
    )
    df["DT_COMPTA"] = pd.to_datetime(df["DT_COMPTA"], errors="coerce")
    return df


# ── 3. Commercial02 (Chiffre d'Affaires depuis BI Oracle) ──
def extract_commercial02(config: AppConfig) -> pd.DataFrame:
    """Extrait le Chiffre d'Affaires depuis la table commercial02 sur Oracle BI."""
    query = load_sql_file("extract_commercial02.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.bi_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Commercial02 — {len(df)} lignes extraites depuis Oracle BI")
    return df


# ── 4. Stojou P (Coût des Ventes P depuis Sage X3) ──
def extract_stojou_p(config: AppConfig) -> pd.DataFrame:
    """Extrait le journal des stocks P (FIFO) depuis Sage X3 Prod."""
    query = load_sql_file("extract_stojou_p.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Stojou P — {len(df)} lignes extraites depuis Sage X3")
    return df


# ── 5. Stojou D (Coût des Ventes D depuis Sage X3) ──
def extract_stojou_d(config: AppConfig) -> pd.DataFrame:
    """Extrait le journal des stocks D (FIFO) depuis Sage X3 Prod."""
    query = load_sql_file("extract_stojou_d.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Stojou D — {len(df)} lignes extraites depuis Sage X3")
    return df


# ── 6. Commercial04 (Remises Exceptionnelles depuis Sage X3) ──
def extract_commercial04_remise(config: AppConfig) -> pd.DataFrame:
    """Extrait les remises exceptionnelles en pied de facture depuis Sage X3 Prod."""
    query = load_sql_file("extract_commercial04_remise.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Commercial04 (Remises) — {len(df)} lignes extraites depuis Sage X3")
    return df


# ── 7. Commercial06 (Avoirs Financiers AF depuis Sage X3) ──
def extract_commercial06_af(config: AppConfig) -> pd.DataFrame:
    """Extrait les avoirs financiers AF (RFA / RRR) depuis Sage X3 Prod."""
    query = load_sql_file("extract_commercial06_af.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.x3_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Commercial06 (AF) — {len(df)} lignes extraites depuis Sage X3")
    return df


# ── 8. Datamart Analytique (Autres Charges & Produits depuis Oracle BI) ──
def extract_datamart_analytique(config: AppConfig) -> pd.DataFrame:
    """Extrait les charges et produits du grand livre non encore intégrés depuis Oracle BI."""
    query = load_sql_file("extract_datamart_analytique.sql")
    start_date = _get_start_date(config)

    with oracle_connection(config.bi_oracle) as conn:
        df = pd.read_sql(query, conn, params={"start_date": start_date})

    logger.info(f"[{config.entite_name}] Datamart Analytique — {len(df)} lignes extraites depuis Oracle BI")
    return df

