SELECT 
    x.sdhnum_0 AS bl,
    y.sddlin_0 AS lig,
    DECODE(SUBSTR(x.bpcord_0,1,1),'X','C','Y','C','Z','C',SUBSTR(x.bpcord_0,1,1)) AS agence,
    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,
    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,
    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,
    (SELECT xfc_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCMKT,
    (SELECT xfclib_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FCLIBMKT,
    (SELECT xfT_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTMKT,
    (SELECT xfTlib_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FTLIBMKT,
    (SELECT xfD_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDMKT,
    (SELECT xfDlib_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0) AS FDLIBMKT,
    CASE 
        WHEN x.bpcord_0 LIKE 'PZ%' THEN y.gropri_0 * 11 
        ELSE y.gropri_0 
    END AS tarif,
    y.qty_0 AS qte,
    CASE 
        WHEN x.bpcord_0 LIKE 'PZ%' THEN (y.qty_0 * y.netpri_0 * 11) 
        ELSE (y.qty_0 * y.netpri_0) 
    END AS HTN,
    CASE 
        WHEN x.bpcord_0 LIKE 'PZ%' THEN (y.qty_0 * y.gropri_0 * 11) 
        ELSE (y.qty_0 * y.gropri_0) 
    END AS HTB,
    y.netpriati_0 AS ttc,
    SUBSTR(x.bpcord_0,2,1) AS categ,
    (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = x.sdhnum_0 AND ii.bpcord_0 = x.bpcord_0) AS proj,
    CASE
        WHEN (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = x.sdhnum_0 AND ii.bpcord_0 = x.bpcord_0) = 'RRRR'
            THEN 'SOLAIRE'
        WHEN (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = x.bpcord_0) = '1'
            THEN 'GRAND COMPTE'
        WHEN (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = x.bpcord_0) = '2'
            THEN 'PARTICULIER'
        WHEN SUBSTR(x.bpcord_0,2,1) = 'U'
            THEN 'APPEL OFFRE'
        ELSE
            DECODE(
                (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = x.sdhnum_0 AND ii.bpcord_0 = x.bpcord_0),
                NULL, 'DISTRIBUTION',
                DECODE(
                    SUBSTR((SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = x.sdhnum_0 AND ii.bpcord_0 = x.bpcord_0), 2, 1),
                    'U', 'APPEL OFFRE',
                    'MARCHE PRIVE'
                )
            )
    END AS canal,
    DECODE((SELECT MAX(t.itmref_0) FROM itmbps t WHERE t.itmref_0 = y.itmref_0 AND t.bpsnum_0 = '208'), NULL, 'NON', ' ', 'NON', 'OUI') AS sicda,
    DECODE((SELECT MAX(a.itmref_0) FROM bom a WHERE a.itmref_0 = y.itmref_0), NULL, 'NON', 'OUI') AS ARTF,
    (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0) AS frs,
    (SELECT MAX(t.bpsnam_0) FROM bpsupplier t WHERE t.bpsnum_0 = (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0)) AS lib_frs2,
    (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = x.bpcord_0) AS xclasse
FROM sdelivery x
JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
WHERE x.sdhnum_0 LIKE 'B%' 
  AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND x.invflg_0 = 1

UNION


SELECT 
    xx.srhnum_0 AS numret,
    yy.srdlin_0 AS lig,
    DECODE(SUBSTR(xx.bpcord_0,1,1),'X','C','Y','C','Z','C',SUBSTR(xx.bpcord_0,1,1)) AS ag,
    xx.rtndat_0 AS date_bl,
    xx.bpcord_0 AS tiers,
    yy.itmref_0 AS article,
    yy.itmdes1_0 AS lib,
    (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FC,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FD,
    (SELECT xfc_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FCMKT,
    (SELECT xfclib_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FCLIBMKT,
    (SELECT xfT_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FTMKT,
    (SELECT xfTlib_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FTLIBMKT,
    (SELECT xfD_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FDMKT,
    (SELECT xfDlib_0 FROM itmmaster t WHERE t.itmref_0 = yy.itmref_0) AS FDLIBMKT,
    CASE 
        WHEN xx.bpcord_0 LIKE 'PZ%' THEN yy.netpri_0 * 11 
        ELSE yy.netpri_0 
    END AS tarif,
    yy.qty_0 * -1 AS qte,
    CASE 
        WHEN xx.bpcord_0 LIKE 'PZ%' THEN (yy.qty_0 * yy.netpri_0 * 11) * -1 
        ELSE (yy.qty_0 * yy.netpri_0) * -1 
    END AS HTN,
    CASE 
        WHEN xx.bpcord_0 LIKE 'PZ%' THEN (yy.qty_0 * yy.netpri_0 * 11) * -1 
        ELSE (yy.qty_0 * yy.netpri_0) * -1 
    END AS HTB,
    yy.netpriati_0 AS ttc,
    SUBSTR(xx.bpcord_0,2,1) AS categ,
    (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = yy.sdhnum_0 AND ii.bpcord_0 = xx.bpcord_0) AS proj,
    CASE
        WHEN (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = yy.sdhnum_0 AND ii.bpcord_0 = xx.bpcord_0) = 'RRRR'
            THEN 'SOLAIRE'
        WHEN (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = xx.bpcord_0) = '1'
            THEN 'GRAND COMPTE'
        WHEN (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = xx.bpcord_0) = '2'
            THEN 'PARTICULIER'
        WHEN SUBSTR(xx.bpcord_0,2,1) = 'U'
            THEN 'APPEL OFFRE'
        ELSE
            DECODE(
                (SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = yy.sdhnum_0 AND ii.bpcord_0 = xx.bpcord_0),
                NULL, 'DISTRIBUTION',
                DECODE(
                    SUBSTR((SELECT MAX(ii.axeproj_0) FROM xprojet ii WHERE ii.sdhnum_0 = yy.sdhnum_0 AND ii.bpcord_0 = xx.bpcord_0), 2, 1),
                    'U', 'APPEL OFFRE',
                    'MARCHE PRIVE'
                )
            )
    END AS canal,
    DECODE((SELECT MAX(t.itmref_0) FROM itmbps t WHERE t.itmref_0 = yy.itmref_0 AND t.bpsnum_0 = '208'), NULL, 'NON', ' ', 'NON', 'OUI') AS sicda,
    DECODE((SELECT MAX(a.itmref_0) FROM bom a WHERE a.itmref_0 = yy.itmref_0), NULL, 'NON', 'OUI') AS ARTF,
    (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0) AS frs,
    (SELECT MAX(t.bpsnam_0) FROM bpsupplier t WHERE t.bpsnum_0 = (SELECT MAX(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0)) AS lib_frs2,
    (SELECT MAX(f.xclasse_0) FROM bpcustomer f WHERE f.bpcnum_0 = xx.bpcord_0) AS xclasse
FROM sreturn xx
JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND (xx.srhnum_0 LIKE 'RV%' OR xx.srhnum_0 LIKE 'RP%')
  AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
      SELECT pp.srhnum_0, pp.srdlin_0 FROM sinvoiced pp 
      WHERE pp.invdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY') 
        AND pp.srhnum_0 <> ' ' 
        AND pp.bpcinv_0 = xx.bpcord_0
  )