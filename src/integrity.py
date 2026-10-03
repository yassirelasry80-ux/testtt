from db import get_connection, get_central_schema
from config import TARGET_TABLE_CONSO


def verify_integrity(config_crm, df_source, source_name):
    """
    Verifies that the number of extracted rows from source_name matches CRM count.
    """
    if df_source.empty:
        print(f"[{source_name}] No data to verify.")
        return True

    schema_crm = get_central_schema(config_crm)
    table_crm = f"{schema_crm}.{TARGET_TABLE_CONSO}"

    extracted_count = len(df_source)

    conn = None
    try:
        conn = get_connection(config_crm)
        cursor = conn.cursor()

        # we only count active rows for the given dossier
        query = f"""
            SELECT COUNT(1) 
            FROM {table_crm} 
            WHERE DOSSIER_0 = '{source_name}' 
            AND MNTREG_0 < MNTGLB_0
        """
        cursor.execute(query)
        crm_count = cursor.fetchone()[0]
        cursor.close()

        if crm_count == extracted_count:
            print(f"[{source_name}] Integrity OK: {extracted_count} == {crm_count}")
            return True
        else:
            msg = f"Mismatch: Extracted {extracted_count} != CRM {crm_count}"
            print(f"[{source_name}] FAILURE: {msg}")
            return False

    except Exception as e:
        print(f"[{source_name}] Error during integrity verification: {e}")
        return False
    finally:
        if conn:
            conn.close()
