SELECT 
    tiers,
    lib_tiers,
    cltgrp,
    lib_grp_tiers
FROM (
    SELECT 
        f.bpcnum_0 AS tiers,
        INITCAP(f.bpcnam_0) AS lib_tiers,
        f.bpcgru_0 AS cltgrp,
        INITCAP((
            SELECT y.bpcnam_0 
            FROM bpcustomer y 
            WHERE y.bpcnum_0 = f.bpcgru_0
        )) AS lib_grp_tiers
    FROM bpcustomer f
    WHERE 
        f.bpcsta_0 = 2
        AND LENGTH(f.bpcnum_0) >= 5
        AND f.bpcnum_0 NOT LIKE 'G%'
) sub
WHERE sub.cltgrp LIKE 'G%'
ORDER BY 
    sub.cltgrp,
    sub.tiers