import time
import pandas as pd
from db import get_engine, invalidate_engine
from config import SOURCE_TABLE_VIEW
from metrics import EXTRACTION_LAST_ROWS

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 5


def extract_from_schema(config, schema_name):

    print(f"[{schema_name}] Starting extraction...")

    last_error = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            query = f"SELECT * FROM {schema_name}.{SOURCE_TABLE_VIEW}"

            engine = get_engine(config)
            df = pd.read_sql(query, engine)

            if df.empty:
                print(f"[{schema_name}] No rows extracted. Returning empty DataFrame.")
                return df

            # normalize column names to uppercase
            df.columns = df.columns.str.upper()

            # rename brp to bpr if brp exists from cmgp philea
            if 'BRP_0' in df.columns:
                df.rename(columns={'BRP_0': 'BPR_0'}, inplace=True)

            # add source dossier column replacing any existing dossier
            if 'DOSSIER_0' in df.columns:
                df.drop(columns=['DOSSIER_0'], inplace=True)

            df['DOSSIER_0'] = schema_name

            # ensure all required columns are there
            required_cols = [
                'ACCDAT_0', 'BPR_0', 'NOMCLT_0', 'NUM_0', 'MNTGLB_0',
                'MNTREG_0', 'SITE_0', 'DES_0', 'MOTIF_0', 'BANQUE_0',
                'REP_0', 'EMAIL_0', 'DOSSIER_0', 'BPCGRU_0'
            ]

            for col in required_cols:
                if col not in df.columns:
                    df[col] = None

            # rearrange and filter strictly
            df = df[required_cols]

            print(f"[{schema_name}] Extracted {len(df)} rows.")
            EXTRACTION_LAST_ROWS.labels(schema=schema_name).set(len(df))
            return df

        except Exception as e:
            last_error = e
            print(f"[{schema_name}] Extraction attempt {attempt}/{MAX_RETRIES} failed: {e}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY_SECONDS * attempt)

    print(f"[{schema_name}] Extraction failed after {MAX_RETRIES} attempts: {last_error}")
    invalidate_engine(config)
    if last_error is not None:
        raise last_error
    else:
        raise Exception(f"[{schema_name}] Extraction failed after {MAX_RETRIES} attempts")

