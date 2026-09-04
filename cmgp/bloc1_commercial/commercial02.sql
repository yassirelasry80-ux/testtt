SELECT 
    x.sdhnum_0 AS bl,
    decode(length(x.bpcord_0),6,substr(x.bpcord_0,1,1),substr(x.bpcord_0,7,1)) AS agence,
    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS article,
    y.itmdes1_0 AS lib_art_bl,
    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,

    CASE 
        WHEN y.itmref_0 LIKE 'RA02%' THEN 'RA01'
        ELSE y.tsicod_2
    END AS FD,

    xfc_0 as FCMKT, xfclib_0 as FCLIBMKT, xft_0 as FTMKT, xftlib_0 as FTLIBMKT, xfd_0 as FDMKT, xfdlib_0 as FDLIBMKT,

    y.gropri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS tarif,
    y.qty_0 AS qte,

    y.qty_0 * y.netpri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS HTN,
    y.qty_0 * y.gropri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS HTB,

    substr(ysauv_clt_0,2,1) AS categ,

    (SELECT MAX(uu.bpsnum_0)
     FROM itmbps uu
     WHERE uu.itmref_0 = y.itmref_0) AS frs,

    y.sddlin_0 AS ligne,

    y.qty_0 * y.netpriati_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS TTCN,

    y.sohnum_0,
    y.soplin_0,
    TO_CHAR(y.soqseq_0) AS soqseq_0,

    0 AS lignebl,
    t.xbusline_0,

    CASE 
        WHEN x.sdhnum_0 LIKE 'B%' THEN (
            SELECT MAX(xdevis_0)
            FROM sorder
            WHERE sohnum_0 = (
                SELECT sohnum_0
                FROM sdeliveryd
                WHERE sdhnum_0 = x.sdhnum_0
                  AND sddlin_0 = y.sddlin_0
            )
        )

        WHEN x.sdhnum_0 LIKE 'RV%' THEN (
            SELECT MAX(xdevis_0)
            FROM sorder
            WHERE sohnum_0 IN (
                SELECT sohnum_0
                FROM sdeliveryd
                WHERE sdhnum_0 IN (
                    SELECT sdhnum_0
                    FROM sreturnd
                    WHERE srhnum_0 = x.sdhnum_0
                      AND srdlin_0 = y.sddlin_0
                )
            )
        )
    END AS xdev

FROM sdelivery x
JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
JOIN itmmaster t ON t.itmref_0 = y.itmref_0
JOIN bpcustomer r ON r.bpcnum_0 = x.bpcord_0

WHERE x.sdhnum_0 LIKE 'B%'
AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')


UNION ALL


SELECT 
    xx.srhnum_0,
    decode(length(xx.bpcord_0),6,substr(xx.bpcord_0,1,1),substr(xx.bpcord_0,7,1)),
    xx.rtndat_0,
    xx.bpcord_0,
    yy.itmref_0,
    yy.itmdes1_0,
    t.tsicod_0,
    t.tsicod_1,

    CASE 
        WHEN yy.itmref_0 LIKE 'RA02%' THEN 'RA01'
        ELSE t.tsicod_2
    END,

    xfc_0, xfclib_0, xft_0, xftlib_0, xfd_0, xfdlib_0,

    yy.netpri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1),

    yy.qty_0 * -1,

    (yy.qty_0 * yy.netpri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) * -1,

    (yy.qty_0 * yy.netpri_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) * -1,

    substr(ysauv_clt_0,2,1),

    (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = yy.itmref_0),

    yy.srdlin_0,

    (yy.qty_0 * yy.netpriati_0 * decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) * -1,

    yy.sdhnum_0,
    yy.sddlin_0,
    '0',
    0,
    xbusline_0,

    CASE 
        WHEN xx.srhnum_0 LIKE 'RV%' THEN (
            SELECT MAX(xdevis_0)
            FROM sorder
            WHERE sohnum_0 IN (
                SELECT sohnum_0
                FROM sdeliveryd
                WHERE sdhnum_0 IN (
                    SELECT sdhnum_0
                    FROM sreturnd
                    WHERE srhnum_0 = xx.srhnum_0
                      AND srdlin_0 = yy.srdlin_0
                )
            )
        )
    END

FROM sreturn xx
JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
JOIN itmmaster t ON t.itmref_0 = yy.itmref_0
JOIN bpcustomer r ON r.bpcnum_0 = xx.bpcord_0

WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2019','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
AND substr(xx.srhnum_0,1,2) IN ('RV','RP')


UNION ALL


SELECT 
    x.num_0,
    decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)),
    x.accdat_0,
    x.bpr_0,
    y.itmref_0,
    y.itmdes1_0,
    y.tsicod_0,
    y.tsicod_1,

    CASE 
        WHEN y.itmref_0 LIKE 'RA02%' THEN 'RA01'
        ELSE t.tsicod_2
    END,

    xfc_0, xfclib_0, xft_0, xftlib_0, xfd_0, xfdlib_0,

    y.gropri_0 * ratmlt_0,

    decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1),

    decode(substr(x.gte_0,1,1),'F',y.qty_0*y.netpri_0*ratmlt_0,
                                      y.qty_0*y.netpri_0*ratmlt_0*-1),

    decode(substr(x.gte_0,1,1),'F',y.qty_0*y.gropri_0*ratmlt_0,
                                      y.qty_0*y.gropri_0*ratmlt_0*-1),

    (SELECT substr(ysauv_clt_0,2,1) FROM bpcustomer WHERE bpcnum_0 = x.bpr_0),

    (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0),

    y.sidlin_0,

    decode(substr(x.gte_0,1,1),'F',y.qty_0*y.netpriati_0*ratmlt_0,
                                      y.qty_0*y.netpriati_0*ratmlt_0*-1),

    y.sdhnum_0,
    y.sddlin_0,
    y.srhnum_0,
    y.srdlin_0,
    xbusline_0,

    NULL

FROM sinvoice x
JOIN sinvoiced y ON x.num_0 = y.num_0
JOIN itmmaster t ON t.itmref_0 = y.itmref_0

WHERE x.accdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
AND ((substr(x.num_0,1,1) IN ('F','P') AND y.sdhnum_0 = ' ')
  OR (substr(x.num_0,1,1) = 'A' AND y.srhnum_0 = ' '))
AND substr(x.num_0,1,2) NOT LIKE 'AF%'