from prometheus_client import Counter, Gauge




SYNC_CYCLES_TOTAL = Counter(
    "impayes_sync_cycles_total",
    "Nombre total de cycles de synchronisation exécutés",
    ["status"]          
)

SYNC_LAST_DURATION = Gauge(
    "impayes_sync_cycle_last_duration_seconds",
    "Durée exacte du dernier cycle complet de synchronisation (secondes)"
)

SYNC_LAST_SUCCESS_TIMESTAMP = Gauge(
    "impayes_sync_last_success_timestamp",
    "Timestamp Unix du dernier cycle de synchronisation réussi"
)








EXTRACTION_LAST_ROWS = Gauge(
    "impayes_extraction_last_rows",
    "Nombre de lignes extraites avec succès lors du dernier cycle, par schéma source",
    ["schema"]
)









CENTRALIZATION_LAST_ROWS = Gauge(
    "impayes_centralization_last_rows",
    "Nombre de lignes centralisées vers le CRM lors du dernier cycle",
    ["operation"]       
)









DISPATCH_LAST_ROWS = Gauge(
    "impayes_dispatch_last_rows",
    "Nombre de lignes dispatchées vers les schémas locaux lors du dernier cycle",
    ["schema"]   
)
