"""
transform.py — Logique métier de ventilation analytique et standardisation des flux.

Gère :
    1. transform() / transform_odp_agirh() : Rapprochement X3 ODP vs AGIRH (Règles R1 à R4)
    2. standardize_balance_df() : Validation et mise en conformité du schéma pour balance_analytique
"""

import logging
from typing import List, Dict, Any
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)

COMMUN = "00000000"
TOLERANCE_ECART = 0.005  # Tolérance arrondi en MAD

# Colonnes officielles de la table balance_analytique
BALANCE_COLUMNS = [
    "NUM_PIECE", "COMPTE", "SENS", "AXE_CENTRE", "AXE_ENTITE",
    "AXE_BLINE", "AXE_SITE", "MONTANT", "TIERS_CODE", "ARTICLE_CODE",
    "DATE_COMPTABLE", "SOURCE", "TYPE_LIGNE",
]


def standardize_balance_df(df: pd.DataFrame, default_source: str = None) -> pd.DataFrame:
    """
    Standardise et valide un DataFrame pour insertion dans balance_analytique.
    Garantit les 13 colonnes, les types et l'intégrité des montants.
    """
    if df is None or df.empty:
        return _empty_result()

    df_out = df.copy()

    # Harmoniser la casse des colonnes
    df_out.columns = [str(c).strip().upper() for c in df_out.columns]

    # Compléter les colonnes manquantes avec None
    for col in BALANCE_COLUMNS:
        if col not in df_out.columns:
            df_out[col] = None

    # Garder uniquement les colonnes du schéma
    df_out = df_out[BALANCE_COLUMNS]

    # Types et nettoyages
    df_out["NUM_PIECE"] = df_out["NUM_PIECE"].astype(str).str.strip()
    df_out["COMPTE"] = df_out["COMPTE"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_out["SENS"] = pd.to_numeric(df_out["SENS"], errors="coerce").fillna(1).astype(int)
    
    # Montant : toujours positif et arrondi à 2 décimales
    df_out["MONTANT"] = pd.to_numeric(df_out["MONTANT"], errors="coerce").fillna(0.0).abs().round(2)

    # Date comptable
    df_out["DATE_COMPTABLE"] = pd.to_datetime(df_out["DATE_COMPTABLE"], errors="coerce")

    # Source et Type de ligne
    if default_source and "SOURCE" in df_out.columns:
        df_out["SOURCE"] = df_out["SOURCE"].fillna(default_source)
    df_out["TYPE_LIGNE"] = df_out["TYPE_LIGNE"].fillna("DETAIL")

    # Nettoyage des chaînes pour Oracle
    for axe in ["AXE_CENTRE", "AXE_ENTITE", "AXE_BLINE", "AXE_SITE", "TIERS_CODE", "ARTICLE_CODE"]:
        df_out[axe] = df_out[axe].apply(lambda x: None if pd.isna(x) or str(x).strip() in ("", "None", "nan") else str(x).strip())

    return df_out


def transform_odp_agirh(df_x3: pd.DataFrame, df_agirh: pd.DataFrame) -> pd.DataFrame:
    """
    Traitement de ventilation analytique de paie : X3 ODP LEFT JOIN AGIRH, mois par mois.
    """
    df_x3 = df_x3.copy()
    df_agirh = df_agirh.copy()
    df_x3["ACC_0"] = df_x3["ACC_0"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_agirh["CODE_interne"] = df_agirh["CODE_interne"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_x3["_mois"] = df_x3["ACCDAT_0"].dt.to_period("M")
    df_agirh["_mois"] = df_agirh["DT_COMPTA"].dt.to_period("M")

    mois_x3 = sorted(df_x3["_mois"].unique())
    logger.info(f"Mois à traiter : {[str(m) for m in mois_x3]}")

    all_results: List[Dict[str, Any]] = []
    anomalies: List[Dict[str, Any]] = []

    for mois in mois_x3:
        x3_mois = df_x3[df_x3["_mois"] == mois]
        agirh_mois = df_agirh[df_agirh["_mois"] == mois]

        pieces = x3_mois["NUM_0"].unique()
        for num_piece in pieces:
            results_piece = _process_piece(
                num_piece=num_piece,
                x3_piece=x3_mois[x3_mois["NUM_0"] == num_piece],
                agirh_mois=agirh_mois,
                anomalies=anomalies,
            )
            all_results.extend(results_piece)

        # Détecter les orphelins AGIRH
        comptes_x3 = set(x3_mois["ACC_0"].unique())
        comptes_agirh = set(agirh_mois["CODE_interne"].unique())
        orphelins = comptes_agirh - comptes_x3
        if orphelins:
            for acc in orphelins:
                anomalies.append({
                    "mois": str(mois),
                    "compte": acc,
                    "type": "ORPHELIN_AGIRH",
                    "detail": "Compte présent dans AGIRH mais absent dans X3",
                })

    df_result = pd.DataFrame(all_results)
    if df_result.empty:
        return _empty_result()

    _verify_equilibre(df_x3, df_result)
    return standardize_balance_df(df_result, default_source="AGIRH")


# Alias pour rétrocompatibilité
transform = transform_odp_agirh


def _process_piece(
    num_piece: str,
    x3_piece: pd.DataFrame,
    agirh_mois: pd.DataFrame,
    anomalies: list,
) -> List[Dict[str, Any]]:
    """Traite une pièce ODP : X3 LEFT JOIN AGIRH par compte."""
    results = []

    x3_agg = (
        x3_piece
        .groupby("ACC_0", as_index=False)
        .agg(
            AMTCUR_0=("AMTCUR_0", "sum"),
            SNS_0=("SNS_0", "first"),
            ACCDAT_0=("ACCDAT_0", "first"),
        )
    )

    for _, x3_row in x3_agg.iterrows():
        acc = str(x3_row["ACC_0"]).strip()
        montant_pere = x3_row["AMTCUR_0"]
        sens = int(x3_row["SNS_0"])
        date_comptable = x3_row["ACCDAT_0"]

        fils = agirh_mois[agirh_mois["CODE_interne"] == acc]

        if fils.empty:
            # CAS 2 : Non ventilé -> COMMUN
            results.append(_make_row(
                num_piece=num_piece,
                compte=acc,
                sens=sens,
                axe_centre=COMMUN,
                axe_entite=COMMUN,
                axe_bline=COMMUN,
                axe_site=COMMUN,
                montant=round(montant_pere, 2),
                date_comptable=date_comptable,
                source="AGIRH",
                type_ligne="COMMUN_NON_VENTILE",
            ))
        else:
            total_agirh = 0.0
            for _, ag_row in fils.iterrows():
                mt = ag_row["mt"]
                total_agirh += mt
                results.append(_make_row(
                    num_piece=num_piece,
                    compte=acc,
                    sens=sens,
                    axe_centre=str(ag_row.get("ETB", COMMUN)),
                    axe_entite=str(ag_row.get("ste", "")),
                    axe_bline=COMMUN,
                    axe_site=str(ag_row.get("CODE_AGENCE", COMMUN)),
                    montant=round(mt, 2),
                    date_comptable=date_comptable,
                    source="AGIRH",
                    type_ligne="DETAIL",
                ))

            ecart = round(montant_pere - total_agirh, 2)
            if abs(ecart) >= TOLERANCE_ECART:
                results.append(_make_row(
                    num_piece=num_piece,
                    compte=acc,
                    sens=sens,
                    axe_centre=COMMUN,
                    axe_entite=str(fils.iloc[0].get("ste", "")),
                    axe_bline=COMMUN,
                    axe_site=COMMUN,
                    montant=ecart,
                    date_comptable=date_comptable,
                    source="AGIRH",
                    type_ligne="COMMUN_ECART",
                ))

    return results


def _make_row(
    num_piece: str,
    compte: str,
    sens: int,
    axe_centre: str,
    axe_entite: str,
    axe_bline: str,
    axe_site: str,
    montant: float,
    date_comptable,
    source: str,
    type_ligne: str,
) -> Dict[str, Any]:
    """Construit un dict représentant une ligne de balance_analytique."""
    return {
        "NUM_PIECE": num_piece,
        "COMPTE": str(compte),
        "SENS": sens,
        "AXE_CENTRE": axe_centre,
        "AXE_ENTITE": axe_entite,
        "AXE_BLINE": axe_bline,
        "AXE_SITE": axe_site,
        "MONTANT": abs(montant),
        "TIERS_CODE": None,
        "ARTICLE_CODE": None,
        "DATE_COMPTABLE": date_comptable,
        "SOURCE": source,
        "TYPE_LIGNE": type_ligne,
    }


def _verify_equilibre(df_x3: pd.DataFrame, df_result: pd.DataFrame) -> None:
    """Vérification post-traitement de l'équilibre comptable."""
    x3_totals = df_x3.groupby(["NUM_0", "ACC_0"], as_index=False)["AMTCUR_0"].sum()
    res_totals = df_result.groupby(["NUM_PIECE", "COMPTE"], as_index=False)["MONTANT"].sum()

    x3_totals["ACC_0"] = x3_totals["ACC_0"].astype(str).str.strip()
    res_totals["COMPTE"] = res_totals["COMPTE"].astype(str).str.strip()

    merged = pd.merge(
        x3_totals,
        res_totals,
        left_on=["NUM_0", "ACC_0"],
        right_on=["NUM_PIECE", "COMPTE"],
        how="left",
    )
    merged["DIFF"] = (merged["AMTCUR_0"] - merged["MONTANT"]).round(2)
    desequilibres = merged[merged["DIFF"].abs() >= TOLERANCE_ECART]
    if not desequilibres.empty:
        logger.error(f"DÉSÉQUILIBRE DÉTECTÉ sur {len(desequilibres)} compte(s) X3 vs AGIRH")
    else:
        logger.info("[OK] Équilibre strict vérifié pour tous les comptes ODP.")


def _empty_result() -> pd.DataFrame:
    """Retourne un DataFrame vide avec le schéma attendu."""
    return pd.DataFrame(columns=BALANCE_COLUMNS)
