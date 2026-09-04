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
    substr(x.bpcord_0, 2, 1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,
    (SELECT max(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0) AS frs,
    (SELECT t.bpsnam_0 FROM bpsupplier t WHERE t.bpsnum_0 = (SELECT max(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = y.itmref_0)) AS lib_frs2,
    (SELECT ' ' FROM bpcustomer f WHERE f.bpcnum_0 = x.bpcord_0) AS xclasse
FROM 
    sdelivery x,
    sdeliveryd y 
WHERE 
    x.sdhnum_0 = y.sdhnum_0 
    AND x.betfcy_0 = 1 
    AND y.qty_0 <> y.rtnqty_0 
    AND x.dlvdat_0 BETWEEN '01/01/2017' AND '31/12/2026' 
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
    (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FCMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FTMKT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FDMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FC,
    ' ' AS FCLIBMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FT,
    ' ' AS FTLIBMKT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FD,
    ' ' AS FDLIBMKT,
    yy.netpri_0 AS tarif,
    yy.qty_0 * -1 AS qte,
    (yy.qty_0 * yy.NETPRINOT_0) * -1 AS HTN,
    (yy.qty_0 * yy.NETPRIATI_0) * -1 AS HTTC,
    (yy.qty_0 * yy.netpri_0) * -1 AS HTB,
    substr(xx.bpcord_0, 2, 1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,
    (SELECT max(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0) AS frs,
    (SELECT t.bpsnam_0 FROM bpsupplier t WHERE t.bpsnum_0 = (SELECT max(u.bpsnum_0) FROM itmbps u WHERE u.itmref_0 = yy.itmref_0)) AS lib_frs2,
    (SELECT ' ' FROM bpcustomer f WHERE f.bpcnum_0 = xx.bpcord_0) AS xclasse
FROM 
    sreturn xx,
    sreturnd yy 
WHERE 
    xx.srhnum_0 = yy.srhnum_0 
    AND xx.rtndat_0 BETWEEN '01/01/2017' AND '31/12/2026' 
    AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
        SELECT pp.srhnum_0, pp.srdlin_0 
        FROM sinvoiced pp 
        WHERE pp.invdat_0 BETWEEN '01/01/2017' AND '31/12/2026' 
        AND pp.srhnum_0 <> ' ' 
        AND pp.bpcinv_0 = xx.bpcord_0
    ) 
    AND (yy.sdhnum_0 = ' ' OR yy.sdhnum_0 IN (SELECT BL FROM (select x.sdhnum_0 bl,y.sddlin_0 lig,x.salfcy_0 agence,x.dlvdat_0 date_bl,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,y.tsicod_0 FCMKT,' ' FCLIBMKT,y.tsicod_1 FTMKT,' ' FTLIBMKT,y.tsicod_2 FDMKT,' ' FDLIBMKT ,y.gropri_0 tarif,y.qty_0 qte,(y.qty_0*y.netpri_0) HTN,(y.qty_0*y.NETPRIATI_0) TTCN,(y.qty_0*y.gropri_0) HTB,substr(x.bpcord_0,2,1) categ,' ' proj,' ' canal,' ' sicda,  ' ' ARTF,  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) frs,   (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) ) lib_frs2,(select ' ' from bpcustomer f where f.bpcnum_0=x.bpcord_0) xclasse      from sdelivery x,sdeliveryd y where x.sdhnum_0=y.sdhnum_0 and x.betfcy_0=1 and y.qty_0<>y.rtnqty_0 and  x.dlvdat_0 between '01/01/2017' and '31/12/2026' and x.invflg_0=1  AND x.xstrnum_0 <> 'PRE') )) 
    AND xx.xstrnum_0 <> 'PRE'