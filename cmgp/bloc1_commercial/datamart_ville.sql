SELECT
    a.lannum_0  AS num_,
    a.lanmes_0  AS ville_
FROM aplstd a
WHERE a.lan_0    = 'FRA'
  AND a.lanchp_0 = '6025'
  AND a.lannum_0 > 0