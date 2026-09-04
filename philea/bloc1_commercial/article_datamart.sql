SELECT DISTINCT
    e.tclcod_0 AS categ_art,
    e.tsicod_0 AS FC,
    e.tsicod_1 AS FT,
    e.tsicod_2 AS FD,
    e.itmref_0 AS article,
    e.des1axx_0 AS lib_article,
    NVL(t.baspri_0, 0) AS tarif,
    e.vacitm_0 AS regime,
    u_max.bpsnum_0 AS art_frs,
    s.bpsnam_0 AS lib_frs,
    e.xbusline_0,
    e.xsbusline_0,
    e.xstock_0,
    e.itmsta_0
FROM itmmaster e
LEFT JOIN itmsales t 
    ON t.itmref_0 = e.itmref_0
LEFT JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
) u_max 
    ON u_max.itmref_0 = e.itmref_0
LEFT JOIN bpsupplier s 
    ON s.bpsnum_0 = u_max.bpsnum_0
WHERE e.tclcod_0 = 'NEG'