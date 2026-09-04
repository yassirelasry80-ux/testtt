SELECT 
    DECODE(s.vcrtyp_0, 19, 'ENTREE', 20, 'SORTIE') AS typ,
    s.iptdat_0,
    h.vcrdes_0 AS ref,
    e.nomusr_0 AS usr,
    s.vcrnum_0,
    s.vcrlin_0,
    s.itmref_0,
    i.des1axx_0 AS des,
    s.qtypcu_0
FROM stojou s
LEFT JOIN smvth h 
    ON h.vcrnum_0 = s.vcrnum_0
LEFT JOIN autilis e 
    ON e.usr_0 = s.creusr_0
LEFT JOIN itmmaster i 
    ON i.itmref_0 = s.itmref_0
WHERE s.vcrtyp_0 IN (19, 20)
  AND s.iptdat_0 BETWEEN TO_DATE('01/01/2026', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')