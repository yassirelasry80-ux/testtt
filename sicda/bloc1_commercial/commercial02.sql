SELECT 
    cast(DECODE(SUBSTR(x.bpcord_0,1,2),
        'IE','BTP','IA','Régies-Concessions','IP','Particuliers','IR','Revendeurs',
        'IS','Associations','IZ','Divers','IG','IntraGroupe','IB','BTP GrandCmpt','AGRIC') as varchar2(50) ) as secteur,
    x.sdhnum_0 bl,
    NVL(NULLIF(b.rep_0,' '),'AUTRES') agence,
    x.dlvdat_0 date_bl,
    x.bpcord_0 tiers,
    y.itmref_0 Article,
    y.itmdes1_0 Lib_art_bl,
    y.tsicod_0 FC,
    y.tsicod_1 FT,
    y.tsicod_2 FD,
    ' ' FCMKT,' ' FCLIBMKT,' ' FTMKT,' ' FTLIBMKT,' ' FDMKT,' ' FDLIBMKT,
    y.gropri_0 tarif,
    y.qty_0 qte,
    (y.qty_0*y.netpri_0) HTN,
    (y.qty_0*y.gropri_0) HTB,
    SUBSTR(b.ysauv_clt_0,2,1) categ,
    im.itmwei_0 poids,
    y.sohnum_0 cde,
    y.soplin_0 ligcde,
    NVL(l.lanmes_0,'ANCIEN') nature_cde
FROM sdelivery x
JOIN sdeliveryd y ON x.sdhnum_0 = y.sdhnum_0
LEFT JOIN bpcustomer b ON b.bpcnum_0 = x.bpcord_0
LEFT JOIN itmmaster im ON im.itmref_0 = y.itmref_0
LEFT JOIN sorder r ON r.sohnum_0 = y.sohnum_0 
                   AND r.xnatcde_0 <> 0 
                   AND r.betfcy_0 = 1
LEFT JOIN aplstd l ON l.lanchp_0 = '6003' 
                  AND l.lannum_0 = r.xnatcde_0 
                  AND l.lan_0 = 'FRA'
WHERE x.sdhnum_0 LIKE 'B%'
AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2016','DD/MM/YYYY') 
                      AND TO_DATE('31/12/2026','DD/MM/YYYY')

UNION

SELECT 
    DECODE(SUBSTR(xx.bpcord_0,1,2),
        'IE','BTP','IA','Régies-Concessions','IP','Particuliers','IR','Revendeurs',
        'IS','Associations','IZ','Divers','IG','IntraGroupe','IB','BTP GrandCmpt','AGRIC') secteur,
    xx.srhnum_0 numret,
    NVL(NULLIF(b.rep_0,' '),'AUTRES') agence,
    xx.rtndat_0,
    xx.bpcord_0,
    yy.itmref_0,
    yy.itmdes1_0,
    im.tsicod_0 FC,
    im.tsicod_1 FT,
    im.tsicod_2 FD,
    ' ',' ',' ',' ',' ',' ',
    yy.netpri_0,
    yy.qty_0 * -1,
    (yy.qty_0 * yy.netpri_0) * -1,
    (yy.qty_0 * yy.netpri_0) * -1,
    SUBSTR(b.ysauv_clt_0,2,1),
    im.itmwei_0,
    yy.sdhnum_0 bl,
    yy.sddlin_0 ligbl,
    NVL(l.lanmes_0,'ANCIEN')
FROM sreturn xx
JOIN sreturnd yy ON xx.srhnum_0 = yy.srhnum_0
LEFT JOIN bpcustomer b ON b.bpcnum_0 = xx.bpcord_0
LEFT JOIN itmmaster im ON im.itmref_0 = yy.itmref_0
LEFT JOIN sdeliveryd hh ON hh.sdhnum_0 = yy.sdhnum_0 
                       AND hh.sddlin_0 = yy.sddlin_0
LEFT JOIN sorder r ON r.sohnum_0 = hh.sohnum_0 
                   AND r.xnatcde_0 <> 0 
                   AND r.betfcy_0 = 1
LEFT JOIN aplstd l ON l.lanchp_0 = '6003' 
                  AND l.lannum_0 = r.xnatcde_0 
                  AND l.lan_0 = 'FRA'
WHERE xx.rtndat_0 BETWEEN TO_DATE('01/01/2016','DD/MM/YYYY') 
                      AND TO_DATE('31/12/2026','DD/MM/YYYY')
AND xx.srhnum_0 LIKE 'RV%'