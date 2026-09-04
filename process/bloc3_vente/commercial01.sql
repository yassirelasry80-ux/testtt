SELECT 
    a.sohnum_0 AS cde,
    SUBSTR(a.salfcy_0, 1, 1) AS agence,
    a.orddat_0 AS date_BC,
    a.bpcord_0 AS tiers,
    b.itmref_0 AS Article,
    b.itmdes1_0 AS lib_art_cde,
    b.tsicod_0 AS FC,
    b.tsicod_1 AS FT,
    b.tsicod_2 AS FD,
    t.tsicod_0 AS FCMKT,
    ' ' AS FCLIBMKT,
    t.tsicod_1 AS FTMKT,
    ' ' AS FTLIBMKT,
    t.tsicod_2 AS FDMKT,
    ' ' AS FDLIBMKT,
    b.gropri_0 AS tarif,
    c.qty_0 AS qte,
    (c.qty_0 * b.netpri_0) AS HTN,
    (c.qty_0 * b.gropri_0) AS HTB,
    SUBSTR(a.bpcord_0, 2, 1) AS categ,
    bp.bpsnum_0 AS frs
FROM sorder a
JOIN sorderp b 
    ON a.sohnum_0 = b.sohnum_0
JOIN sorderq c 
    ON a.sohnum_0 = c.sohnum_0 
    AND b.soplin_0 = c.soplin_0
LEFT JOIN itmmaster t 
    ON t.itmref_0 = b.itmref_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
) bp 
    ON bp.itmref_0 = b.itmref_0
WHERE a.sohnum_0 LIKE 'C%'
  AND a.orddat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')