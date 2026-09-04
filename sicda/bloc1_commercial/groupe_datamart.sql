SELECT
    f.bpcnum_0 AS tiers,
    INITCAP(f.bpcnam_0) AS lib_tiers,
    f.bpcgru_0 AS cltgrp,
    INITCAP(y.bpcnam_0) AS lib_grp_tiers
FROM bpcustomer f
LEFT JOIN bpcustomer y
       ON y.bpcnum_0 = f.bpcgru_0
WHERE f.bpcsta_0 = 2
  AND LENGTH(f.bpcnum_0) >= 5
  AND f.bpcnum_0 NOT LIKE 'Q%'
  AND f.bpcgru_0 LIKE 'Q%'
ORDER BY f.bpcgru_0, f.bpcnum_0