"""
config.py — Chargement direct et compact de la configuration multi-entités (.env).
"""

import os
import logging
from pathlib import Path
from dataclasses import dataclass
from typing import List, Optional
from dotenv import load_dotenv

logger = logging.getLogger(__name__)


@dataclass
class DbConfig:
    """Configuration d'une connexion base de données."""
    host: str
    port: int
    user: str
    password: str
    service_name: str = ""   # Oracle
    database: str = ""       # SQL Server
    driver: str = ""         # SQL Server ODBC driver


@dataclass
class AppConfig:
    """Configuration globale de l'application pour une entité donnée."""
    entite_name: str
    start_date: str
    x3_oracle: DbConfig
    agirh_sqlserver: DbConfig
    bi_oracle: DbConfig
    moovapps_oracle: DbConfig
    end_date: Optional[str] = None


def get_entities_list(env_path: str = ".env") -> List[str]:
    """Récupère la liste des entités à traiter (ex: CMGP,SICDA,PHILEA)."""
    p = Path(env_path)
    load_dotenv(p if p.exists() else None, override=True)
    raw = os.getenv("ENTITES") or os.getenv("ENTITE_NAME") or "CMGP"
    return [e.strip().upper() for e in raw.split(",") if e.strip()]


def _oracle_db(prefix: str, role: str) -> DbConfig:
    """Helper compact pour instancier la configuration Oracle (Source X3 ou Target BI)."""
    p = f"{prefix}_DB_{role}"
    f = f"{'X3' if role == 'SOURCE' else 'BI'}_ORACLE"
    return DbConfig(
        host=os.getenv(f"{p}_HOST", os.getenv(f"{f}_HOST", "")),
        port=int(os.getenv(f"{p}_PORT", os.getenv(f"{f}_PORT", "1521"))),
        service_name=os.getenv(f"{p}_SERVICE", os.getenv(f"{f}_SERVICE", "ERPV6")),
        user=os.getenv(f"{p}_USER", os.getenv(f"{f}_USER", "")),
        password=os.getenv(f"{p}_PASSWORD", os.getenv(f"{f}_PASSWORD", "")),
    )


def _oracle_moovapps_db(prefix: str) -> DbConfig:
    """Helper pour instancier la configuration Oracle Moovapps (par entité ou fallback générique)."""
    p = f"{prefix}_DB_MOOVAPPS"
    p_alt = f"{prefix}_MOOVAPPS_DB"
    f = "MOOVAPPS_DB"
    return DbConfig(
        host=os.getenv(f"{p}_HOST") or os.getenv(f"{p_alt}_HOST") or os.getenv(f"{f}_HOST", ""),
        port=int(os.getenv(f"{p}_PORT") or os.getenv(f"{p_alt}_PORT") or os.getenv(f"{f}_PORT", "1521")),
        service_name=os.getenv(f"{p}_SERVICE") or os.getenv(f"{p_alt}_SERVICE") or os.getenv(f"{f}_SERVICE", "ERPV6"),
        user=os.getenv(f"{p}_USER") or os.getenv(f"{p_alt}_USER") or os.getenv(f"{f}_USER", ""),
        password=os.getenv(f"{p}_PASSWORD") or os.getenv(f"{p_alt}_PASSWORD") or os.getenv(f"{f}_PASSWORD", ""),
    )


def _sqlserver_agirh_db(prefix: str) -> DbConfig:
    """Helper pour instancier la configuration SQL Server AGIRH (par entité ou fallback, ex: CMGP_DB_AGIRH_*)."""
    p = f"{prefix}_DB_AGIRH"
    p_alt = f"{prefix}_AGIRH_SQLSERVER"
    f = "AGIRH_SQLSERVER"
    return DbConfig(
        host=os.getenv(f"{p}_HOST") or os.getenv(f"{p_alt}_HOST") or os.getenv(f"{f}_HOST", ""),
        port=int(os.getenv(f"{p}_PORT") or os.getenv(f"{p_alt}_PORT") or os.getenv(f"{f}_PORT", "1433")),
        database=os.getenv(f"{p}_DB") or os.getenv(f"{p_alt}_DB") or os.getenv(f"{f}_DB", ""),
        user=os.getenv(f"{p}_USER") or os.getenv(f"{p_alt}_USER") or os.getenv(f"{f}_USER", ""),
        password=os.getenv(f"{p}_PASSWORD") or os.getenv(f"{p_alt}_PASSWORD") or os.getenv(f"{f}_PASSWORD", ""),
        driver=os.getenv(f"{p}_DRIVER") or os.getenv(f"{p_alt}_DRIVER") or os.getenv(f"{f}_DRIVER", "ODBC Driver 17 for SQL Server"),
    )


def load_config(env_path: str = ".env", entite_name: str = None) -> AppConfig:
    """Charge la configuration pour l'entité choisie depuis le fichier .env."""
    p = Path(env_path)
    load_dotenv(p if p.exists() else None, override=True)

    if not entite_name:
        entities = get_entities_list(env_path)
        entite_name = entities[0] if entities else "CMGP"

    entite_name = entite_name.strip()
    prefix = entite_name.upper()

    return AppConfig(
        entite_name=entite_name,
        start_date=os.getenv("START_DATE", "01/01/2026").strip(),
        x3_oracle=_oracle_db(prefix, "SOURCE"),
        bi_oracle=_oracle_db(prefix, "TARGET"),
        moovapps_oracle=_oracle_moovapps_db(prefix),
        agirh_sqlserver=_sqlserver_agirh_db(prefix),
        end_date=os.getenv("END_DATE", "").strip() or None,
    )

