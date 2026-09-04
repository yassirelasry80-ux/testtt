SELECT
    x.cusquoref_0,
    x.quosta_0,
    x.sqhnum_0 AS devis,

    CASE
        WHEN LENGTH(x.bpcord_0) = 6
             THEN SUBSTR(x.bpcord_0,1,1)
        ELSE SUBSTR(x.bpcord_0,7,1)
    END AS agence,

    x.quodat_0 AS date_dev,
    x.bpcord_0 AS tiers,

    y.itmref_0 AS article,
    y.itmdes1_0 AS lib_art_bl,

    z.tsicod_0 AS fc,
    z.tsicod_1 AS ft,
    z.tsicod_2 AS fd,

    z.xfc_0 AS fcmkt,
    z.xfclib_0 AS fclibmkt,

    z.xft_0 AS ftmkt,
    z.xftlib_0 AS ftlibmkt,

    z.xfd_0 AS fdmkt,
    z.xfdlib_0 AS fdlibmkt,

    y.gropri_0 AS tarif,
    y.qty_0 AS qte,

    (y.qty_0 * y.netpri_0) AS htn,
    (y.qty_0 * y.gropri_0) AS htb,

    y.ordflg_0,
    y.ordqty_0,

    SUBSTR(r.ysauv_clt_0,2,1) AS categ,

    u.max_bpsnum AS frs,

    y.sqdlin_0 AS ligne,

    (y.qty_0 * y.netpriati_0) AS ttcn,

    z.xbusline_0

FROM squote x

INNER JOIN squoted y
       ON y.sqhnum_0 = x.sqhnum_0

INNER JOIN itmmaster z
       ON z.itmref_0 = y.itmref_0

INNER JOIN bpcustomer r
       ON r.bpcnum_0 = x.bpcord_0

LEFT JOIN (
        SELECT /*+ MATERIALIZE */
               itmref_0,
               MAX(bpsnum_0) AS max_bpsnum
        FROM itmbps
        GROUP BY itmref_0
) u
ON u.itmref_0 = y.itmref_0

WHERE x.quodat_0 >= DATE '2019-01-01'
  AND x.quodat_0 <  DATE '2027-01-01'
  AND y.bpcord_0 LIKE '_U%'