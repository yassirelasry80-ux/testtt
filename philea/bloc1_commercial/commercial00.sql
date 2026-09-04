SELECT 
    x.cusquoref_0,
    x.quosta_0, 
    x.sqhnum_0 AS devis,
    DECODE(LENGTH(x.bpcord_0), 6, SUBSTR(x.bpcord_0, 1, 1), SUBSTR(x.bpcord_0, 7, 1)) AS agence,
    x.quodat_0 AS date_dev,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,
    z.tsicod_0 AS FC,
    z.tsicod_1 AS FT,
    z.tsicod_2 AS FD,
    y.gropri_0 AS tarif,
    y.discrgval1_0 AS remise,
    y.qty_0 AS qte,
    (y.qty_0 * y.netpri_0) AS HTN,
    (y.qty_0 * y.gropri_0) AS HTB,
    y.ordflg_0,
    y.ordqty_0,
    SUBSTR(ysauv_clt_0, 2, 1) AS categ,
    (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs,
    y.sqdlin_0 AS ligne,
    (y.qty_0 * y.netpriati_0) AS TTCN,
    z.xbannis_0, 
    z.xbusline_0,
    z.xsbusline_0,
    z.xproduit_0  
FROM 
    squote x,
    squoted y,
    itmmaster z,
    bpcustomer r 
WHERE 
    r.bpcnum_0 = x.bpcord_0 
    AND z.itmref_0 = y.itmref_0 
    AND x.sqhnum_0 = y.sqhnum_0 
    AND x.quodat_0 BETWEEN '01/01/2026' AND '31/12/2026'