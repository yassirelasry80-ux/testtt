SELECT
    x.cusquoref_0,
    x.quosta_0,
    x.sqhnum_0 AS devis,
    CASE 
        WHEN LENGTH(x.bpcord_0) = 6 THEN SUBSTR(x.bpcord_0,1,1)
        ELSE SUBSTR(x.bpcord_0,7,1)
    END AS agence,
    x.quodat_0 AS date_dev,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,
    z.tsicod_0 AS FC,
    z.tsicod_1 AS FT,
    z.tsicod_2 AS FD,
    z.xfc_0 AS FCMKT,
    z.xfclib_0 AS FCLIBMKT,
    z.xfT_0 AS FTMKT,
    z.xfTlib_0 AS FTLIBMKT,
    z.xfD_0 AS FDMKT,
    z.xfDlib_0 AS FDLIBMKT,
    y.gropri_0 AS tarif,
    y.qty_0 AS qte,
    (y.qty_0 * y.netpri_0) AS HTN,
    (y.qty_0 * y.gropri_0) AS HTB,
    y.ordflg_0,
    y.ordqty_0,
    SUBSTR(r.ysauv_clt_0,2,1) AS categ,
    u.max_bpsnum AS frs,
    y.sqdlin_0 AS ligne,
    (y.qty_0 * y.netpriati_0) AS TTCN,
    z.xbusline_0
FROM squote x
JOIN squoted y ON x.sqhnum_0 = y.sqhnum_0
JOIN itmmaster z ON z.itmref_0 = y.itmref_0
JOIN bpcustomer r ON r.bpcnum_0 = x.bpcord_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS max_bpsnum
    FROM itmbps
    GROUP BY itmref_0
) u ON u.itmref_0 = y.itmref_0
WHERE x.quodat_0 BETWEEN DATE '2019-01-01' AND DATE '2026-12-31'
  AND y.bpcord_0 LIKE '_U%';