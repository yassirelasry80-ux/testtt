SELECT 
    x.num_0 AS fac,
    DECODE(
        SUBSTR(x.bpr_0, 1, 1), 
        'X', 'C', 
        'Y', 'C', 
        'Z', 'C', 
        SUBSTR(x.bpr_0, 1, 1)
    ) AS agence,
    x.accdat_0 AS date_fac,
    x.bpr_0 AS tiers,
    y.itmref_0 AS article,
    y.itmdes1_0 AS lib_art_fac,
    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,
    (SELECT t.tsicod_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCMKT,
    (SELECT ' ' FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCLIBMKT,
    (SELECT t.tsicod_1 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTMKT,
    (SELECT ' ' FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTLIBMKT,
    (SELECT t.tsicod_2 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDMKT,
    (SELECT ' ' FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDLIBMKT,
    y.gropri_0 AS tarif,
    DECODE(
        x.gte_0, 
        'FAC', y.qty_0, 
        'FCP', y.qty_0, 
        'AVC', y.qty_0 * -1, 
        'AVP', y.qty_0 * -1, 
        'AFV', y.qty_0 * -1
    ) AS qte,
    DECODE(
        x.gte_0, 
        'FAC', (y.qty_0 * y.netpri_0), 
        'FCP', (y.qty_0 * y.netpri_0), 
        'AVC', (y.qty_0 * y.netpri_0) * -1, 
        'AVP', (y.qty_0 * y.netpri_0) * -1, 
        'AFV', (y.qty_0 * y.netpri_0) * -1
    ) AS HTN,
    DECODE(
        x.gte_0, 
        'FAC', (y.qty_0 * y.gropri_0), 
        'FCP', (y.qty_0 * y.gropri_0), 
        'AVC', (y.qty_0 * y.gropri_0) * -1, 
        'AVP', (y.qty_0 * y.gropri_0) * -1, 
        'AFV', (y.qty_0 * y.gropri_0) * -1
    ) AS HTB,
    SUBSTR(x.bpr_0, 2, 1) AS categ,
    (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs,
    DECODE(
        x.gte_0, 
        'FAC', (y.qty_0 * y.netpriati_0), 
        'FCP', (y.qty_0 * y.netpriati_0), 
        'AVC', (y.qty_0 * y.netpriati_0) * -1, 
        'AVP', (y.qty_0 * y.netpriati_0) * -1, 
        'AFV', (y.qty_0 * y.netpriati_0) * -1
    ) AS TTCN
FROM 
    sinvoice x,
    sinvoiced y 
WHERE 
    x.num_0 = y.num_0  
    AND x.accdat_0 BETWEEN '01/01/2017' AND '31/12/2026'