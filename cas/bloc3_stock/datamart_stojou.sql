SELECT /*+ PARALLEL(t, 4) */ 
    t.iptdat_0,
    t.vcrnum_0,
    t.vcrtyp_0,
    t.vcrlin_0,
    t.vcrnumori_0,
    t.vcrlinori_0,
    t.stofcy_0,
    t.itmref_0,
    t.qtypcu_0,
    NVL(m.xlastpricepo_0, t.priord_0) AS priord_0,
    t.bprnum_0,
    CASE WHEN t.trstyp_0 IN (5, 6) THEN 1 ELSE 0 END AS fabrique  
FROM 
    stojou t
JOIN 
    itmmaster m ON m.itmref_0 = t.itmref_0
WHERE 
    t.iptdat_0 BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
    AND t.regflg_0 = 1