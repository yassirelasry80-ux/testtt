SELECT 
    kk.bpr_0        AS tiers,
    kk.accdat_0     AS periode,
    SUBSTR(kk.bpr_0, 2, 1) AS categ,

    DECODE(
        SUBSTR(kk.bpr_0, 1, 1),
        'X', 'C',
        'Y', 'C',
        'Z', 'C',
        SUBSTR(kk.bpr_0, 1, 1)
    ) AS agence,

    kk.num_0        AS num_0,
    kk.amtnot_0     AS HT,
    kk.amtati_0     AS TTC,

    (
        SELECT f.xclasse_0
        FROM bpcustomer f
        WHERE f.bpcnum_0 = kk.bpr_0
    ) AS xclasse

FROM sinvoice kk

WHERE kk.accdat_0  BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND kk.num_0 LIKE 'AF%'