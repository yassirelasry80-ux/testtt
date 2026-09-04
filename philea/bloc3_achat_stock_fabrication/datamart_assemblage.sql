SELECT DISTINCT 
    vcrnum_0,
    trstyp_0,
    DECODE(vcrtyp_0, 31, 'Assemblage', 32, 'Désassemblage') typ,
    iptdat_0 date_,
    itmref_0,
    (
        SELECT des1axx_0 
        FROM itmmaster m 
        WHERE m.itmref_0 = ss.itmref_0
    ) des,
    NVL(
        (
            SELECT SUM(qtypcu_0) 
            FROM stojou s 
            WHERE s.itmref_0 = ss.itmref_0 
              AND s.vcrnum_0 = ss.vcrnum_0 
              AND trstyp_0 = 1 
              AND iptdat_0 BETWEEN '01/01/2021' AND '31/12/2026'
        ), 0
    ) qtefabacompose,
    NVL(
        (
            SELECT SUM(qtypcu_0) 
            FROM stojou s 
            WHERE s.itmref_0 = ss.itmref_0 
              AND s.vcrnum_0 = ss.vcrnum_0 
              AND trstyp_0 = 2 
              AND iptdat_0 BETWEEN '01/01/2021' AND '31/12/2026'
        ), 0
    ) qtefabacomposant,
    pcu_0 unitstk 
FROM 
    stojou ss 
WHERE 
    iptdat_0 BETWEEN '01/01/2021' AND '31/12/2026' 
    AND (vcrnum_0 LIKE 'BFM%' OR vcrnum_0 LIKE 'DES%')