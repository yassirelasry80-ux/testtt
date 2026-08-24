import os
import glob
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
from dotenv import load_dotenv
import time

from db_utils import get_connection, stream_data, verify_table_data

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(threadName)s - %(message)s')
logger = logging.getLogger(__name__)

def is_complex_script(sql_file_path):
    try:
        with open(sql_file_path, "r", encoding="utf-8") as f:
            content = f.read().upper()
        return "CREATE TABLE" in content or "CREATE GLOBAL" in content or 'BEGIN' in content
    except Exception:
        return False

def process_single_sql_file(sql_file_path, base_target_name, source_creds, target_creds, prefix=""):
    p_tag = f"[{prefix}]" if prefix else ""
    logger.info(f"{p_tag} Démarrage traitement pour le fichier: {os.path.basename(sql_file_path)}")
    
    target_table_name = (base_target_name).upper()[:30]
    
    try:
        with open(sql_file_path, "r", encoding="utf-8") as f:
            select_query = f.read().strip()
            
        if not select_query:
            logger.warning(f"{p_tag} Le fichier {sql_file_path} est vide. Ignoré.")
            return True

        blocks = []
        current_block = []
        for line in select_query.split('\n'):
            if line.strip() == '/':
                if current_block:
                    blocks.append('\n'.join(current_block).strip())
                    current_block = []
            else:
                current_block.append(line)
        
        if current_block:
            joined = '\n'.join(current_block).strip()
            if joined:
                blocks.append(joined)

        source_conn = get_connection(*source_creds)
        target_conn = get_connection(*target_creds)
        
        try:
            source_cursor = source_conn.cursor()
            try:
                for idx, block in enumerate(blocks):
                    upper_block = block.upper()
                    
                    if not (upper_block.startswith("BEGIN") or upper_block.startswith("DECLARE")):
                        if block.endswith(';'):
                            block = block[:-1]
                            upper_block = block.upper()
                    
                    if upper_block.startswith("SELECT") or upper_block.startswith("WITH"):
                        logger.info(f"{p_tag}[{base_target_name}] Extraction des donnees (SELECT/WITH)...")
                        stream_data(source_conn, target_conn, block, target_table_name, prefix=prefix)
                    elif upper_block.startswith("COMMIT"):
                        source_conn.commit()
                        logger.info(f"{p_tag}[{base_target_name}] COMMIT execute en source.")
                    else:
                        logger.info(f"{p_tag}[{base_target_name}] Execution script source (bloc {idx+1}/{len(blocks)})...")
                        source_cursor.execute(block)
            except Exception as inner_e:
                logger.error(f"{p_tag} Erreur durant l'execution des blocs pour {base_target_name}: {inner_e}")
                for cleanup_block in blocks:
                    if cleanup_block.strip().upper().startswith("DROP"):
                        logger.info(f"{p_tag}[{base_target_name}] Tentative de nettoyage suite a l'erreur: {cleanup_block[:50]}...")
                        try:
                            clean_stmt = cleanup_block.strip(';')
                            source_cursor.execute(clean_stmt)
                        except Exception as drop_e:
                            logger.warning(f"{p_tag}[{base_target_name}] Echec du nettoyage: {drop_e}")
                raise inner_e
            finally:
                source_cursor.close()
                
        finally:
            source_conn.close()
            target_conn.close()
        
        return True
    except Exception as e:
        logger.error(f"{p_tag} Echec global sur {sql_file_path} : {str(e)}")
        return False

def execute_bi_script(prefix, parent_dir, target_creds):
    possible_files = [
        os.path.join(parent_dir, "script_bi.sql"),
        os.path.join(parent_dir, "script bi.sql")
    ]
    bi_file_path = None
    for path in possible_files:
        if os.path.isfile(path):
            bi_file_path = path
            break
    
    if not bi_file_path:
        logger.warning(f"[{prefix}] Aucun script BI trouvé sous {parent_dir}.")
        return False

    logger.info("=" * 60)
    logger.info(f"[{prefix}] DÉMARRAGE DU SCRIPT BI POST-ETL : {os.path.basename(bi_file_path)}")
    logger.info("=" * 60)

    try:
        with open(bi_file_path, "r", encoding="utf-8") as f:
            sql_content = f.read().strip()

        if not sql_content:
            logger.warning(f"[{prefix}] Le fichier {bi_file_path} est vide.")
            return True

        blocks = []
        current_block = []
        for line in sql_content.split('\n'):
            if line.strip() == '/':
                if current_block:
                    blocks.append('\n'.join(current_block).strip())
                    current_block = []
            else:
                current_block.append(line)

        if current_block:
            joined = '\n'.join(current_block).strip()
            if joined:
                blocks.append(joined)

        target_conn = get_connection(*target_creds)
        try:
            target_cursor = target_conn.cursor()
            try:
                for idx, block in enumerate(blocks):
                    block_clean = block.strip()
                    upper_block = block_clean.upper()

                    if not (upper_block.startswith("BEGIN") or upper_block.startswith("DECLARE")):
                        if block_clean.endswith(';'):
                            block_clean = block_clean[:-1].strip()
                            upper_block = block_clean.upper()

                    if upper_block == "COMMIT":
                        target_conn.commit()
                        logger.info(f"[{prefix}][SCRIPT BI] COMMIT exécuté sur la base cible.")
                    elif block_clean:
                        logger.info(f"[{prefix}][SCRIPT BI] Exécution bloc {idx+1}/{len(blocks)}...")
                        target_cursor.execute(block_clean)
                        target_conn.commit()
                logger.info(f"[{prefix}][SCRIPT BI] SCRIPT BI exécuté avec succès !")
            finally:
                target_cursor.close()
        finally:
            target_conn.close()
        return True
    except Exception as e:
        logger.error(f"[{prefix}][SCRIPT BI] Échec global lors de l'exécution du script BI {bi_file_path} : {e}")
        return False

def run_for_filiale(prefix):
    logger.info("=" * 60)
    logger.info(f"[{prefix}] DÉMARRAGE DU TRAITEMENT POUR LA FILIALE : {prefix}")
    logger.info("=" * 60)
    
    source_user = os.getenv(f"{prefix}_DB_SOURCE_USER")
    source_password = os.getenv(f"{prefix}_DB_SOURCE_PASSWORD")
    source_host = os.getenv(f"{prefix}_DB_SOURCE_HOST")
    source_port = os.getenv(f"{prefix}_DB_SOURCE_PORT", "1521")
    source_service = os.getenv(f"{prefix}_DB_SOURCE_SERVICE")
    
    target_user = os.getenv(f"{prefix}_DB_TARGET_USER")
    target_password = os.getenv(f"{prefix}_DB_TARGET_PASSWORD")
    target_host = os.getenv(f"{prefix}_DB_TARGET_HOST")
    target_port = os.getenv(f"{prefix}_DB_TARGET_PORT", "1521")
    target_service = os.getenv(f"{prefix}_DB_TARGET_SERVICE")
    
    parent_dir = os.getenv(f"{prefix}_SQL_PARENT_DIR")
    if not parent_dir:
        candidates = [os.path.join("..", prefix.lower()), prefix.lower()]
        for cand in candidates:
            if os.path.exists(cand):
                parent_dir = cand
                break
    
    if not all([source_user, source_host, source_service, target_user, target_host, target_service, parent_dir]):
        logger.warning(f"[{prefix}] Configuration environnement incomplète ! Vérifiez le fichier .env. Filiale ignorée.")
        return

    source_dsn = f"{source_host}:{source_port}/{source_service}"
    target_dsn = f"{target_host}:{target_port}/{target_service}"

    source_creds = (source_user, source_password, source_dsn)
    target_creds = (target_user, target_password, target_dsn)

    # Tri : le dossier *_controle_gestion passe toujours en premier, les autres suivent par ordre alphabétique
    bloc_dirs = sorted(
        [os.path.join(parent_dir, d) for d in os.listdir(parent_dir)
         if d.startswith("bloc") and os.path.isdir(os.path.join(parent_dir, d))],
        key=lambda d: (0 if os.path.basename(d).endswith("_controle_gestion") else 1, os.path.basename(d))
    )
    
    if not bloc_dirs:
         logger.warning(f"[{prefix}] Aucun dossier commençant par 'bloc' trouvé sous {parent_dir}.")
         return

         
    simple_tasks = []
    complex_tasks = []
    for d in bloc_dirs:
         sql_files = glob.glob(os.path.join(d, "*.sql"))
         for file_path in sql_files:
             filename = os.path.basename(file_path)
             base_name = filename.replace(".sql", "")
             if is_complex_script(file_path):
                 complex_tasks.append((file_path, base_name))
             else:
                 simple_tasks.append((file_path, base_name))

    total = len(simple_tasks) + len(complex_tasks)
    logger.info(f"[{prefix}] {total} fichiers SQL identifiés : "
                f"{len(simple_tasks)} simples (parallèle) | {len(complex_tasks)} complexes (séquentiel)")
    
    MAX_WORKERS = 5
    success_count = 0
    failure_count = 0
    
    if complex_tasks:
        logger.info(f"[{prefix}] === PHASE 1 : Scripts complexes (SÉQUENTIEL) ===")
        for sql_file, base_name in complex_tasks:
            logger.info(f"[{prefix}] [SÉQUENTIEL] Traitement de {base_name}...")
            try:
                is_success = process_single_sql_file(sql_file, base_name, source_creds, target_creds, prefix)
                if is_success:
                    success_count += 1
                else:
                    failure_count += 1
            except Exception as exc:
                logger.error(f"[{prefix}] Le fichier {sql_file} a levé l'exception: {exc}")
                failure_count += 1
    
    if simple_tasks:
        logger.info(f"[{prefix}] === PHASE 2 : Scripts simples (PARALLÈLE x{MAX_WORKERS}) ===")
        with ThreadPoolExecutor(max_workers=MAX_WORKERS, thread_name_prefix=f"{prefix}-Worker") as executor:
            future_to_sql = {
                executor.submit(process_single_sql_file, sql_file, base_name, source_creds, target_creds, prefix): sql_file 
                for sql_file, base_name in simple_tasks
            }
            
            for future in as_completed(future_to_sql):
                sql_file = future_to_sql[future]
                try:
                    is_success = future.result()
                    if is_success:
                        success_count += 1
                    else:
                        failure_count += 1
                except Exception as exc:
                    logger.error(f"[{prefix}] Le fichier {sql_file} a levé l'exception: {exc}")
                    failure_count += 1
                
    logger.info("-" * 40)
    logger.info(f"[{prefix}] FIN DATAMARTS POUR {prefix}")
    logger.info(f"[{prefix}] Fichiers traités avec succès : {success_count}/{total}")
    logger.info(f"[{prefix}] Fichiers en échec : {failure_count}/{total}")
    logger.info("-" * 40)

    # Exécution du script BI post-ETL si présent (ex: CAS, PROCESS)
    possible_bi = [
        os.path.join(parent_dir, "script_bi.sql"),
        os.path.join(parent_dir, "script bi.sql")
    ]
    if any(os.path.isfile(p) for p in possible_bi):
        execute_bi_script(prefix, parent_dir, target_creds)

def run_pole(pole_name, filiales):
    logger.info("#" * 60)
    logger.info(f"DÉMARRAGE DU {pole_name} - FILIALES : {', '.join(filiales)}")
    logger.info("#" * 60)
    for filiale in filiales:
        run_for_filiale(filiale)
    logger.info("#" * 60)
    logger.info(f"FIN DU {pole_name}")
    logger.info("#" * 60)

def main():
    start_time = time.perf_counter()  

    load_dotenv()

    pole1_filiales = ["CMGP", "SICDA", "PHILEA"]
    pole2_filiales = ["CAS", "PROCESS"]

    logger.info("DÉMARRAGE SIMULTANÉ DU PÔLE 1 ET DU PÔLE 2 (2 PÔLES EN PARALLÈLE, 5 WORKERS CHACUN)")

    with ThreadPoolExecutor(max_workers=2, thread_name_prefix="PoleExecutor") as executor:
        futures = {
            executor.submit(run_pole, "PÔLE 1 (Serveur Prod 1)", pole1_filiales): "PÔLE 1",
            executor.submit(run_pole, "PÔLE 2 (Serveur Prod 2)", pole2_filiales): "PÔLE 2"
        }
        for future in as_completed(futures):
            pole_id = futures[future]
            try:
                future.result()
                logger.info(f"{pole_id} terminé avec succès.")
            except Exception as exc:
                logger.error(f"{pole_id} a levé une exception : {exc}")

    end_time = time.perf_counter()  
    total_time = end_time - start_time

    logger.info("TOUS LES PÔLES ET FILIALES ONT ÉTÉ TRAITÉS.")
    logger.info(f"Temps total d'exécution : {total_time:.2f} secondes.")

if __name__ == "__main__":
    main()