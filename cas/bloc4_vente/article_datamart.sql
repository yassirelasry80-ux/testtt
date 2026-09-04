SELECT DISTINCT
    e.tclcod_0 AS categ_art,
    e.tsicod_0 AS FC,
    e.tsicod_1 AS FT,
    e.tsicod_2 AS FD,
    e.itmref_0 AS article,
    e.des1axx_0 AS lib_article,
    NVL((SELECT t.baspri_0 FROM itmsales t WHERE t.itmref_0 = e.itmref_0), 0) AS tarif,
    e.vacitm_0 AS regime,
    NVL(
        (SELECT dca.fourn_name FROM datamart_commande_achat dca WHERE dca.article = e.itmref_0 AND ROWNUM = 1),
        (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = e.itmref_0)
    ) AS art_frs,
    NVL(
        (SELECT dca.fourn_name FROM datamart_commande_achat dca WHERE dca.article = e.itmref_0 AND ROWNUM = 1),
        (SELECT tt.bpsnam_0 FROM bpsupplier tt WHERE tt.bpsnum_0 = (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = e.itmref_0))
    ) AS lib_frs,
    e.xtype_0 AS art_typ,
    NVL(
        (SELECT dernier_prix_achat_year(e.itmref_0, 2025) FROM dual),
        NVL(
            (SELECT ROUND(prix, 2) FROM SYNTHESE_PR_PROD WHERE code = e.itmref_0),
            e.xprixrev_0
        )
    ) AS dernier_prix_achat,
    e.xva_0,
    e.cce_0 AS XBUSLINE_0,
    e.cce_0 AS xsbusline_0
FROM itmmaster e