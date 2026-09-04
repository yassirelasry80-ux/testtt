SELECT 
    DECODE(k.xtypgar_0, 1, 'GP', 2, 'GS', 3, 'CS', 4, 'CB', k.xtypgar_0) typ_gar,
    k.num_0,
    k.amtcur_0,
    k.accdat_0,
    k.bpr_0    
FROM 
    paymenth k 
WHERE 
    k.num_0 LIKE 'GAR%'   
    AND k.xtypgar_0 IN (1, 2, 3, 4)