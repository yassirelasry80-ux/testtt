SELECT * 
FROM (
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
        e.mntreg AS mntreg, 
        SUBSTR(b.bpr_0, 2, 1) AS categ,
        (b.sns_0 * b.amtled_0) AS mnt,
        CASE 
            WHEN a.jou_0 = 'VT' THEN (a.accdat_0 + c.xdrecouvr_0) 
            ELSE a.duddat_0 
        END AS date_ech,
        b.des_0,
        CASE 
            WHEN b.accnum_0 <> 0 THEN (b.sns_0 * b.amtled_0) - (NVL(f.tot_payloc, 0) * b.sns_0)
            ELSE 0
        END AS solde,
        b.sns_0,
        b.accnum_0,
        CASE 
            WHEN a.num_0 LIKE '%IMP%' THEN 1 
            ELSE 0 
        END AS impaye
    FROM gaccentry a
    INNER JOIN gaccentryd b 
        ON a.typ_0 = b.typ_0 
       AND a.num_0 = b.num_0
    LEFT JOIN bpcustomer c 
        ON c.bpcnum_0 = b.bpr_0
    LEFT JOIN (
        SELECT num_0, bpr_0, lig_0, SUM(payloc_0 * sns_0) AS mntreg
        FROM gaccdudate
        GROUP BY num_0, bpr_0, lig_0
    ) e 
        ON e.num_0 = b.num_0 
       AND e.bpr_0 = b.bpr_0 
       AND e.lig_0 = b.lin_0
    LEFT JOIN (
        SELECT accnum_0, SUM(payloc_0) AS tot_payloc
        FROM gaccdudate
        GROUP BY accnum_0
    ) f
        ON f.accnum_0 = b.accnum_0
    WHERE a.accdat_0 BETWEEN TO_DATE('01/01/2008', 'DD/MM/YYYY') AND SYSDATE
      AND SUBSTR(b.acc_0, 1, 4) IN ('3425', '3426', '3424', '3421', '3427', '3428', '3429')
      AND (b.mtc_0 = ' ' OR b.mtc_0 BETWEEN 'a' AND 'z')
      AND b.bpr_0 <> 'ZZZZ'
      AND a.typ_0 NOT IN ('RAN', 'AN')
)
WHERE mnt - mntreg <> 0