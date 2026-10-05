"""
main.py — Point d'entrée du pipeline global d'alimentation de balance_analytique.
"""

import argparse
import logging
import sys
import warnings
from typing import List, Dict, Any

warnings.filterwarnings("ignore", message=".*pandas only supports SQLAlchemy.*")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("main")

ALL_SOURCES = [
    "agirh",
    "commercial02",
    "stojou_p",
    "stojou_d",
    "commercial04",
    "commercial06",
]


def run_pipeline(
    env_path: str = ".env",
    entites: List[str] = None,
    sources: List[str] = None,
    mode: str = "delete_insert",
):
    """Exécute le pipeline pour chaque entité et chaque source demandée."""
    from etl.config import load_config, get_entities_list
    import etl.extract as ext
    from etl.transform import transform_odp_agirh, standardize_balance_df
    from etl.load import load

    if not entites:
        entites = get_entities_list(env_path)

    sources_to_run = ALL_SOURCES if not sources or "all" in sources else [s.strip().lower() for s in sources if s.strip()]

    # Mapping flux standards : clé -> (fonction_extraction, nom_source_table, description)
    flux_standards = {
        "commercial02": (ext.extract_commercial02, "COMMERCIAL02", "CA Ventes (Oracle BI)"),
        "stojou_p":     (ext.extract_stojou_p, "STOJOU_CMGP_GLOBAL_P", "Stocks P FIFO (Sage X3)"),
        "stojou_d":     (ext.extract_stojou_d, "STOJOU_CMGP_GLOBAL_D", "Stocks D FIFO (Sage X3)"),
        "commercial04": (ext.extract_commercial04_remise, "COMMERCIAL04", "Remises de pied (Sage X3)"),
        "commercial06": (ext.extract_commercial06_af, "COMMERCIAL06", "Avoirs Financiers AF (Sage X3)"),
        # "datamart_analytique": (ext.extract_datamart_analytique, "DATAMART_ANALYTIQUE", "Grand Livre (Oracle BI)"),
    }

    logger.info("=" * 70)
    logger.info(f"DÉMARRAGE — Pipeline Global BALANCE_ANALYTIQUE | Entités: {', '.join(entites)} | Mode: {mode}")
    logger.info("=" * 70)

    stats: Dict[str, Dict[str, Any]] = {}

    for i, entite in enumerate(entites, 1):
        logger.info(f"[{i}/{len(entites)}] TRAITEMENT DE L'ENTITÉ : {entite}")
        config = load_config(env_path, entite)
        stats[entite] = {}

        # 1. Flux AGIRH (combinaison X3 ODP + SQL Server AGIRH)
        if "agirh" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Paie AGIRH (ODP X3 + SQL Server)")
                df_bal = transform_odp_agirh(ext.extract_x3(config), ext.extract_agirh(config))
                nb = load(df_bal, config, source_name="AGIRH", mode=mode)
                stats[entite]["AGIRH"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur AGIRH : {e}", exc_info=True)
                stats[entite]["AGIRH"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # 2. Flux standards (Commercial, Stocks, Avoirs)
        for key, (extract_fn, src_name, desc) in flux_standards.items():
            if key in sources_to_run:
                try:
                    logger.info(f"[{entite}] >> {desc}")
                    df_raw = extract_fn(config)
                    df_bal = standardize_balance_df(df_raw, default_source=src_name)
                    nb = load(df_bal, config, source_name=src_name, mode=mode)
                    stats[entite][src_name] = {"statut": "OK", "lignes": nb}
                except Exception as e:
                    logger.error(f"[{entite}] Erreur sur {key} : {e}", exc_info=True)
                    stats[entite][src_name] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

    # Rapport final
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


def main():
    parser = argparse.ArgumentParser(description="Pipeline global d'alimentation de balance_analytique")
    parser.add_argument("--entites", "-e", default=None, help="Entités séparées par virgules (ex: CMGP,SICDA)")
    parser.add_argument("--sources", "-s", default="all", help="Sources à traiter (ex: commercial02,stojou_p ou all)")
    parser.add_argument("--env", default=".env", help="Chemin vers le fichier .env")
    parser.add_argument("--truncate", action="store_true", help="TRUNCATE complet au lieu de la purge ciblée")

    args = parser.parse_args()
    entites = [e.strip().upper() for e in args.entites.split(",") if e.strip()] if args.entites else None
    sources = [s.strip().lower() for s in args.sources.split(",") if s.strip()] if args.sources else None
    mode = "truncate" if args.truncate else "delete_insert"

    try:
        run_pipeline(env_path=args.env, entites=entites, sources=sources, mode=mode)
    except Exception as e:
        logger.error(f"ERREUR FATALE : {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
