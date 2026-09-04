SELECT 
    a.bpcnum_0 AS tiers,
    INITCAP(bpcnam_0) AS lib_tiers,
    DECODE(bus_0, '1', 'G', '2', 'S', '3', 'B', '4', 'N', bus_0) AS classe,
    credat_0,
    ostauz_0,
    ' ' AS xech_0,
    ' ' AS xdrecouvr_0,
    DECODE(
        (SELECT MAX(j.rep_0) FROM bpcustomer j WHERE j.bpcnum_0 = a.bpcnum_0), 
        ' ', 'N/A', 
        (SELECT MAX(j.rep_0) FROM bpcustomer j WHERE j.bpcnum_0 = a.bpcnum_0)
    ) AS rep,
    DECODE(
        (SELECT MAX(j.rep_1) FROM bpcustomer j WHERE j.bpcnum_0 = a.bpcnum_0), 
        ' ', 'N/A', 
        (SELECT MAX(j.rep_1) FROM bpcustomer j WHERE j.bpcnum_0 = a.bpcnum_0)
    ) AS rep_gest,
    ROUND((SYSDATE - credat_0) / 365, 2) AS anc,
    'N/R' AS type_client,
    bcgcod_0 AS categ_clt,
    0 AS synergie,
    ' ' AS syn_name,
    0 AS commun,
    ' ' AS com_name,
    0 AS xdmp_0 
FROM 
    bpcustomer a 
WHERE 
    LENGTH(bpcnum_0) > 3 
    AND bpcnum_0 NOT LIKE 'Q%'