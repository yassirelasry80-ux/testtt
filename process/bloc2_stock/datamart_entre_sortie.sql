SELECT 
    DECODE(vcrtyp_0, 19, 'ENTREE', 20, 'SORTIE') AS typ,
    iptdat_0,
    (SELECT vcrdes_0 FROM smvth h WHERE h.vcrnum_0 = s.vcrnum_0) AS ref,
    (SELECT nomusr_0 FROM autilis e WHERE e.usr_0 = s.creusr_0) AS usr,
    vcrnum_0,
    vcrlin_0,
    itmref_0,
    (SELECT des1axx_0 FROM itmmaster i WHERE i.itmref_0 = s.itmref_0) AS des,
    qtypcu_0 
FROM 
    stojou s 
WHERE 
    vcrtyp_0 IN ('19', '20') 
    AND iptdat_0 BETWEEN '01/01/2024' AND '31/12/2026'