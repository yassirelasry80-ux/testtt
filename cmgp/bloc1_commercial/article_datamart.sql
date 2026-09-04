SELECT DISTINCT
    e.tclcod_0                                                          AS categ_art,
    e.tsicod_0                                                          AS FC,
    e.tsicod_1                                                          AS FT,
    CASE
        WHEN e.itmref_0 LIKE 'RA02%' THEN 'RA01'
        ELSE e.tsicod_2
    END                                                                 AS FD,
    e.itmref_0                                                          AS article,
    e.des1axx_0                                                         AS lib_article,
    NVL(s.baspri_0, 0)                                                  AS tarif,
    e.vacitm_0                                                          AS regime,
    frs.bpsnum_0                                                        AS art_frs,
    sup.bpsnam_0                                                        AS lib_frs,
    e.xclasse_0,
    e.itmsta_0,
    e.xstock_0,
    e.xbusline_0,
    DECODE(e.xfrs_0,
        1, 'IMPORT',
        2, 'LOCAL',
        3, 'IMP/LOC',
        4, 'FABRICATION',
        5, 'TECHNIQUE'
    )                                                                   AS XFRS,
    e.xsbusline_0,
    e.xcentre_0,
    e.XVA_0,
    sim.artsicda,
    sim.poids,
    sim.categ_sicda                                                     AS categ
FROM itmmaster e
LEFT OUTER JOIN (
    SELECT DISTINCT itmref_0, baspri_0
    FROM itmsales
) s
    ON s.itmref_0 = e.itmref_0
LEFT OUTER JOIN (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
) frs
    ON frs.itmref_0 = e.itmref_0
LEFT OUTER JOIN bpsupplier sup
    ON sup.bpsnum_0 = frs.bpsnum_0
LEFT OUTER JOIN (
    SELECT
        xitmart_0,
        MAX(itmref_0)   AS artsicda,
        MAX(itmwei_0)   AS poids,
        MAX(xdesgrp_0)  AS categ_sicda
    FROM sicda.itmmaster
    WHERE xitmart_0 <> ' '
    GROUP BY xitmart_0
) sim
    ON sim.xitmart_0 = e.itmref_0
WHERE e.tclcod_0 IN ('NEG', 'NEGT', 'ARC', 'ART')