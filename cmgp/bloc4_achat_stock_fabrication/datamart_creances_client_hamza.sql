SELECT
    a.num_0,
    a.sta_0,
    a.accdat_0 AS dat,
    b.mtc_0,
    a.jou_0,
    b.acc_0,
    SUBSTR(b.acc_0, 1, 4) AS racine,
    b.bpr_0 AS tiers,
    c.bpcnam_0 AS nomclt,
    e.mntreg,
    SUBSTR(b.bpr_0, 2, 1) AS categ,
    b.sns_0 * b.amtled_0 AS mnt,
    a.duddat_0 AS date_ech,
    b.des_0
FROM gaccentry a
JOIN gaccentryd b
    ON a.num_0 = b.num_0
   AND a.typ_0 = b.typ_0
LEFT JOIN bpcustomer c
    ON c.bpcnum_0 = b.bpr_0
LEFT JOIN (
    SELECT num_0, bpr_0, lig_0,
           SUM(payloc_0 * sns_0) AS mntreg
    FROM gaccdudate
    GROUP BY num_0, bpr_0, lig_0
) e
    ON e.num_0 = b.num_0
   AND e.bpr_0 = b.bpr_0
   AND e.lig_0 = b.lin_0
WHERE a.accdat_0 BETWEEN TO_DATE('01/01/2008','DD/MM/YYYY') AND SYSDATE
  AND SUBSTR(b.acc_0, 1, 4) IN ('3425','3426','3424','3421','3427','3428','3429')
  AND SUBSTR(b.mtc_0,1,1) NOT BETWEEN 'A' AND 'Z'
  AND b.bpr_0 <> 'ZZZZ'
  AND SUBSTR(b.bpr_0,2,1) <> 'L'
  AND a.typ_0 NOT IN ('RAN','AN')
ORDER BY b.bpr_0, b.mtc_0