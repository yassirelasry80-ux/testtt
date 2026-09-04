SELECT 
    n.pnhnum_0,
    n.rtndat_0 date_,
    rr.itmref_0 art,
    rr.itmdes_0 des,
    SUM(qtypuu_0) qte,
    netpri_0 prix,
    DECODE(r.STOMGTCOD_0, 2, 'OUI', 'NON') gerernstock,
    DECODE(n.CFMFLG_0, 2, 'OUI', 'NON') valider,
    rr.pthnum_0 rec 
FROM 
    preturnd rr,
    preturn n,
    itmmaster r 
WHERE 
    rr.itmref_0 = r.itmref_0 
    AND n.pnhnum_0 = rr.pnhnum_0 
    AND n.rtndat_0 BETWEEN '01/01/2021' AND '31/12/2025' 
GROUP BY 
    rr.pthnum_0,
    n.pnhnum_0,
    n.rtndat_0,
    rr.itmref_0,
    rr.itmdes_0,
    netpri_0,
    n.CFMFLG_0,
    r.STOMGTCOD_0