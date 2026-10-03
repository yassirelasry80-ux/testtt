import time
from concurrent.futures import TimeoutError as FutureTimeoutError
import threading
import schedule
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from wsgiref.simple_server import WSGIServer, WSGIRequestHandler
from prometheus_client import make_wsgi_app

from config import DB_CONFIG_1, DB_CONFIG_2, DB_CONFIG_CRM, SYNC_INTERVAL_MINUTES, METRICS_PORT
from extractor import extract_from_schema
from centralizer import apply_centralization
from integrity import verify_integrity
from dispatcher import dispatch_data
from metrics import (
    SYNC_CYCLES_TOTAL,
    SYNC_LAST_DURATION,
    SYNC_LAST_SUCCESS_TIMESTAMP,
    EXTRACTION_LAST_ROWS,
    CENTRALIZATION_LAST_ROWS,
    DISPATCH_LAST_ROWS
)


EXTRACTION_TIMEOUT = 90


def _start_metrics_server(port: int) -> None:
    """
    Starts the Prometheus /metrics HTTP endpoint in a daemon thread.
    Uses allow_reuse_address=True (SO_REUSEADDR) so the OS immediately
    releases the port on service stop/restart, preventing errno 98.
    """
    class _ReuseAddrWSGIServer(WSGIServer):
        allow_reuse_address = True  

    try:
        app = make_wsgi_app()
        httpd = _ReuseAddrWSGIServer(("", port), WSGIRequestHandler)
        httpd.set_app(app)
        t = threading.Thread(target=httpd.serve_forever, daemon=True)
        t.start()
        print(f"[METRICS] Server started on http://0.0.0.0:{port}/metrics")
    except OSError as e:
        print(f"[METRICS] Could not start metrics server on port {port}: {e}")


def run_sync_cycle():
    cycle_start = time.time()

    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Démarrage Synchronisation")

    for source_schema in sum([DB_CONFIG_1['schemas'], DB_CONFIG_2['schemas']], []):
        EXTRACTION_LAST_ROWS.labels(schema=source_schema).set(0)
        DISPATCH_LAST_ROWS.labels(schema=source_schema).set(0)

    for op in ["Chargement initial", "Nouvel impaye", "Reglement partiel", "Reglement total"]:
        CENTRALIZATION_LAST_ROWS.labels(operation=op).set(0)

    success = True

    try:
        # collect all sources
        sources = []
        for config in [DB_CONFIG_1, DB_CONFIG_2]:
            for schema in config['schemas']:
                sources.append((config, schema))

        # parallel extraction
        print("Parallel Extraction")
        extracted_data = {}
        with ThreadPoolExecutor(max_workers=len(sources)) as executor:
            futures = {executor.submit(extract_from_schema, config, schema): schema for config, schema in sources}
            for future in futures:
                schema = futures[future]
                try:
                    df = future.result(timeout=EXTRACTION_TIMEOUT)
                    extracted_data[schema] = df
                except FutureTimeoutError:
                    future.cancel()
                    print(f"[{schema}] Extraction TIMEOUT après {EXTRACTION_TIMEOUT}s — serveur inaccessible réseau.")
                    success = False
                    extracted_data[schema] = pd.DataFrame()
                except Exception as e:
                    print(f"[{schema}] Extraction failed: {e}")
                    success = False
                    extracted_data[schema] = pd.DataFrame()

        # combine extracted data
        all_dfs = [df for df in extracted_data.values() if not df.empty]
        if not all_dfs:
            if not success:
                print("Aucune donnée à extraire mais des erreurs sont survenues. Cycle terminé en échec.")
                SYNC_CYCLES_TOTAL.labels(status="failure").inc()
            else:
                print("Aucune donnée à extraire. Cycle ignoré avec succès.")
                SYNC_CYCLES_TOTAL.labels(status="success").inc()
            return

        df_combined_sources = pd.concat(all_dfs, ignore_index=True)
        print(f"Total rows extracted across all sources: {len(df_combined_sources)}")

        # centralization
        print("\nCentralization")
        if apply_centralization(DB_CONFIG_CRM, df_combined_sources) is False:
            success = False

        # integrity verification
        print("\nIntegrity Verification")
        for schema, df in extracted_data.items():
            if verify_integrity(DB_CONFIG_CRM, df, schema) is False:
                success = False

        # dispatching
        print("\nDispatching")
        if dispatch_data(DB_CONFIG_CRM) is False:
            success = False

        if success:
            SYNC_LAST_SUCCESS_TIMESTAMP.set(cycle_start)
            SYNC_CYCLES_TOTAL.labels(status="success").inc()
        else:
            print(f"Cycle de synchronisation complété avec des erreurs partielles.")
            SYNC_CYCLES_TOTAL.labels(status="failure").inc()

    except Exception as e:
        print(f"Échec critique du cycle de synchronisation : {e}")
        SYNC_CYCLES_TOTAL.labels(status="failure").inc()

    finally:
        duration = time.time() - cycle_start
        SYNC_LAST_DURATION.set(duration)
        status_str = "COMPLETED" if success else "FAILED"
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Fin Synchronisation — {status_str} en {duration:.2f} secondes")
        
        def reset_duration():
            time.sleep(40)
            SYNC_LAST_DURATION.set(0)
        threading.Thread(target=reset_duration, daemon=True).start()


def run_sync_if_working_hours():
    from datetime import datetime
    now = datetime.now()
    weekday = now.weekday()  
    hour = now.hour
    minute = now.minute

    should_run = False

    if 0 <= weekday <= 4:
        if 8 <= hour < 18 or (hour == 18 and minute <= 30):
            should_run = True
    elif weekday == 5:
        if 8 <= hour < 12 or (hour == 12 and minute == 0):
            should_run = True

    if should_run:
        run_sync_cycle()
    else:
        print(f"[{now.strftime('%Y-%m-%d %H:%M:%S')}] Hors plage horaire de travail. Synchronisation ignorée.")


if __name__ == "__main__":
    _start_metrics_server(METRICS_PORT)


    run_sync_if_working_hours()

    print(f"Scheduling sync every {SYNC_INTERVAL_MINUTES} minutes (working hours only)...")
    schedule.every(SYNC_INTERVAL_MINUTES).minutes.do(run_sync_if_working_hours)

    while True:
        schedule.run_pending()
        time.sleep(1)
