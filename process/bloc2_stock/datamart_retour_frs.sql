SELECT 
    n.pnhnum_0, 
    n.rtndat_0 AS date_, 
    rr.itmref_0 AS art, 
    rr.itmdes_0 AS des, 
    SUM(qtypuu_0) AS qte, 
    netpri_0 AS prix, 
    DECODE(r.STOMGTCOD_0, 2, 'OUI', 'NON') AS gerernstock, 
    DECODE(n.CFMFLG_0, 2, 'OUI', 'NON') AS valider, 
    rr.pthnum_0 AS rec 
FROM 
    preturnd rr, 
    preturn n, 
    itmmaster r 
WHERE 
    rr.itmref_0 = r.itmref_0 
    AND n.pnhnum_0 = rr.pnhnum_0 
    AND n.rtndat_0 BETWEEN '01/01/2024' AND '31/12/2026' 
GROUP BY 
    rr.pthnum_0, 
    n.pnhnum_0, 
    n.rtndat_0, 
    rr.itmref_0, 
    rr.itmdes_0, 
    netpri_0, 
    n.CFMFLG_0, 
    r.STOMGTCOD_0