SELECT 
    a.itmref_0 AS code,
    (
        SELECT d1.des1axx_0 
        FROM itmmaster d1 
        WHERE d1.itmref_0 = a.itmref_0
    ) AS libelle,
    SUM(a.qtypcu_0) AS qte 
FROM 
    stojou a 
WHERE 
    a.iptdat_0 BETWEEN '01/01/2026' AND '01/01/2026'    
GROUP BY 
    a.itmref_0