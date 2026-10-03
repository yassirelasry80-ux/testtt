import oracledb
from sqlalchemy import create_engine


try:
    oracledb.init_oracle_client()
except Exception as e:
    print(f"Warning: Could not initialize Oracle Client: {e}. If thin mode works for your DB, this is fine.")

_engines = {}

def get_engine(config):

    url = (
        f"oracle+oracledb://{config['user']}:{config['password']}"
        f"@{config['dsn']}"
    )
    if url not in _engines:

        _engines[url] = create_engine(
            url,
            thick_mode=False,
            pool_size=5,
            max_overflow=10,
            pool_recycle=3600,
            pool_pre_ping=True,
            connect_args={"tcp_connect_timeout": 10}
        )
        print(f"[DB] Initialized new SQLAlchemy Engine for {config['dsn']}")

    return _engines[url]


def invalidate_engine(config):

    url = (
        f"oracle+oracledb://{config['user']}:{config['password']}"
        f"@{config['dsn']}"
    )
    engine = _engines.pop(url, None)
    if engine is not None:
        try:
            engine.dispose()
        except Exception:
            pass
        print(f"[DB] Engine cache invalidé pour {config['dsn']} (sera recréé au prochain cycle)")

def get_connection(config):

    try:
        connection = oracledb.connect(
            user=config["user"],
            password=config["password"],
            dsn=config["dsn"]
        )
        return connection
    except Exception as e:
        print(f"Error connecting to DB {config['dsn']}: {e}")
        raise


def get_central_schema(config):

    return config.get("central_schema", "")

def chunk_generator(data_list, chunk_size):
    for i in range(0, len(data_list), chunk_size):
        yield data_list[i:i + chunk_size]

def execute_batch(connection, sql, data, batch_size=5000):

    if not data:
        return 0
    
    cursor = connection.cursor()
    total_executed = 0
    
    try:
        for chunk in chunk_generator(data, batch_size):
            cursor.executemany(sql, chunk)
            total_executed += len(chunk)
        connection.commit()
    except Exception as e:
        connection.rollback()
        raise e
    finally:
        cursor.close()
        
    return total_executed
