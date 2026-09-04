SELECT 
    a1.code_0 AS FD,
    a2.texte_0 AS LIB_FD
FROM atabdiv a1
JOIN atextra a2
    ON a2.ident2_0 = a1.code_0
WHERE a1.numtab_0 = '22'
  AND a2.codfic_0 = 'ATABDIV'
  AND a2.ident1_0 = 22
  AND a2.zone_0 = 'LNGDES'