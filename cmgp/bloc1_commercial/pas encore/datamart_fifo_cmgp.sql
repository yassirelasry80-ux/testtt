SELECT
    ff.mois,
    ff.itmref_0,
    ff.prixrev,
    SUM(ff.qte) AS qte
FROM datamart_mvt_cmgp ff
GROUP BY
    ff.mois,
    ff.itmref_0,
    ff.prixrev