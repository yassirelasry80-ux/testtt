SELECT DISTINCT 
    e.tclcod_0 AS categ_art,
    e.tsicod_0 AS FC,
    e.tsicod_1 AS FT,
    e.tsicod_2 AS FD,
    e.itmref_0 AS article,
    e.des1axx_0 AS lib_article,
    NVL(
        (SELECT t.baspri_0 FROM itmsales t WHERE t.itmref_0 = e.itmref_0), 
        0
    ) AS tarif,
    e.vacitm_0 AS regime,
    (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = e.itmref_0) AS art_frs,
    (SELECT tt.bpsnam_0 FROM bpsupplier tt WHERE tt.bpsnum_0 = (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = e.itmref_0)) AS lib_frs,
    1 AS art_typ,
    NVL(
        (SELECT dernier_prix_achat_year(itmref_0, 2023) FROM dual), 
        NVL(
            (SELECT ROUND(prix, 2) FROM SYNTHESE_PR_PROD WHERE code = e.itmref_0), 
            0
        )
    ) AS dernier_prix_achat,
    XBUSLINE_0,
    xsbusline_0 
FROM 
    itmmaster e