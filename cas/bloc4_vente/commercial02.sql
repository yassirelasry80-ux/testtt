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
        (SELECT t.tsicod_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCMKT,
        ' ' AS FCLIBMKT,
        (SELECT t.tsicod_1 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTMKT,
        ' ' AS FTLIBMKT,
        (SELECT t.tsicod_2 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDMKT,
        ' ' AS FDLIBMKT,
        y.gropri_0 AS tarif,
        y.qty_0 AS qte,
        (y.qty_0 * (y.netprinot_0 * x.CHGRAT_0)) AS HTN,
        (y.qty_0 * (y.netprinot_0 * x.CHGRAT_0)) AS HTB,
        SUBSTR(x.bpcord_0, 2, 1) AS categ,
        (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs,
        y.sddlin_0 AS ligne,
        (y.qty_0 * (y.netpriati_0 * x.CHGRAT_0)) AS TTCN,
        x.VACBPR_0 AS reg
    FROM sdelivery x, sdeliveryd y 
    WHERE x.sdhnum_0 = y.sdhnum_0 
      AND x.invflg_0 <> 2 
      AND x.betfcy_0 = 1 
      AND x.dlvdat_0 BETWEEN '01/01/2024' AND '31/12/2026' 
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
        (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FC,
        (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FT,
        (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FD,
        (SELECT t.tsicod_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FCMKT,
        ' ' AS FCLIBMKT,
        (SELECT t.tsicod_1 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FTMKT,
        ' ' AS FTLIBMKT,
        (SELECT t.tsicod_2 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FDMKT,
        ' ' AS FDLIBMKT,
        yy.netpri_0,
        yy.qty_0 * -1 AS qty_0,
        (yy.qty_0 * yy.netprinot_0) * -1 AS HTN,
        (yy.qty_0 * yy.netprinot_0) * -1 AS HTB,
        SUBSTR(xx.bpcord_0, 2, 1) AS categ,
        (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = yy.itmref_0) AS frs,
        yy.srdlin_0 AS ligne,
        (yy.qty_0 * yy.netpriati_0) * -1 AS TTCN,
        'MAR' AS reg
    FROM sreturn xx, sreturnd yy 
    WHERE xx.srhnum_0 = yy.srhnum_0 
      AND xx.rtndat_0 BETWEEN '01/01/2024' AND '31/12/2026'  
      AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
          SELECT pp.srhnum_0, pp.srdlin_0 
          FROM sinvoiced pp 
          WHERE pp.invdat_0 BETWEEN '01/01/2024' AND '31/12/2026' 
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
        (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = y.itmref_0) AS FD,
        (SELECT t.tsicod_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCMKT,
        ' ' AS FCLIBMKT,
        (SELECT t.tsicod_1 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTMKT,
        ' ' AS FTLIBMKT,
        (SELECT t.tsicod_2 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDMKT,
        ' ' AS FDLIBMKT,
        y.gropri_0 AS tarif,
        y.qty_0 * x.sns_0 AS qte,
        (y.AMTNOTLIN_0 * ratmlt_0 * x.sns_0) AS HTN,
        (y.AMTNOTLIN_0 * ratmlt_0 * x.sns_0) AS HTB,
        SUBSTR(x.bpr_0, 2, 1) AS categ,
        (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs,
        y.sidlin_0 AS ligne,
        (y.AMTATILIN_0 * ratmlt_0 * x.sns_0) AS TTCN,
        VAC_0 AS reg
    FROM sinvoice x, sinvoiced y 
    WHERE x.num_0 = y.num_0  
      AND x.accdat_0 BETWEEN '01/01/2024' AND '31/12/2026'
),
combined_data AS (
    SELECT bl, agence, date_bl, tiers, Article, Lib_art_bl, FC, FT, FD, FCMKT, FCLIBMKT, FTMKT, FTLIBMKT, FDMKT, FDLIBMKT, tarif, qte, HTN, HTB, categ, frs, ligne, TTCN, reg FROM commercial02_BL
    UNION ALL
    SELECT numret, ag, rtndat_0, bpcord_0, itmref_0, itmdes1_0, FC, FT, FD, FCMKT, FCLIBMKT, FTMKT, FTLIBMKT, FDMKT, FDLIBMKT, netpri_0, qty_0, HTN, HTB, categ, frs, ligne, TTCN, reg FROM commercial02_ret
    UNION ALL
    SELECT fac, agence, date_fac, tiers, article, lib_art_fac, FC, FT, FD, FCMKT, FCLIBMKT, FTMKT, FTLIBMKT, FDMKT, FDLIBMKT, tarif, qte, HTN, HTB, categ, frs, ligne, TTCN, reg FROM commercial02_fac
)

SELECT c.*, CAST(NULL AS VARCHAR2(100)) AS xdev 
FROM combined_data c