SELECT 
    a1.code_0 AS FC, 
    a2.texte_0 AS lib_FC 
FROM 
    atabdiv a1, 
    atextra a2 
WHERE 
    a1.numtab_0 = '20' 
    AND a2.codfic_0 = 'ATABDIV' 
    AND a2.ident1_0 = 20 
    AND a2.zone_0 = 'LNGDES' 
    AND a2.ident2_0 = a1.code_0