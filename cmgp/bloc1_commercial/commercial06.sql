SELECT 
    kk.bpr_0 AS tiers,
    kk.accdat_0 AS periode,
    SUBSTR(kk.bpr_0, 1, 2) AS categ,
    DECODE(
        LENGTH(kk.bpr_0),
        6, SUBSTR(kk.bpr_0, 1, 1),
        SUBSTR(kk.bpr_0, 7, 1)
    ) AS agence,
    kk.amtnotl_0 AS HT,
    kk.amtatil_0 AS TTC
FROM sinvoice kk
WHERE  kk.accdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND kk.num_0 LIKE 'AF%'