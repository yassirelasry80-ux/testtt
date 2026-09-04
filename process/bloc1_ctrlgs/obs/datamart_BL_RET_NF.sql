SELECT 
    x.sdhnum_0 AS bl,
    y.sddlin_0 AS lig,
    x.salfcy_0 AS agence,
    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,
    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,
    y.tsicod_0 AS FCMKT,
    ' ' AS FCLIBMKT,
    y.tsicod_1 AS FTMKT,
    ' ' AS FTLIBMKT,
    y.tsicod_2 AS FDMKT,
    ' ' AS FDLIBMKT,
    y.gropri_0 AS tarif,
    y.qty_0 AS qte,
    (y.qty_0 * y.netpri_0) AS HTN,
    (y.qty_0 * y.NETPRIATI_0) AS TTCN,
    (y.qty_0 * y.gropri_0) AS HTB,
    SUBSTR(x.bpcord_0, 2, 1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,
    b.bpsnum_0 AS frs,
    s.bpsnam_0 AS lib_frs2,
    ' ' AS xclasse
FROM sdelivery x
JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
) b ON b.itmref_0 = y.itmref_0
LEFT JOIN bpsupplier s ON s.bpsnum_0 = b.bpsnum_0
WHERE x.betfcy_0 = 1 
  AND y.qty_0 <> y.rtnqty_0 
  AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
  AND x.invflg_0 = 1 
  AND x.xstrnum_0 <> 'PRE'

UNION

SELECT 
    xx.srhnum_0 AS numret,
    yy.srdlin_0 AS lig,
    xx.salfcy_0 AS ag,
    xx.rtndat_0 AS date_bl,
    xx.bpcord_0 AS tiers,
    yy.itmref_0 AS article,
    yy.itmdes1_0 AS lib,
    tt.tsicod_0 AS FCMKT,
    tt.tsicod_1 AS FTMKT,
    tt.tsicod_2 AS FDMKT,
    tt.tsicod_0 AS FC,
    ' ' AS FCLIBMKT,
    tt.tsicod_1 AS FT,
    ' ' AS FTLIBMKT,
    tt.tsicod_2 AS FD,
    ' ' AS FDLIBMKT,
    yy.netpri_0 AS tarif,
    yy.qty_0 * -1 AS qte,
    (yy.qty_0 * yy.NETPRINOT_0) * -1 AS HTN,
    (yy.qty_0 * yy.NETPRIATI_0) * -1 AS HTTC,
    (yy.qty_0 * yy.netpri_0) * -1 AS HTB,
    SUBSTR(xx.bpcord_0, 2, 1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,
    b.bpsnum_0 AS frs,
    s.bpsnam_0 AS lib_frs2,
    ' ' AS xclasse
FROM sreturn xx
JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
LEFT JOIN itmmaster tt ON tt.itmref_0 = yy.itmref_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
) b ON b.itmref_0 = yy.itmref_0
LEFT JOIN bpsupplier s ON s.bpsnum_0 = b.bpsnum_0
WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
  AND NOT EXISTS (
      SELECT 1 
      FROM sinvoiced pp 
      WHERE pp.srhnum_0 = yy.srhnum_0 
        AND pp.srdlin_0 = yy.srdlin_0 
        AND pp.invdat_0 BETWEEN TO_DATE('01/01/2017', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
        AND pp.srhnum_0 <> ' ' 
        AND pp.bpcinv_0 = xx.bpcord_0
  ) 
  AND (yy.sdhnum_0 = ' ' OR yy.sdhnum_0 IN (SELECT BL FROM datamart_bl_ret_nf_bl)) 
  AND xx.xstrnum_0 <> 'PRE'