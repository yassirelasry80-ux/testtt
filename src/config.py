import os

DB_CONFIG_1 = {
    "user": os.getenv("DB_USER_1", "cas"),
    "password": os.getenv("DB_PASSWORD_1", "tiger"),
    "dsn": os.getenv("DB_DSN_1", "10.1.201.214/erpv6"),
    "schemas": ["CAS"]
}

DB_CONFIG_2 = {
    "user": os.getenv("DB_USER_2", "cmgp"),
    "password": os.getenv("DB_PASSWORD_2", "tiger"),
    "dsn": os.getenv("DB_DSN_2", "193.100.100.214/erpv6"),
    "schemas": ["CMGP", "SICDA","PHILEA"]
    # schemas cmgp sicda philea
}

DB_CONFIG_CRM = {
    "user": os.getenv("DB_USER_CRM", "qlik"),
    "password": os.getenv("DB_PASSWORD_CRM", "qlik"),
    "dsn": os.getenv("DB_DSN_CRM", "193.100.100.102/erpv6"),
    "central_schema": "CRM"
}

SYNC_INTERVAL_MINUTES = 5

SOURCE_TABLE_VIEW = "XIMPAYE"
TARGET_TABLE_CONSO = "XIMPAYE_CONSO"
TARGET_TABLE_LOCAL = "XIMPAYEC"


# Prometheus metrics endpoint port
METRICS_PORT = int(os.getenv("METRICS_PORT", 8000))
