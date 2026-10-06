"""
transform.py — Ventilation analytique de paie (ODP vs AGIRH) et standardisation.
"""

import logging
from typing import List, Dict, Any
import pandas as pd

logger = logging.getLogger(__name__)

COMMUN = "00000000"
TOLERANCE_ECART = 0.005

BALANCE_COLUMNS = [
    "NUM_PIECE", "COMPTE", "SENS", "AXE_CENTRE", "AXE_ENTITE",
    "AXE_BLINE", "AXE_SITE", "MONTANT", "TIERS_CODE", "ARTICLE_CODE",
    "DATE_COMPTABLE", "SOURCE", "TYPE_LIGNE",
]


def standardize_balance_df(df: pd.DataFrame, default_source: str = None) -> pd.DataFrame:
    """Valide et standardise le DataFrame pour balance_analytique de façon vectorisée."""
    if df is None or df.empty:
        return pd.DataFrame(columns=BALANCE_COLUMNS)

    df_out = df.copy()
    df_out.columns = [str(c).strip().upper() for c in df_out.columns]

    for col in BALANCE_COLUMNS:
        if col not in df_out.columns:
            df_out[col] = None

    df_out = df_out[BALANCE_COLUMNS]
    df_out["NUM_PIECE"] = df_out["NUM_PIECE"].astype(str).str.strip()
    df_out["COMPTE"] = df_out["COMPTE"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_out["SENS"] = pd.to_numeric(df_out["SENS"], errors="coerce").fillna(1).astype(int)
    df_out["MONTANT"] = pd.to_numeric(df_out["MONTANT"], errors="coerce").fillna(0.0).round(2)
    df_out["DATE_COMPTABLE"] = pd.to_datetime(df_out["DATE_COMPTABLE"], errors="coerce")
    df_out["SOURCE"] = df_out["SOURCE"].fillna(default_source or "INCONNU")
    df_out["TYPE_LIGNE"] = df_out["TYPE_LIGNE"].fillna("DETAIL")

    return df_out


def transform_odp_agirh(df_x3: pd.DataFrame, df_agirh: pd.DataFrame) -> pd.DataFrame:
    """Rapprochement X3 ODP vs AGIRH mois par mois avec équilibrage strict."""
    if df_x3 is None or df_x3.empty:
        return pd.DataFrame(columns=BALANCE_COLUMNS)

    df_x3 = df_x3.copy()
    df_agirh = df_agirh.copy() if df_agirh is not None else pd.DataFrame()

    df_x3["ACC_0"] = df_x3["ACC_0"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
    df_x3["_mois"] = df_x3["ACCDAT_0"].dt.to_period("M")

    if not df_agirh.empty:
        df_agirh["CODE_interne"] = df_agirh["CODE_interne"].astype(str).str.strip().str.replace(r"\.0$", "", regex=True)
        df_agirh["_mois"] = pd.to_datetime(df_agirh["DT_COMPTA"]).dt.to_period("M")

    results: List[Dict[str, Any]] = []

    for mois in sorted(df_x3["_mois"].unique()):
        x3_m = df_x3[df_x3["_mois"] == mois]
        ag_m = df_agirh[df_agirh["_mois"] == mois] if not df_agirh.empty else pd.DataFrame()

        # Aggrégation directe par pièce et compte dans X3
        agg = x3_m.groupby(["NUM_0", "ACC_0"], as_index=False).agg(
            AMTCUR_0=("AMTCUR_0", "sum"),
            SNS_0=("SNS_0", "first"),
            ACCDAT_0=("ACCDAT_0", "first"),
        )

        for _, row in agg.iterrows():
            num_p, acc = row["NUM_0"], row["ACC_0"]
            mt_pere, sens, dt = row["AMTCUR_0"], int(row["SNS_0"]), row["ACCDAT_0"]
            fils = ag_m[ag_m["CODE_interne"] == acc] if not ag_m.empty else pd.DataFrame()

            if fils.empty:
                results.append(_row(num_p, acc, sens, COMMUN, COMMUN, COMMUN, round(mt_pere, 2), dt, "COMMUN_NON_VENTILE"))
            else:
                tot_ag = 0.0
                ste = str(fils.iloc[0].get("ste", COMMUN))
                for _, ag in fils.iterrows():
                    tot_ag += ag["mt"]
                    results.append(_row(
                        num_p, acc, sens,
                        str(ag.get("ETB", COMMUN)), ste, str(ag.get("CODE_AGENCE", COMMUN)),
                        round(ag["mt"], 2), dt, "DETAIL"
                    ))

                ecart = round(mt_pere - tot_ag, 2)
                if abs(ecart) >= TOLERANCE_ECART:
                    results.append(_row(num_p, acc, sens, COMMUN, ste, COMMUN, ecart, dt, "COMMUN_ECART"))

    df_res = pd.DataFrame(results)
    if df_res.empty:
        return pd.DataFrame(columns=BALANCE_COLUMNS)

    _verify_equilibre(df_x3, df_res)
    return standardize_balance_df(df_res, default_source="AGIRH")


def _row(num, acc, sens, centre, entite, site, mt, dt, typ) -> Dict[str, Any]:
    """Helper compact pour construire une ligne de balance."""
    return {
        "NUM_PIECE": num, "COMPTE": acc, "SENS": sens,
        "AXE_CENTRE": centre, "AXE_ENTITE": entite, "AXE_BLINE": COMMUN, "AXE_SITE": site,
        "MONTANT": mt, "TIERS_CODE": None, "ARTICLE_CODE": None,
        "DATE_COMPTABLE": dt, "SOURCE": "AGIRH", "TYPE_LIGNE": typ,
    }


def _verify_equilibre(df_x3: pd.DataFrame, df_res: pd.DataFrame) -> None:
    """Contrôle d'équilibre strict X3 vs résultat final."""
    t_x3 = df_x3.groupby(["NUM_0", "ACC_0"], as_index=False)["AMTCUR_0"].sum()
    t_res = df_res.groupby(["NUM_PIECE", "COMPTE"], as_index=False)["MONTANT"].sum()
    m = pd.merge(t_x3, t_res, left_on=["NUM_0", "ACC_0"], right_on=["NUM_PIECE", "COMPTE"], how="left")
    diffs = m[(m["AMTCUR_0"] - m["MONTANT"]).round(2).abs() >= TOLERANCE_ECART]
    if not diffs.empty:
        logger.warning(f"Déséquilibre sur {len(diffs)} compte(s) X3 vs AGIRH")
    else:
        logger.info("[OK] Équilibre strict vérifié pour tous les comptes ODP.")


def complement_with_moovapps(
    df_datamart: pd.DataFrame, df_moovapps: pd.DataFrame
) -> pd.DataFrame:
    """
    Pour chaque ligne du Datamart Analytique, si un champ est vide/NULL,
    le compléter avec la valeur correspondante de Moovapps (jointure LEFT par NUM_PIECE).

    - Colonnes texte (AXE_CENTRE, AXE_ENTITE, AXE_BLINE, AXE_SITE, COMPTE,
      TIERS_CODE, ARTICLE_CODE) : complétées si NULL ou chaîne vide.
    - Colonnes numériques (MONTANT, SENS) : complétées si NULL ou == 0.
    - DATE_COMPTABLE : complétée si NULL.
    """
    if df_datamart is None or df_datamart.empty:
        logger.warning("Datamart Analytique vide — rien à compléter.")
        return pd.DataFrame(columns=BALANCE_COLUMNS)

    df = df_datamart.copy()
    df.columns = [str(c).strip().upper() for c in df.columns]

    if df_moovapps is None or df_moovapps.empty:
        logger.info("Moovapps vide — aucun complément appliqué.")
        return df

    df_mv = df_moovapps.copy()
    df_mv.columns = [str(c).strip().upper() for c in df_mv.columns]

    # Normaliser NUM_PIECE dans les deux DataFrames
    df["NUM_PIECE"] = df["NUM_PIECE"].astype(str).str.strip()
    df_mv["NUM_PIECE"] = df_mv["NUM_PIECE"].astype(str).str.strip()

    # Dédupliquer Moovapps par NUM_PIECE (garder la première occurrence)
    df_mv = df_mv.drop_duplicates(subset="NUM_PIECE", keep="first")

    # LEFT JOIN sur NUM_PIECE
    suffixed = df.merge(df_mv, on="NUM_PIECE", how="left", suffixes=("", "_MV"))

    # Suivi des lignes enrichies par Moovapps
    enriched = pd.Series(False, index=suffixed.index)

    # Colonnes texte : compléter si NULL ou vide
    text_cols = [
        "AXE_CENTRE", "AXE_ENTITE", "AXE_BLINE", "AXE_SITE",
        "COMPTE", "TIERS_CODE", "ARTICLE_CODE",
    ]
    for col in text_cols:
        mv_col = f"{col}_MV"
        if mv_col in suffixed.columns:
            mask = suffixed[col].isnull() | (suffixed[col].astype(str).str.strip() == "")
            has_mv_value = mask & suffixed[mv_col].notna() & (suffixed[mv_col].astype(str).str.strip() != "")
            suffixed.loc[mask, col] = suffixed.loc[mask, mv_col]
            enriched = enriched | has_mv_value
            nb_filled = has_mv_value.sum()
            if nb_filled > 0:
                logger.info(f"  Complément Moovapps : {nb_filled} valeur(s) renseignée(s) pour {col}")

    # Colonnes numériques : compléter si NULL ou == 0
    num_cols = ["MONTANT", "SENS"]
    for col in num_cols:
        mv_col = f"{col}_MV"
        if mv_col in suffixed.columns:
            suffixed[col] = pd.to_numeric(suffixed[col], errors="coerce")
            suffixed[mv_col] = pd.to_numeric(suffixed[mv_col], errors="coerce")
            mask = suffixed[col].isnull() | (suffixed[col] == 0)
            has_mv_value = mask & suffixed[mv_col].notna() & (suffixed[mv_col] != 0)
            suffixed.loc[mask, col] = suffixed.loc[mask, mv_col]
            enriched = enriched | has_mv_value
            nb_filled = has_mv_value.sum()
            if nb_filled > 0:
                logger.info(f"  Complément Moovapps : {nb_filled} valeur(s) renseignée(s) pour {col}")

    # DATE_COMPTABLE : compléter si NULL
    if "DATE_COMPTABLE_MV" in suffixed.columns:
        mask = suffixed["DATE_COMPTABLE"].isnull()
        has_mv_value = mask & suffixed["DATE_COMPTABLE_MV"].notna()
        suffixed.loc[mask, "DATE_COMPTABLE"] = suffixed.loc[mask, "DATE_COMPTABLE_MV"]
        enriched = enriched | has_mv_value
        nb_filled = has_mv_value.sum()
        if nb_filled > 0:
            logger.info(f"  Complément Moovapps : {nb_filled} valeur(s) renseignée(s) pour DATE_COMPTABLE")

    # Marquer TYPE_LIGNE pour les lignes enrichies par Moovapps
    suffixed.loc[enriched, "TYPE_LIGNE"] = "DETAIL OD MOOVAPPS"
    logger.info(f"  {enriched.sum()} ligne(s) marquée(s) 'DETAIL OD MOOVAPPS'")

    # Supprimer les colonnes suffixées _MV
    mv_columns = [c for c in suffixed.columns if c.endswith("_MV")]
    suffixed.drop(columns=mv_columns, inplace=True)

    logger.info(f"Complément Moovapps terminé — {len(suffixed)} lignes résultantes.")
    return suffixed


transform = transform_odp_agirh
