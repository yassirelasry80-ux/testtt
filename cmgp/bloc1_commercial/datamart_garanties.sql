SELECT
    CASE k.xtypgar_0
        WHEN 1 THEN 'GP'
        WHEN 2 THEN 'GS'
        WHEN 3 THEN 'CS'
        WHEN 4 THEN 'CB'
        ELSE TO_CHAR(k.xtypgar_0)
    END  AS typ_gar,
    k.num_0,
    k.amtcur_0,
    k.accdat_0,
    k.bpr_0
FROM paymenth k
WHERE k.num_0     LIKE 'GAR%'
  AND k.xannule_0  <> 2
  AND k.xremisclt_0 <> 2
  AND k.xtypgar_0   IN (1, 2, 3, 4)