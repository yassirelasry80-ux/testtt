SELECT 
    s.iptdat_0,
    s.vcrnum_0,
    s.vcrtyp_0,
    s.vcrlin_0,
    s.vcrnumori_0,
    s.vcrlinori_0,
    s.stofcy_0,
    s.itmref_0,
    s.qtypcu_0,
    NVL(xlastpricepo_0, priord_0) AS priord_0,
    s.bprnum_0,
    CASE WHEN s.TRSTYP_0 IN (5, 6) THEN 1 ELSE 0 END AS fabrique
FROM 
    stojou s
JOIN 
    itmmaster i ON i.itmref_0 = s.itmref_0
WHERE 
    s.regflg_0 = 1
    AND s.iptdat_0 BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')