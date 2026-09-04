SELECT 
    vcrnum_0,
    trstyp_0,
    DECODE(vcrtyp_0, 31, 'Assemblage', 32, 'Désassemblage') AS typ,
    iptdat_0 AS date_,
    itmref_0,
    des1axx_0 AS des,
    NVL(qtefabacompose, 0) AS qtefabacompose,
    NVL(qtefabacomposant, 0) AS qtefabacomposant,
    unitstk
FROM (
    SELECT DISTINCT 
        ss.vcrnum_0,
        ss.trstyp_0,
        ss.vcrtyp_0,
        ss.iptdat_0,
        ss.itmref_0,
        m.des1axx_0,
        fa1.qtefabacompose,
        fa2.qtefabacomposant,
        ss.pcu_0 AS unitstk
    FROM stojou ss
    LEFT JOIN itmmaster m 
        ON m.itmref_0 = ss.itmref_0
    LEFT JOIN (
        SELECT itmref_0, vcrnum_0, SUM(qtypcu_0) AS qtefabacompose
        FROM stojou
        WHERE trstyp_0 = 1 
          AND iptdat_0 BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
        GROUP BY itmref_0, vcrnum_0
    ) fa1 ON fa1.itmref_0 = ss.itmref_0 AND fa1.vcrnum_0 = ss.vcrnum_0
    LEFT JOIN (
        SELECT itmref_0, vcrnum_0, SUM(qtypcu_0) AS qtefabacomposant
        FROM stojou
        WHERE trstyp_0 = 2 
          AND iptdat_0 BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
        GROUP BY itmref_0, vcrnum_0
    ) fa2 ON fa2.itmref_0 = ss.itmref_0 AND fa2.vcrnum_0 = ss.vcrnum_0
    WHERE ss.iptdat_0 BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
)