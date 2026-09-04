SELECT 
    a.itmref_0 AS code,
    MAX(d1.des1axx_0) AS libelle,
    SUM(a.qtypcu_0) AS qte 
FROM 
    stojou a
LEFT JOIN 
    itmmaster d1 ON d1.itmref_0 = a.itmref_0
WHERE 
    a.iptdat_0 = TO_DATE('01/01/2025', 'DD/MM/YYYY') 
    AND a.vcrnum_0 NOT LIKE 'INV%'
GROUP BY 
    a.itmref_0