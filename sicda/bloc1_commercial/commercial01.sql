SELECT 
    cast(DECODE(SUBSTR(a.bpcord_0,1,2),
        'IE','BTP',
        'IA','Régies-Concessions',
        'IP','Particuliers',
        'IR','Revendeurs',
        'IS','Associations',
        'IZ','Divers',
        'AGRIC') as varchar2(50) ) AS secteur,

    a.sohnum_0 AS cde,
    b.soplin_0,

    DECODE(y.rep_0, ' ', 'AUTRES', y.rep_0) AS agence,

    a.orddat_0 AS date_BC,
    a.bpcord_0 AS tiers,
    b.itmref_0 AS Article,
    b.itmdes1_0 AS lib_art_cde,
    b.tsicod_0 AS FC,
    b.tsicod_1 AS FT,
    b.tsicod_2 AS FD,

    ' ' AS FCMKT,
    ' ' AS FCLIBMKT,
    ' ' AS FTMKT,
    ' ' AS FTLIBMKT,
    ' ' AS FDMKT,
    ' ' AS FDLIBMKT,

    b.gropri_0 AS tarif,
    c.qty_0 AS qte,

    (c.qty_0 * b.netpri_0) AS HTN,
    (c.qty_0 * b.gropri_0) AS HTB,

    SUBSTR(y.ysauv_clt_0,2,1) AS categ,
    t.itmwei_0 AS poids,

    c.dlvqty_0 AS qteliv,
    c.invqty_0 AS qtefac,

    DECODE(l.lanmes_0,'AABCDEFGHIJKLM','N/R',l.lanmes_0) AS regions

FROM sorder a
JOIN sorderp b 
    ON a.sohnum_0 = b.sohnum_0
JOIN sorderq c 
    ON a.sohnum_0 = c.sohnum_0 
   AND b.soplin_0 = c.soplin_0

LEFT JOIN bpcustomer y 
    ON y.bpcnum_0 = a.bpcord_0

LEFT JOIN itmmaster t 
    ON t.itmref_0 = b.itmref_0

LEFT JOIN aplstd l 
    ON l.lanchp_0 = 6004 
   AND l.lannum_0 = a.xregion_0

WHERE a.sohnum_0 LIKE 'C%'
  AND a.orddat_0 BETWEEN TO_DATE('01/01/2016','DD/MM/YYYY') 
                      AND TO_DATE('31/12/2026','DD/MM/YYYY')