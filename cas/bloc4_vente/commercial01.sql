SELECT 
    a.sohnum_0 cde,
    DECODE(LENGTH(a.bpcord_0), 6, SUBSTR(a.bpcord_0, 1, 1), SUBSTR(a.bpcord_0, 7, 1)) agence,
    a.orddat_0 date_BC, 
    a.bpcord_0 tiers,
    b.itmref_0 Article,
    b.itmdes1_0 lib_art_cde,
    b.tsicod_0 FC,
    b.tsicod_1 FT,
    b.tsicod_2 FD,
    ' ' FCMKT,
    ' ' FCLIBMKT,
    ' ' FTMKT,
    ' ' FTLIBMKT,
    ' ' FDMKT,
    ' ' as xfDlib_0, 
    ' ' FDLIBMKT,
    b.gropri_0 * DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1) tarif,
    c.qty_0 qte,
    (c.qty_0 * b.netpri_0 * DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1)) HTN,
    (c.qty_0 * b.gropri_0 * DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1)) HTB,
    SUBSTR(r.ysauv_clt_0, 2, 1) categ,
    frs.bpsnum_0 frs,
    b.soplin_0,
    b.sopseq_0,
    b.sqhnum_0,
    b.sqdlin_0,
    c.dlvqty_0,
    t.xbusline_0,
    CASE WHEN b.SOQSTA_0 = 3 THEN 'Oui' ELSE 'Non' END solde 
FROM sorder a
JOIN sorderp b ON a.sohnum_0 = b.sohnum_0
JOIN sorderq c ON b.sohnum_0 = c.sohnum_0 AND b.soplin_0 = c.soplin_0
JOIN itmmaster t ON t.itmref_0 = b.itmref_0
JOIN bpcustomer r ON r.bpcnum_0 = a.bpcord_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0 
    FROM itmbps 
    GROUP BY itmref_0
) frs ON frs.itmref_0 = b.itmref_0
WHERE a.sohnum_0 LIKE 'C%' 
  AND a.orddat_0 BETWEEN TO_DATE('01/01/2020', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')