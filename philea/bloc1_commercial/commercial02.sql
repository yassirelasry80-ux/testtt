SELECT 
    x.sdhnum_0 AS bl,
    sddlin_0 AS lin,

    DECODE(
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = x.bpcord_0),
        ' ',
        'AUTRES',
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = x.bpcord_0)
    ) AS agence,

    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,

    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,
    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,

    ' ' AS FCMKT,
    ' ' AS FCLIBMKT,
    ' ' AS FTMKT,
    ' ' AS FTLIBMKT,
    ' ' AS FDMKT,
    ' ' AS FDLIBMKT,

    y.gropri_0 AS tarif,
    y.qty_0 AS qte,

    (y.qty_0 * y.netpri_0) AS HTN,
    (y.qty_0 * y.netpriati_0) AS TTCN,
    (y.qty_0 * y.gropri_0) AS HTB,

    (SELECT SUBSTR(ysauv_clt_0, 2, 1) 
     FROM bpcustomer 
     WHERE bpcnum_0 = x.bpcord_0) AS categ

FROM 
    sdelivery x,
    sdeliveryd y

WHERE 
    x.sdhnum_0 = y.sdhnum_0
    AND x.sdhnum_0 LIKE 'B%'
    AND x.dlvdat_0 BETWEEN 
        TO_DATE('01/01/2019', 'DD/MM/YYYY')
        AND TO_DATE('31/12/2026', 'DD/MM/YYYY')

UNION

SELECT 
    xx.srhnum_0 AS numret,
    srdlin_0 AS lin,

    DECODE(
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = xx.bpcord_0),
        ' ',
        'AUTRES',
        (SELECT rep_0 
         FROM bpcustomer y 
         WHERE y.bpcnum_0 = xx.bpcord_0)
    ) AS agence,

    xx.rtndat_0,
    xx.bpcord_0,

    yy.itmref_0,
    yy.itmdes1_0,

    (SELECT tt.tsicod_0 
     FROM itmmaster tt 
     WHERE tt.itmref_0 = yy.itmref_0) AS FC,

    (SELECT tt.tsicod_1 
     FROM itmmaster tt 
     WHERE tt.itmref_0 = yy.itmref_0) AS FT,

    (SELECT tt.tsicod_2 
     FROM itmmaster tt 
     WHERE tt.itmref_0 = yy.itmref_0) AS FD,

    ' ' AS FCMKT,
    ' ' AS FCLIBMKT,
    ' ' AS FTMKT,
    ' ' AS FTLIBMKT,
    ' ' AS FDMKT,
    ' ' AS FDLIBMKT,

    yy.netpri_0,
    yy.qty_0 * -1,

    (yy.qty_0 * yy.netpri_0) * -1 AS HTN,
    (yy.qty_0 * yy.netpriati_0) * -1 AS TTCN,
    (yy.qty_0 * yy.netpri_0) * -1 AS HTB,

    (SELECT SUBSTR(ysauv_clt_0, 2, 1) 
     FROM bpcustomer 
     WHERE bpcnum_0 = xx.bpcord_0) AS categ

FROM 
    sreturn xx,
    sreturnd yy

WHERE 
    xx.srhnum_0 = yy.srhnum_0
    AND xx.rtndat_0 BETWEEN  TO_DATE('01/01/2019', 'DD/MM/YYYY')AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
    AND xx.srhnum_0 LIKE 'RV%'