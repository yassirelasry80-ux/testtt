SELECT 
    DECODE(vcrtyp_0, 19, 'ENTREE', 20, 'SORTIE') typ,
    iptdat_0,
    (SELECT MAX(vcrdes_0) 
     FROM smvth h 
     WHERE h.vcrnum_0 = s.vcrnum_0) ref,
    (SELECT nomusr_0 
     FROM autilis e 
     WHERE e.usr_0 = s.creusr_0) usr,
    vcrnum_0,
    vcrlin_0,
    itmref_0,
    (SELECT des1axx_0 
     FROM itmmaster i 
     WHERE i.itmref_0 = s.itmref_0) des,
    qtypcu_0
FROM stojou s
WHERE vcrtyp_0 IN (19, 20)
  AND iptdat_0 BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
  AND vcrnum_0 NOT LIKE 'INI%200%_9%'