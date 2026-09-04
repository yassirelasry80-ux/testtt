SELECT 
    a1.code_0 AS FD, 
    a2.texte_0 AS LIB_FD 
FROM 
    atabdiv a1, 
    atextra a2 
WHERE 
    a1.numtab_0 = '22' 
    AND a2.codfic_0 = 'ATABDIV' 
    AND a2.ident1_0 = 22 
    AND a2.zone_0 = 'LNGDES' 
    AND a2.ident2_0 = a1.code_0 

UNION 

SELECT 
    'SOLAIRE' AS FD, 
    'SOLAIRE' AS LIB_FD 
FROM 
    dual