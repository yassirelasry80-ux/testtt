SELECT 
    x.itmref_0,
    
    (
        SELECT t2.des1axx_0 
        FROM itmmaster t2 
        WHERE t2.itmref_0 = x.itmref_0
    ) AS libelle,
    
    MAX(x.iptdat_0) AS iptdat_0,
    SUM(x.qtypcu_0) AS qtypcu_0,
    MAX(t.laspurpri_0) AS laspurpri_0,
    
    der_date_achat(x.itmref_0) AS der_date_achat_conso,
    der_prix_achat(x.itmref_0) AS der_prix_achat

FROM 
    stojou x,
    itmmvt t

WHERE 
    t.itmref_0 = x.itmref_0 
    AND t.stofcy_0 = x.stofcy_0 
    AND x.iptdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                       AND TO_DATE('31/12/2026','DD/MM/YYYY')
    AND x.itmref_0 LIKE 'CAMI%' 
    AND x.vcrnum_0 NOT LIKE 'INV%'

GROUP BY 
    x.itmref_0 

ORDER BY 
    1, 2
    