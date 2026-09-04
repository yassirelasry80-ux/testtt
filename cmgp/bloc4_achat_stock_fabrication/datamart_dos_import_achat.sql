SELECT 
    g.xdanum_0,
    g.xetdat_0,
    p.pohnum_0,
    p.poplin_0,
    p.xdaqty_0,
    p.pthnum_0
FROM xgetape g
JOIN xgpohlin p 
    ON g.xdanum_0 = p.xdanum_0
WHERE g.xetape_0 = 175