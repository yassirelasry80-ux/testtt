SELECT 
    kk.bpr_0 AS tiers,
    kk.accdat_0 AS periode,
    SUBSTR(kk.bpr_0, 2, 1) AS categ,
    y.rep_0 AS agence,
    kk.amtnot_0 AS HT,
    kk.amtati_0 AS TTC
FROM sinvoice kk
LEFT JOIN bpcustomer y 
    ON y.bpcnum_0 = kk.bpr_0
WHERE kk.accdat_0 BETWEEN 
      TO_DATE('01/01/2019','DD/MM/YYYY') 
  AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND kk.num_0 LIKE 'AF%'