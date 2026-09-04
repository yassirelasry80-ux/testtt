WITH commercial02_BL AS (
    SELECT 
        x.sdhnum_0 AS bl,
        SUBSTR(x.salfcy_0, 1, 1) AS agence,
        x.dlvdat_0 AS date_bl,
        x.bpcord_0 AS tiers,
        y.itmref_0 AS Article,
        y.itmdes1_0 AS Lib_art_bl,
        y.tsicod_0 AS FC,
        y.tsicod_1 AS FT,
        y.tsicod_2 AS FD,
        t.tsicod_0 AS FCMKT,
        ' ' AS FCLIBMKT,
        t.tsicod_1 AS FTMKT,
        ' ' AS FTLIBMKT,
        t.tsicod_2 AS FDMKT,
        ' ' AS FDLIBMKT,
        y.gropri_0 AS tarif,
        y.qty_0 AS qte,
        (y.qty_0 * (y.netprinot_0 * x.CHGRAT_0)) AS HTN,
        (y.qty_0 * (y.netprinot_0 * x.CHGRAT_0)) AS HTB,
        SUBSTR(x.bpcord_0, 2, 1) AS categ,
        uu.bpsnum_0 AS frs,
        y.sddlin_0 AS ligne,
        (y.qty_0 * (y.netpriati_0 * x.CHGRAT_0)) AS TTCN,
        CAST(NULL AS VARCHAR2(100)) AS xdev
    FROM sdelivery x
    JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
    LEFT JOIN itmmaster t ON t.itmref_0 = y.itmref_0
    LEFT JOIN (
        SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0 
        FROM itmbps 
        GROUP BY itmref_0
    ) uu ON uu.itmref_0 = y.itmref_0
    WHERE x.invflg_0 <> 2 
      AND x.betfcy_0 = 1 
      AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
      AND (y.qty_0 - y.rtnqty_0 > 0)
),
commercial02_ret AS (
    SELECT 
        xx.srhnum_0 AS numret,
        SUBSTR(yy.stofcy_0, 1, 1) AS ag,
        xx.rtndat_0,
        xx.bpcord_0,
        yy.itmref_0,
        yy.itmdes1_0,
        tt.tsicod_0 AS FC,
        tt.tsicod_1 AS FT,
        tt.tsicod_2 AS FD,
        t.tsicod_0 AS FCMKT,
        ' ' AS FCLIBMKT,
        t.tsicod_1 AS FTMKT,
        ' ' AS FTLIBMKT,
        t.tsicod_2 AS FDMKT,
        ' ' AS FDLIBMKT,
        yy.netpri_0,
        yy.qty_0 * -1 AS qty_0,
        (yy.qty_0 * yy.netprinot_0) * -1 AS HTN,
        (yy.qty_0 * yy.netprinot_0) * -1 AS HTB,
        SUBSTR(xx.bpcord_0, 2, 1) AS categ,
        uu.bpsnum_0 AS frs,
        yy.srdlin_0 AS ligne,
        (yy.qty_0 * yy.netpriati_0) * -1 AS TTCN,
        CAST(NULL AS VARCHAR2(100)) AS xdev
    FROM sreturn xx
    JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
    LEFT JOIN itmmaster tt ON tt.itmref_0 = yy.itmref_0
    LEFT JOIN itmmaster t ON t.itmref_0 = yy.itmref_0
    LEFT JOIN (
        SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0 
        FROM itmbps 
        GROUP BY itmref_0
    ) uu ON uu.itmref_0 = yy.itmref_0
    WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
      AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
          SELECT pp.srhnum_0, pp.srdlin_0 
          FROM sinvoiced pp 
          WHERE pp.invdat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY') 
            AND pp.srhnum_0 <> ' ' 
            AND pp.bpcinv_0 = xx.bpcord_0
      )
      AND (yy.sdhnum_0 = ' ' OR yy.sdhnum_0 IN (SELECT bl FROM commercial02_BL))
),
commercial02_fac AS (
    SELECT 
        x.num_0 AS fac,
        SUBSTR(x.fcy_0, 1, 1) AS agence,
        x.accdat_0 AS date_fac,
        x.bpr_0 AS tiers,
        y.itmref_0 AS article,
        y.itmdes1_0 AS lib_art_fac,
        y.tsicod_0 AS FC,
        y.tsicod_1 AS FT,
        tt.tsicod_2 AS FD,
        t.tsicod_0 AS FCMKT,
        ' ' AS FCLIBMKT,
        t.tsicod_1 AS FTMKT,
        ' ' AS FTLIBMKT,
        t.tsicod_2 AS FDMKT,
        ' ' AS FDLIBMKT,
        y.gropri_0 AS tarif,
        DECODE(x.gte_0, 'FAC', y.qty_0, 'AVC', y.qty_0 * -1) AS qte,
        DECODE(x.gte_0, 'FAC', (y.qty_0 * (y.netprinot_0 * x.ratmlt_0)), 'AVC', (y.qty_0 * (y.netprinot_0 * x.ratmlt_0)) * -1) AS HTN,
        DECODE(x.gte_0, 'FAC', (y.qty_0 * (y.netprinot_0 * x.ratmlt_0)), 'AVC', (y.qty_0 * (y.netprinot_0 * x.ratmlt_0)) * -1) AS HTB,
        SUBSTR(x.bpr_0, 2, 1) AS categ,
        uu.bpsnum_0 AS frs,
        y.sidlin_0 AS ligne,
        DECODE(x.gte_0, 'FAC', (y.qty_0 * y.netpriati_0), 'AVC', (y.qty_0 * y.netpriati_0) * -1) AS TTCN,
        CAST(NULL AS VARCHAR2(100)) AS xdev
    FROM sinvoice x
    JOIN sinvoiced y ON x.num_0 = y.num_0
    LEFT JOIN itmmaster tt ON tt.itmref_0 = y.itmref_0
    LEFT JOIN itmmaster t ON t.itmref_0 = y.itmref_0
    LEFT JOIN (
        SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0 
        FROM itmbps 
        GROUP BY itmref_0
    ) uu ON uu.itmref_0 = y.itmref_0
    WHERE x.accdat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
)
SELECT * FROM commercial02_BL
UNION
SELECT * FROM commercial02_ret
UNION
SELECT * FROM commercial02_fac