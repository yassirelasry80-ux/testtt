SELECT 
    b.bprnum_0, 
    b.bprnam_0, 
    f.xclasse_0 AS xclasse
FROM bpartner b
LEFT JOIN bpcustomer f 
    ON f.bpcnum_0 = b.bprnum_0
