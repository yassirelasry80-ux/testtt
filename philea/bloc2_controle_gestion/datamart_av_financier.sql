SELECT
    kk.bpr_0 tiers,
    kk.accdat_0 periode,
    SUBSTR(kk.bpr_0,2,1) categ,
    DECODE(SUBSTR(kk.bpr_0,1,1),
        'X','C',
        'Y','C',
        'Z','C',
        SUBSTR(kk.bpr_0,1,1)
    ) agence,
    kk.num_0,
    kk.amtnot_0 HT,
    kk.amtati_0 TTC,
    ' ' xclasse
FROM sinvoice kk
WHERE kk.accdat_0 BETWEEN
        TO_DATE('01/01/2017','DD/MM/YYYY')
    AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND kk.num_0 LIKE 'AF%'