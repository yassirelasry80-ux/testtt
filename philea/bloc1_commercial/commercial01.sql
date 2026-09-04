SELECT 
    a.sohnum_0 AS cde,

    DECODE(
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = a.bpcord_0),
        ' ',
        'AUTRES',
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = a.bpcord_0)
    ) AS agence,

    a.orddat_0 AS date_BC,
    a.bpcord_0 AS tiers,

    b.itmref_0 AS Article,
    b.itmdes1_0 AS lib_art_cde,
    b.tsicod_0 AS FC,
    b.tsicod_1 AS FT,
    b.tsicod_2 AS FD,

    ' ' AS FCMKT,
    ' ' AS FCLIBMKT,
    ' ' AS FTMKT,
    ' ' AS FTLIBMKT,
    ' ' AS FDMKT,
    ' ' AS FDLIBMKT,

    b.gropri_0 AS tarif,
    c.qty_0 AS qte,
    c.dlvqty_0 AS qte_livrer,

    (c.qty_0 * b.netpri_0) AS HTN,
    (c.qty_0 * b.gropri_0) AS HTB,

    (SELECT SUBSTR(ysauv_clt_0, 2, 1) 
     FROM bpcustomer 
     WHERE bpcnum_0 = a.bpcord_0) AS categ

FROM 
    sorder a,
    sorderp b,
    sorderq c

WHERE 
    a.sohnum_0 = b.sohnum_0
    AND a.sohnum_0 = c.sohnum_0
    AND b.soplin_0 = c.soplin_0

    AND a.sohnum_0 LIKE 'C%'

    AND a.orddat_0 BETWEEN 
        TO_DATE('01/01/2019', 'DD/MM/YYYY')
        AND TO_DATE('31/12/2026', 'DD/MM/YYYY')