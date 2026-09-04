SELECT DISTINCT 
    vcrnum_0,
    trstyp_0,
    DECODE(trstyp_0, 
           5, 'qtefabacompose',
           6, 'qtefabacomposant') AS typ,
    iptdat_0 AS date_,
    itmref_0,
    (
        SELECT des1axx_0 
        FROM itmmaster m 
        WHERE m.itmref_0 = ss.itmref_0
    ) AS des,
    SUM(qtypcu_0) AS qte,
    pcu_0 AS unitstk
FROM stojou ss
WHERE iptdat_0 BETWEEN TO_DATE('01/01/2022','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND vcrnumori_0 LIKE 'OF%'
GROUP BY 
    vcrnum_0,
    trstyp_0,
    iptdat_0,
    itmref_0,
    pcu_0