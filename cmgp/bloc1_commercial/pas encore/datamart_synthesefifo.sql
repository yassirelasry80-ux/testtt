SELECT
    itmref_0,
    mois,
    prixrev,
    SUM(qte)  AS qte,
    0         AS montant,
    0         AS qtetraiter,
    0         AS prix_rec
FROM datamart_fifo_cmgp
WHERE mois BETWEEN :date_debut AND :date_fin
GROUP BY
    mois,
    itmref_0,
    prixrev
ORDER BY
    mois,
    itmref_0