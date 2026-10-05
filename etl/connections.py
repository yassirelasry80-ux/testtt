"""
connections.py — Gestionnaires de connexions aux bases de données.

Oracle (X3 + BI) : oracledb (Mode Thick requis pour Oracle 11g/11c)
SQL Server (AGIRH) : pyodbc
"""

import logging
from contextlib import contextmanager
import oracledb
import pyodbc
from etl.config import DbConfig

logger = logging.getLogger(__name__)

# Initialisation du client Oracle si disponible (mode Thick / Thin)
try:
    oracledb.init_oracle_client()
except Exception:
    pass


@contextmanager
def oracle_connection(cfg: DbConfig):
    """Context manager pour une connexion Oracle."""
    dsn = oracledb.makedsn(cfg.host, cfg.port, service_name=cfg.service_name)
    conn = None
    try:
        conn = oracledb.connect(user=cfg.user, password=cfg.password, dsn=dsn)
        logger.info(f"Connexion Oracle établie : {cfg.host}/{cfg.service_name}")
        yield conn
    except oracledb.Error as e:
        logger.error(f"Erreur de connexion Oracle ({cfg.host}): {e}")
        raise
    finally:
        if conn:
            conn.close()
            logger.info(f"Connexion Oracle fermée : {cfg.host}/{cfg.service_name}")


@contextmanager
def sqlserver_connection(cfg: DbConfig):
    """
    Context manager pour une connexion SQL Server.
    
    Usage:
        with sqlserver_connection(config.agirh_sqlserver) as conn:
            df = pd.read_sql(query, conn)
    """
    conn_str = (
        f"DRIVER={{{cfg.driver}}};"
        f"SERVER={cfg.host},{cfg.port};"
        f"DATABASE={cfg.database};"
        f"UID={cfg.user};"
        f"PWD={cfg.password};"
        f"TrustServerCertificate=yes;"
    )
    conn = None
    try:
        conn = pyodbc.connect(conn_str)
        logger.info(f"Connexion SQL Server établie : {cfg.host}/{cfg.database}")
        yield conn
    except pyodbc.Error as e:
        logger.error(f"Erreur de connexion SQL Server ({cfg.host}): {e}")
        raise
    finally:
        if conn:
            conn.close()
            logger.info(f"Connexion SQL Server fermée : {cfg.host}/{cfg.database}")
