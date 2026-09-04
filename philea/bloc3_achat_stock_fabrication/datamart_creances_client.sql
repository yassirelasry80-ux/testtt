SELECT
    a.num_0,
    a.sta_0,
    a.accdat_0 AS dat,
    b.mtc_0,
    a.jou_0,
    b.acc_0,
    SUBSTR(b.acc_0,1,4) AS racine,
    b.bpr_0 AS tiers,
    (
        SELECT c.bpcnam_0
        FROM bpcustomer c
        WHERE c.bpcnum_0 = b.bpr_0
    ) AS nomclt,
    SUBSTR(b.bpr_0,2,1) AS categ,
    b.sns_0 * b.amtled_0 AS mnt,
    a.duddat_0 AS date_ech,
    b.des_0
FROM gaccentry a
JOIN gaccentryd b
    ON a.typ_0 = b.typ_0
   AND a.num_0 = b.num_0
WHERE a.accdat_0 BETWEEN TO_DATE('01/01/2008','DD/MM/YYYY')
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND SUBSTR(b.acc_0,1,4) IN ('3425','3426','3424','3421','3427','3428','3429')
  AND (b.mtc_0 = ' ' OR (b.mtc_0 >= 'a' AND b.mtc_0 <= 'z'))
  AND b.bpr_0 <> 'ZZZZ'
  AND a.typ_0 NOT IN ('RAN','AN')
  AND b.ledtyp_0 = 1
ORDER BY b.bpr_0, b.mtc_0