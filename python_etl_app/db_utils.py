import os
import oracledb
import logging

oracledb.defaults.fetch_decimals = True

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Timeout TCP de connexion en secondes (défaut : 30s)
CONNECT_TIMEOUT = float(os.getenv("DB_CONNECT_TIMEOUT", "30"))
# Timeout d'exécution d'une instruction SQL en millisecondes (défaut : 10 min)
CALL_TIMEOUT_MS  = int(os.getenv("DB_CALL_TIMEOUT_MS", str(10 * 60 * 1000)))

_oracle_client_initialized = False

def get_connection(user, password, dsn):
    global _oracle_client_initialized
    if not _oracle_client_initialized:
        try:
            oracledb.init_oracle_client()
            _oracle_client_initialized = True
        except oracledb.ProgrammingError:
            _oracle_client_initialized = True  # déjà initialisé
        except Exception as e:
            logger.warning(f"Erreur d'initialisation du client Oracle (mode Thick) : {e}")

    try:
        conn = oracledb.connect(
            user=user,
            password=password,
            dsn=dsn,
            tcp_connect_timeout=CONNECT_TIMEOUT
        )
        with conn.cursor() as cursor:
            cursor.callTimeout = CALL_TIMEOUT_MS
            cursor.execute("ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS'")
            cursor.execute("ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS.FF'")
        logger.debug(f"Connexion établie à {dsn} (tcp_timeout={CONNECT_TIMEOUT}s, call_timeout={CALL_TIMEOUT_MS}ms)")
        return conn
    except Exception as e:
        logger.error(f"Erreur lors de la connexion à {dsn} avec l'utilisateur {user}: {e}")
        raise

def map_oracle_type(description):

    col_name = description[0]
    type_code = description[1]
    display_size = description[2]
    internal_size = description[3]
    precision = description[4]
    scale = description[5]

    try:
        type_name = type_code.name.upper()
    except AttributeError:
        type_name = str(type_code).upper()

    if type_name in ('DB_TYPE_CHAR', 'CHAR'):
        size = internal_size if internal_size else (display_size if display_size else 2000)
        return f"{col_name} CHAR({size})"
    elif type_name in ('DB_TYPE_NCHAR', 'NCHAR'):
        size = internal_size if internal_size else (display_size if display_size else 2000)
        return f"{col_name} NCHAR({size})"
    elif type_name in ('DB_TYPE_NVARCHAR', 'NVARCHAR2', 'NVARCHAR'):
        size = internal_size if internal_size else (display_size if display_size else 4000)
        return f"{col_name} NVARCHAR2({size})"
    elif 'VARCHAR' in type_name:
        size = internal_size if internal_size else (display_size if display_size else 4000)
        return f"{col_name} VARCHAR2({size})"
    elif 'NUMBER' in type_name:

        return f"{col_name} NUMBER"
    elif 'FLOAT' in type_name or 'DOUBLE' in type_name:
        return f"{col_name} FLOAT"
    elif 'DATE' in type_name:
        return f"{col_name} DATE"
    elif 'TIMESTAMP' in type_name:
        return f"{col_name} TIMESTAMP"
    elif 'CLOB' in type_name:
        return f"{col_name} CLOB"
    elif 'BLOB' in type_name:
        return f"{col_name} BLOB"
    else:
        return f"{col_name} VARCHAR2(4000)"

def _existing_col_to_ddl(col_name, data_type, data_length, data_precision, data_scale):

    dl = int(data_length) if data_length is not None else None
    dp = int(data_precision) if data_precision is not None else None
    ds = int(data_scale) if data_scale is not None else None

    if data_type in ('CHAR', 'NCHAR'):
        return f"{col_name} {data_type}({dl})"
    elif data_type in ('VARCHAR2', 'NVARCHAR2'):
        return f"{col_name} {data_type}({dl})"
    elif data_type == 'NUMBER':
        if dp is not None and ds is not None and dp > 0:
            return f"{col_name} NUMBER({dp},{ds})"
        elif dp is not None and dp > 0:
            return f"{col_name} NUMBER({dp})"
        else:
            return f"{col_name} NUMBER"
    elif data_type == 'FLOAT':
        return f"{col_name} FLOAT"
    elif data_type == 'DATE':
        return f"{col_name} DATE"
    elif 'TIMESTAMP' in data_type:
        return f"{col_name} TIMESTAMP"
    elif data_type == 'CLOB':
        return f"{col_name} CLOB"
    elif data_type == 'BLOB':
        return f"{col_name} BLOB"
    else:
        return f"{col_name} VARCHAR2(4000)"

def _columns_match(target_cursor, table_name, cursor_description, prefix=""):
    p_tag = f"[{prefix}]" if prefix else ""

    expected = [map_oracle_type(desc) for desc in cursor_description]

    target_cursor.execute("""
        SELECT column_name, data_type, data_length, data_precision, data_scale
        FROM user_tab_columns
        WHERE UPPER(table_name) = :name
        ORDER BY column_id
    """, [table_name.upper()])
    existing_rows = target_cursor.fetchall()

    if len(existing_rows) != len(expected):
        logger.info(f"{p_tag}[{table_name}] Changement DDL detecte : nombre de colonnes ({len(existing_rows)} vs {len(expected)})")
        return False

    for i, (col_name, data_type, data_length, data_precision, data_scale) in enumerate(existing_rows):
        existing_ddl = _existing_col_to_ddl(col_name, data_type, data_length, data_precision, data_scale)
        if existing_ddl != expected[i]:
            logger.info(f"{p_tag}[{table_name}] Changement DDL detecte sur colonne {col_name}: "
                        f"existant=[{existing_ddl}] vs attendu=[{expected[i]}]")
            return False

    return True

def setup_target_table(target_cursor, table_name, cursor_description, prefix=""):
    p_tag = f"[{prefix}]" if prefix else ""

    target_cursor.execute("""
        SELECT count(*) FROM user_tables WHERE UPPER(table_name) = :name
    """, [table_name.upper()])

    table_exists = int(target_cursor.fetchone()[0]) > 0
    needs_create = False

    if table_exists:
        if _columns_match(target_cursor, table_name, cursor_description, prefix=prefix):
            logger.info(f"{p_tag}[{table_name}] La table existe avec structure identique. Truncate (vidage) en cours...")
            target_cursor.execute(f"TRUNCATE TABLE {table_name}")
        else:
            logger.info(f"{p_tag}[{table_name}] La table existe mais sa structure a change. Drop + Recreate en cours...")
            target_cursor.execute(f"DROP TABLE {table_name} PURGE")
            needs_create = True
    else:
        needs_create = True

    if needs_create:
        logger.info(f"{p_tag}[{table_name}] Creation de la table basee sur les metadonnees...")
        columns_ddl = ",\n".join([map_oracle_type(desc) for desc in cursor_description])
        create_stmt = f"CREATE TABLE {table_name} (\n{columns_ddl}\n) NOLOGGING"
        try:
            target_cursor.execute(create_stmt)
            logger.info(f"{p_tag}[{table_name}] Table creee avec succes.")
        except Exception as e:
            logger.error(f"{p_tag}[{table_name}] Echec de creation de la table : {e}\nRequete: {create_stmt}")
            raise

def stream_data(source_conn, target_conn, select_query, target_table_name, batch_size=70000, prefix=""):
    p_tag = f"[{prefix}]" if prefix else ""

    try:
        source_cursor = source_conn.cursor()
        source_cursor.callTimeout = CALL_TIMEOUT_MS
        target_cursor = target_conn.cursor()
        target_cursor.callTimeout = CALL_TIMEOUT_MS

        logger.info(f"{p_tag}[{target_table_name}] Execution de la requete source...")
        source_cursor.execute(select_query)
        description = source_cursor.description

        if not description:
             logger.warning(f"{p_tag}[{target_table_name}] La requete source n'a pas retourne de colonnes. Ignoree.")
             return

        setup_target_table(target_cursor, target_table_name, description, prefix=prefix)

        col_names = [desc[0] for desc in description]
        bind_vars = ", ".join([f":{i+1}" for i in range(len(col_names))])

        insert_stmt = f"INSERT /*+ APPEND_VALUES */ INTO {target_table_name} ({', '.join(col_names)}) VALUES ({bind_vars})"

        total_rows = 0
            
        while True:
            rows = source_cursor.fetchmany(batch_size)
            if not rows:
                break
            
            target_cursor.executemany(insert_stmt, rows)
            target_conn.commit() 
            total_rows += len(rows)
            logger.info(f"{p_tag}[{target_table_name}] {total_rows} lignes integrees...")

        logger.info(f"{p_tag}[{target_table_name}] Termine ! Total lignes: {total_rows}.")

    except Exception as e:
         logger.error(f"{p_tag}[{target_table_name}] Erreur lors du traitement ETL: {e}")
         target_conn.rollback()
         raise
    finally:
        source_cursor.close()
        target_cursor.close()

def verify_table_data(target_conn, base_table, test_table):

    cursor = target_conn.cursor()
    try:

        cursor.execute("SELECT count(*) FROM user_tables WHERE UPPER(table_name) IN (:1, :2)", [base_table.upper(), test_table.upper()])
        count_exist = int(cursor.fetchone()[0])
        
        if count_exist < 2:
            logger.warning(f"[{base_table}] Analyse MINUS annulee. La table d'origine de reference {base_table} n'existe pas dans la BdD de destination Qlik.")
            return

        logger.info(f"[{base_table}] Demarrage du controle du nombre de lignes (COUNT)...")
        
        cursor.execute(f"SELECT COUNT(*) FROM {base_table}")
        count_base = int(cursor.fetchone()[0])
        
        cursor.execute(f"SELECT COUNT(*) FROM {test_table}")
        count_test = int(cursor.fetchone()[0])

        if count_base != count_test:
            logger.error(f"[{base_table}] ALERTE ! ECARTS DETECTES ! Le nombre de lignes est different. "
                         f"({base_table}: {count_base} lignes | {test_table}: {count_test} lignes)")
    

        logger.info(f"[{base_table}] Le nombre de lignes est identique ({count_base}). Demarrage du controle avec MINUS bidirectionnel...")
        
        cursor.execute("SELECT column_name FROM user_tab_columns WHERE UPPER(table_name) = :name ORDER BY column_id", [base_table.upper()])
        base_cols = [row[0] for row in cursor.fetchall()]
        
        cursor.execute("SELECT column_name FROM user_tab_columns WHERE UPPER(table_name) = :name ORDER BY column_id", [test_table.upper()])
        test_cols = [row[0] for row in cursor.fetchall()]
        
        if base_cols != test_cols:
            logger.error(f"[{base_table}] ALERTE ! FAUSSE STRUCTURE DETECTEE. Les colonnes ou leur ordre ne correspondent pas.")
            logger.error(f"  -> Structure attendue ({base_table}): {', '.join(base_cols)}")
            logger.error(f"  -> Structure trouvée  ({test_table}): {', '.join(test_cols)}")
            return
            
        if not base_cols:
            logger.warning(f"[{base_table}] Aucune colonne trouvee pour ces tables.")
            return
            
        cols_str = ", ".join(base_cols)
        
        query_test_minus_base = f"SELECT {cols_str} FROM {test_table} MINUS SELECT {cols_str} FROM {base_table}"
        query_base_minus_test = f"SELECT {cols_str} FROM {base_table} MINUS SELECT {cols_str} FROM {test_table}"

        cursor.execute(f"SELECT COUNT(*) FROM ({query_test_minus_base})")
        val_test_to_base = int(cursor.fetchone()[0])

        cursor.execute(f"SELECT COUNT(*) FROM ({query_base_minus_test})")
        val_base_to_test = int(cursor.fetchone()[0])

        if val_test_to_base == 0 and val_base_to_test == 0:
            logger.info(f"[{base_table}] VERIFICATION [OK] - Parfaite correspondance des donnees ! (0 ecart)")
        else:
            logger.error(f"[{base_table}] ALERTE ! ECARTS DETECTES ! "
                         f"(Lignes uniques dans {test_table}: {val_test_to_base} | "
                         f"Lignes uniques dans {base_table}: {val_base_to_test})")
            
            if val_test_to_base > 0:
                cursor.execute(f"SELECT * FROM ({query_test_minus_base}) WHERE ROWNUM <= 5")
                sample_rows = cursor.fetchall()
                logger.error(f"[{base_table}] Exemples de lignes presentes dans {test_table} mais absentes ou differentes dans {base_table} :")
                for row in sample_rows:
                    logger.error(f"  -> {row}")

            if val_base_to_test > 0:
                cursor.execute(f"SELECT * FROM ({query_base_minus_test}) WHERE ROWNUM <= 5")
                sample_rows = cursor.fetchall()
                logger.error(f"[{base_table}] Exemples de lignes presentes dans {base_table} mais absentes ou differentes dans {test_table} :")
                for row in sample_rows:
                    logger.error(f"  -> {row}")

    except Exception as e:
         logger.error(f"[{base_table}] Erreur d'execution de la verification : {e}. (Types ou attributs inegaux)")
    finally:
        cursor.close()