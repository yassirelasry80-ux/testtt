WITH Filtered AS (
    SELECT 
        vcrnum_0,
        trstyp_0,
        vcrtyp_0,
        iptdat_0,
        itmref_0,
        pcu_0,
        qtypcu_0
    FROM stojou
    WHERE iptdat_0 BETWEEN TO_DATE('01/01/2019','DD/MM/YYYY')
                       AND TO_DATE('31/12/2026','DD/MM/YYYY')
      AND (vcrnum_0 LIKE 'BFM%' OR vcrnum_0 LIKE 'DES%')
),
Totaux AS (
    SELECT 
        itmref_0, 
        vcrnum_0,
        SUM(CASE WHEN trstyp_0 = 1 THEN qtypcu_0 ELSE 0 END) AS qtefabacompose,
        SUM(CASE WHEN trstyp_0 = 2 THEN qtypcu_0 ELSE 0 END) AS qtefabacomposant
    FROM Filtered
    GROUP BY itmref_0, vcrnum_0
)
SELECT DISTINCT
    f.vcrnum_0,
    f.trstyp_0,
    DECODE(f.vcrtyp_0, 31, 'Assemblage', 32, 'Désassemblage') AS typ,
    f.iptdat_0 AS date_,
    f.itmref_0,
    m.des1axx_0 AS des,
    NVL(t.qtefabacompose, 0) AS qtefabacompose,
    NVL(t.qtefabacomposant, 0) AS qtefabacomposant,
    f.pcu_0 AS unitstk
FROM Filtered f
JOIN Totaux t
  ON t.itmref_0 = f.itmref_0
 AND t.vcrnum_0 = f.vcrnum_0
LEFT JOIN itmmaster m
  ON m.itmref_0 = f.itmref_0;