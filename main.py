"""
main.py — Exécution directe du pipeline global d'alimentation de balance_analytique.
"""

import logging
import sys
import warnings
from typing import Dict, Any

from etl.config import load_config, get_entities_list
import etl.extract as ext
from etl.transform import transform_odp_agirh, standardize_balance_df
from etl.load import load

warnings.filterwarnings("ignore", message=".*pandas only supports SQLAlchemy.*")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("main")

# Mapping des flux standards : (fonction_extraction, nom_source_table, description)
FLUX_STANDARDS = [
    (ext.extract_commercial02, "COMMERCIAL02", "CA Ventes (Oracle BI)"),
    (ext.extract_stojou_p, "STOJOU_CMGP_GLOBAL_P", "Stocks P FIFO (Sage X3)"),
    (ext.extract_stojou_d, "STOJOU_CMGP_GLOBAL_D", "Stocks D FIFO (Sage X3)"),
    (ext.extract_commercial04_remise, "COMMERCIAL04", "Remises de pied (Sage X3)"),
    (ext.extract_commercial06_af, "COMMERCIAL06", "Avoirs Financiers AF (Sage X3)"),
    # (ext.extract_datamart_analytique, "DATAMART_ANALYTIQUE", "Grand Livre (Oracle BI)"),
    (ext.extract_moovapps, "MOOVAPPS", "Moovapps (Oracle)"),
]


def run():
    """Démarre directement le pipeline sur toutes les filiales définies dans le .env."""
    entites = get_entities_list()

    logger.info("=" * 70)
    logger.info(f"DÉMARRAGE — Pipeline Global BALANCE_ANALYTIQUE | Entités: {', '.join(entites)}")
    logger.info("=" * 70)

    stats: Dict[str, Dict[str, Any]] = {}

    for i, entite in enumerate(entites, 1):
        logger.info(f"[{i}/{len(entites)}] TRAITEMENT DE L'ENTITÉ : {entite}")
        config = load_config(entite_name=entite)
        stats[entite] = {}

        # 1. Flux AGIRH (Paie ODP X3 + AGIRH SQL Server)
        try:
            logger.info(f"[{entite}] >> Paie AGIRH (ODP X3 + SQL Server)")
            df_bal = transform_odp_agirh(ext.extract_x3(config), ext.extract_agirh(config))
            nb = load(df_bal, config, source_name="AGIRH")
            stats[entite]["AGIRH"] = {"statut": "OK", "lignes": nb}
        except Exception as e:
            logger.error(f"[{entite}] Erreur sur AGIRH : {e}", exc_info=True)
            stats[entite]["AGIRH"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # 2. Flux standards (Ventes, Stocks, Remises, Avoirs)
        for extract_fn, src_name, desc in FLUX_STANDARDS:
            try:
                logger.info(f"[{entite}] >> {desc}")
                df_raw = extract_fn(config)
                df_bal = standardize_balance_df(df_raw, default_source=src_name)
                nb = load(df_bal, config, source_name=src_name)
                stats[entite][src_name] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur {src_name} : {e}", exc_info=True)
                stats[entite][src_name] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

    # Rapport final d'exécution
    print("\n+" + "=" * 76 + "+")
    print("|            RÉCAPITULATIF D'ALIMENTATION BALANCE ANALYTIQUE               |")
    print("+" + "=" * 76 + "+")
    print("|  Entité    | Source              | Statut | Lignes chargées | Info        |")
    print("|  ----------+---------------------+--------+-----------------+------------ |")
    for ent, res_dict in stats.items():
        for src, res in res_dict.items():
            stat = "[OK]" if res["statut"] == "OK" else "[KO]"
            err = res.get("erreur", "")
            err_short = (err[:10] + "...") if err else ""
            print(f"|  {ent:<10}| {src:<20}| {stat:<7}| {res['lignes']:>15} | {err_short:<12}|")
    print("+" + "=" * 76 + "+\n")


if __name__ == "__main__":
    try:
        run()
    except Exception as e:
        logger.error(f"ERREUR FATALE : {e}", exc_info=True)
        sys.exit(1)
