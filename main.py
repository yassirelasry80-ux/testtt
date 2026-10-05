"""
main.py — Point d'entrée du pipeline global d'alimentation de la table balance_analytique.

Sources supportées :
    - agirh         : Ventilation de paie (Sage X3 ODP vs AGIRH SQL Server)
    - commercial02  : Chiffre d'Affaires net lignes de ventes (Oracle BI)
    - stojou_p      : Coût d'achat FIFO des ventes Production (Sage X3)
    - stojou_d      : Coût d'achat FIFO des ventes Distribution (Sage X3)
    - commercial04  : Remises exceptionnelles en pied de facture (Sage X3)
    - commercial06  : Avoirs financiers AF / RFA (Sage X3)

Usage :
    # Exécuter tous les flux pour toutes les entités configurées
    python main.py

    # Exécuter uniquement CMGP
    python main.py --entites CMGP

    # Exécuter uniquement les flux commerciaux et stocks
    python main.py --sources commercial02,stojou_p,stojou_d,commercial04,commercial06

    # Exécuter uniquement la paie
    python main.py --sources agirh
"""

import argparse
import logging
import sys
import warnings
from typing import List, Dict

# Supprimer le warning Pandas sur SQLAlchemy
warnings.filterwarnings("ignore", message=".*pandas only supports SQLAlchemy.*")

# Configuration du logging
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
    # "datamart_analytique",  # Désactivé : évite les doublons avec commercial02
]


def run_pipeline(
    env_path: str = ".env",
    entites: List[str] = None,
    sources: List[str] = None,
    mode: str = "delete_insert",
):
    """
    Exécute le pipeline d'alimentation de balance_analytique pour chaque entité et chaque source.
    """
    from etl.config import load_config, get_entities_list
    from etl.extract import (
        extract_x3,
        extract_agirh,
        extract_commercial02,
        extract_stojou_p,
        extract_stojou_d,
        extract_commercial04_remise,
        extract_commercial06_af,
        extract_datamart_analytique,
    )
    from etl.transform import transform_odp_agirh, standardize_balance_df
    from etl.load import load

    if not entites:
        entites = get_entities_list(env_path)

    if not sources or "all" in sources:
        sources_to_run = ALL_SOURCES
    else:
        sources_to_run = [s.strip().lower() for s in sources if s.strip()]

    logger.info("=" * 70)
    logger.info("DÉMARRAGE — Pipeline Global d'Alimentation BALANCE_ANALYTIQUE")
    logger.info(f"Entités ({len(entites)}) : {', '.join(entites)}")
    logger.info(f"Flux sélectionnés ({len(sources_to_run)}) : {', '.join(sources_to_run)}")
    logger.info(f"Mode de chargement : {mode}")
    logger.info("=" * 70)

    # Récapitulatif global : {entite: {source: nb_lignes}}
    stats_globales: Dict[str, Dict[str, Any]] = {}

    for i, entite in enumerate(entites, 1):
        logger.info("-" * 70)
        logger.info(f"[{i}/{len(entites)}] TRAITEMENT DE L'ENTITÉ : {entite}")
        logger.info("-" * 70)

        config = load_config(env_path, entite)
        stats_globales[entite] = {}

        # ── 1. FLUX AGIRH (Paie ODP) ──
        if "agirh" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 1/6 : Paie AGIRH (ODP X3 + SQL Server)")
                df_x3 = extract_x3(config)
                df_agirh = extract_agirh(config)
                df_bal = transform_odp_agirh(df_x3, df_agirh)
                nb = load(df_bal, config, source_name="AGIRH", mode=mode)
                stats_globales[entite]["AGIRH"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur AGIRH : {e}", exc_info=True)
                stats_globales[entite]["AGIRH"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 2. FLUX COMMERCIAL02 (Chiffre d'Affaires sur Oracle BI) ──
        if "commercial02" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 2/6 : Commercial02 (CA Ventes depuis BI)")
                df_comm = extract_commercial02(config)
                df_bal = standardize_balance_df(df_comm, default_source="COMMERCIAL02")
                nb = load(df_bal, config, source_name="COMMERCIAL02", mode=mode)
                stats_globales[entite]["COMMERCIAL02"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur commercial02 : {e}", exc_info=True)
                stats_globales[entite]["COMMERCIAL02"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 3. FLUX STOJOU P (Coût des Ventes P sur Sage X3) ──
        if "stojou_p" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 3/6 : Stojou P (Stocks P FIFO depuis Sage X3)")
                df_stk_p = extract_stojou_p(config)
                df_bal = standardize_balance_df(df_stk_p, default_source="STOJOU_CMGP_GLOBAL_P")
                nb = load(df_bal, config, source_name="STOJOU_CMGP_GLOBAL_P", mode=mode)
                stats_globales[entite]["STOJOU_P"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur stojou_p : {e}", exc_info=True)
                stats_globales[entite]["STOJOU_P"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 4. FLUX STOJOU D (Coût des Ventes D sur Sage X3) ──
        if "stojou_d" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 4/6 : Stojou D (Stocks D FIFO depuis Sage X3)")
                df_stk_d = extract_stojou_d(config)
                df_bal = standardize_balance_df(df_stk_d, default_source="STOJOU_CMGP_GLOBAL_D")
                nb = load(df_bal, config, source_name="STOJOU_CMGP_GLOBAL_D", mode=mode)
                stats_globales[entite]["STOJOU_D"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur stojou_d : {e}", exc_info=True)
                stats_globales[entite]["STOJOU_D"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 5. FLUX COMMERCIAL04 (Remises Exceptionnelles sur Sage X3) ──
        if "commercial04" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 5/6 : Commercial04 (Remises de pied depuis Sage X3)")
                df_rem = extract_commercial04_remise(config)
                df_bal = standardize_balance_df(df_rem, default_source="COMMERCIAL04")
                nb = load(df_bal, config, source_name="COMMERCIAL04", mode=mode)
                stats_globales[entite]["COMMERCIAL04"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur commercial04 : {e}", exc_info=True)
                stats_globales[entite]["COMMERCIAL04"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 6. FLUX COMMERCIAL06 (Avoirs Financiers AF sur Sage X3) ──
        if "commercial06" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 6/7 : Commercial06 (Avoirs Financiers AF depuis Sage X3)")
                df_af = extract_commercial06_af(config)
                df_bal = standardize_balance_df(df_af, default_source="COMMERCIAL06")
                nb = load(df_bal, config, source_name="COMMERCIAL06", mode=mode)
                stats_globales[entite]["COMMERCIAL06"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur commercial06 : {e}", exc_info=True)
                stats_globales[entite]["COMMERCIAL06"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

        # ── 7. FLUX DATAMART_ANALYTIQUE (Autres Charges & Produits sur Oracle BI) ──
        # S'exécute impérativement EN DERNIER car il filtre : WHERE num_0 NOT IN (SELECT num_piece FROM balance_analytique)
        if "datamart_analytique" in sources_to_run:
            try:
                logger.info(f"[{entite}] >> Flux 7/7 : Datamart Analytique (Autres écritures P&L depuis BI)")
                df_dm = extract_datamart_analytique(config)
                df_bal = standardize_balance_df(df_dm, default_source="DATAMART_ANALYTIQUE")
                nb = load(df_bal, config, source_name="DATAMART_ANALYTIQUE", mode=mode)
                stats_globales[entite]["DATAMART_ANALYTIQUE"] = {"statut": "OK", "lignes": nb}
            except Exception as e:
                logger.error(f"[{entite}] Erreur sur datamart_analytique : {e}", exc_info=True)
                stats_globales[entite]["DATAMART_ANALYTIQUE"] = {"statut": "KO", "lignes": 0, "erreur": str(e)}

    # ── RAPPORT RÉCAPITULATIF FINAL ──
    print()
    print("+" + "=" * 76 + "+")
    print("|            RÉCAPITULATIF D'ALIMENTATION BALANCE ANALYTIQUE               |")
    print("+" + "=" * 76 + "+")
    print("|  Entité    | Source              | Statut | Lignes chargées | Info        |")
    print("|  ----------+---------------------+--------+-----------------+------------ |")
    for ent, sources_dict in stats_globales.items():
        for src, res in sources_dict.items():
            stat = "[OK]" if res["statut"] == "OK" else "[KO]"
            err = res.get("erreur", "")
            err_short = (err[:10] + "...") if err else ""
            print(f"|  {ent:<10}| {src:<20}| {stat:<7}| {res['lignes']:>15} | {err_short:<12}|")
    print("+" + "=" * 76 + "+")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Pipeline global d'alimentation de la table balance_analytique"
    )
    parser.add_argument(
        "--entites", "-e", default=None,
        help="Entité(s) à traiter, séparées par virgules (ex: CMGP,SICDA). Défaut : toutes les entités du .env"
    )
    parser.add_argument(
        "--sources", "-s", default="all",
        help="Source(s) à traiter (ex: commercial02,stojou_p,commercial04,commercial06,agirh ou all)"
    )
    parser.add_argument(
        "--env", default=".env",
        help="Chemin vers le fichier .env (défaut : .env)"
    )
    parser.add_argument(
        "--truncate", action="store_true",
        help="Si activé, effectue un TRUNCATE complet au lieu d'une purge ciblée par source"
    )

    args = parser.parse_args()

    entites_list = [e.strip().upper() for e in args.entites.split(",") if e.strip()] if args.entites else None
    sources_list = [s.strip().lower() for s in args.sources.split(",") if s.strip()] if args.sources else None
    mode = "truncate" if args.truncate else "delete_insert"

    try:
        run_pipeline(
            env_path=args.env,
            entites=entites_list,
            sources=sources_list,
            mode=mode,
        )
    except Exception as e:
        logger.error(f"ERREUR FATALE : {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
