SELECT
    x.sdhnum_0 AS bl,
    y.sddlin_0 AS lig,
    DECODE(SUBSTR(x.bpcord_0,7,1),
           'X','C',
           'Y','C',
           'Z','C',
           SUBSTR(x.bpcord_0,7,1)) AS agence,
    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS article,
    y.itmdes1_0 AS lib_art_bl,
    y.tsicod_0 AS fc,
    y.tsicod_1 AS ft,
    y.tsicod_2 AS fd,
    y.tsicod_0 AS fcmkt,
    ' ' AS fclibmkt,
    y.tsicod_1 AS ftmkt,
    ' ' AS ftlibmkt,
    y.tsicod_2 AS fdmkt,
    ' ' AS fdlibmkt,
    
    CASE WHEN x.bpcord_0 LIKE 'PZ%' THEN y.gropri_0 * 11 ELSE y.gropri_0 END AS tarif,
    y.qty_0 AS qte,
    CASE WHEN x.bpcord_0 LIKE 'PZ%' THEN (y.qty_0 * y.netpri_0 * 11) ELSE (y.qty_0 * y.netpri_0) END AS htn,
    CASE WHEN x.bpcord_0 LIKE 'PZ%' THEN (y.qty_0 * y.gropri_0 * 11) ELSE (y.qty_0 * y.gropri_0) END AS htb,

    SUBSTR(x.bpcord_0,2,1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS artf,
    (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0) AS frs,
    (SELECT t.bpsnam_0 FROM bpsupplier t WHERE t.bpsnum_0 = 
        (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0)) AS lib_frs2,
    (SELECT ' ' FROM bpcustomer f WHERE f.bpcnum_0 = x.bpcord_0) AS xclasse
FROM sdelivery x
JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
WHERE x.sdhnum_0 LIKE 'B%'
  AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND x.invflg_0 = 1

UNION

SELECT
    xx.srhnum_0 AS numret,
    yy.srdlin_0 AS lig,
    DECODE(SUBSTR(xx.bpcord_0,7,1),
           'X','C',
           'Y','C',
           'Z','C',
           SUBSTR(xx.bpcord_0,7,1)) AS ag,
    xx.rtndat_0 AS date_bl,
    xx.bpcord_0 AS tiers,
    yy.itmref_0 AS article,
    yy.itmdes1_0 AS lib,
    (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS fcmkt,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS ftmkt,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS fdmkt,
    
    CASE WHEN xx.bpcord_0 LIKE 'PZ%' 
         THEN (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0)
         ELSE (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) 
    END AS fc,
    ' ' AS fclibmkt,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS ft,
    ' ' AS ftlibmkt,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS fd,
    ' ' AS fdlibmkt,
    
    CASE WHEN xx.bpcord_0 LIKE 'PZ%' THEN yy.netpri_0 * 11 ELSE yy.netpri_0 END AS tarif,
    yy.qty_0 * -1 AS qte,
    CASE WHEN xx.bpcord_0 LIKE 'PZ%' THEN (yy.qty_0 * yy.netpri_0 * 11) * -1 ELSE (yy.qty_0 * yy.netpri_0) * -1 END AS htn,
    CASE WHEN xx.bpcord_0 LIKE 'PZ%' THEN (yy.qty_0 * yy.netpri_0 * 11) * -1 ELSE (yy.qty_0 * yy.netpri_0) * -1 END AS htb,

    SUBSTR(xx.bpcord_0,2,1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS artf,
    (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0) AS frs,
    (SELECT t.bpsnam_0 FROM bpsupplier t WHERE t.bpsnum_0 = 
        (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0)) AS lib_frs2,
    (SELECT ' ' FROM bpcustomer f WHERE f.bpcnum_0 = xx.bpcord_0) AS xclasse
FROM sreturn xx
JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND (xx.srhnum_0 LIKE 'RV%' OR xx.srhnum_0 LIKE 'RP%')
  AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
        SELECT pp.srhnum_0, srdlin_0
        FROM sinvoiced pp
        WHERE pp.invdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
          AND pp.srhnum_0 <> ' '
          AND pp.bpcinv_0 = xx.bpcord_0
  )