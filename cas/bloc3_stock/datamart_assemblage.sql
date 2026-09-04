SELECT DISTINCT 
    ss.vcrnum_0,
    ss.trstyp_0,
    DECODE(ss.vcrtyp_0, 31, 'Assemblage', 32, 'Désassemblage') AS typ,
    ss.iptdat_0 AS date_,
    ss.itmref_0,
    m.des1axx_0 AS des,
    NVL(agg.qtefabacompose, 0) AS qtefabacompose,
    NVL(agg.qtefabacomposant, 0) AS qtefabacomposant,
    ss.pcu_0 AS unitstk
FROM 
    stojou ss
LEFT OUTER JOIN 
    itmmaster m ON m.itmref_0 = ss.itmref_0
LEFT OUTER JOIN (
    select 
        itmref_0,
        vcrnum_0,
        SUM(CASE WHEN trstyp_0 = 1 THEN qtypcu_0 ELSE 0 END) AS qtefabacompose,
        SUM(CASE WHEN trstyp_0 = 2 THEN qtypcu_0 ELSE 0 END) AS qtefabacomposant
    from 
        stojou
    where 
        iptdat_0 BETWEEN TO_DATE('01/01/2026', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
    group by 
        itmref_0,
        vcrnum_0
) agg ON agg.itmref_0 = ss.itmref_0 AND agg.vcrnum_0 = ss.vcrnum_0
WHERE 
    ss.iptdat_0 BETWEEN TO_DATE('01/01/2026', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')