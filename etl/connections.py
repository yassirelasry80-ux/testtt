"""
connections.py — Gestionnaires de connexions aux bases de données Oracle et SQL Server.
"""

import logging
from contextlib import contextmanager
import oracledb
import pyodbc
from etl.config import DbConfig

logger = logging.getLogger(__name__)

# Initialisation optionnelle du client Oracle (mode Thick si dispo, sinon Thin)
try:
    oracledb.init_oracle_client()
except Exception:
    pass


@contextmanager
def oracle_connection(cfg: DbConfig):
    """Context manager pour une connexion Oracle."""
    dsn = oracledb.makedsn(cfg.host, cfg.port, service_name=cfg.service_name)
    conn = oracledb.connect(user=cfg.user, password=cfg.password, dsn=dsn)
    try:
        yield conn
    finally:
        conn.close()


@contextmanager
def sqlserver_connection(cfg: DbConfig):
    """Context manager pour une connexion SQL Server."""
    conn_str = (
        f"DRIVER={{{cfg.driver}}};"
        f"SERVER={cfg.host},{cfg.port};"
        f"DATABASE={cfg.database};"
        f"UID={cfg.user};"
        f"PWD={cfg.password};"
        f"TrustServerCertificate=yes;"
    )
    conn = pyodbc.connect(conn_str)
    try:
        yield conn
    finally:
        conn.close()
