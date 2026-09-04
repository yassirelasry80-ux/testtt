SELECT DISTINCT 
    vcrnum_0,
    trstyp_0,
    DECODE(trstyp_0, 5, 'qtefabacompose', 6, 'qtefabacomposant') typ,
    iptdat_0 date_,
    itmref_0,
    (
        SELECT des1axx_0 
        FROM itmmaster m 
        WHERE m.itmref_0 = ss.itmref_0
    ) des,
    SUM(qtypcu_0) qte,
    pcu_0 unitstk 
FROM 
    stojou ss 
WHERE 
    iptdat_0 BETWEEN '01/01/2021' AND '31/12/2026' 
    AND vcrnumori_0 LIKE 'OF%' 
GROUP BY 
    vcrnum_0,
    trstyp_0,
    iptdat_0,
    itmref_0,
    pcu_0