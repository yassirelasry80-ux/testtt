SELECT 
    bpcnum_0 AS tiers,
    INITCAP(bpcnam_0) AS lib_tiers,

    DECODE(bus_0,
        '1', 'G',
        '2', 'S',
        '3', 'B',
        '4', 'N',
        bus_0
    ) AS classe,

    credat_0,
    ostauz_0,
    xech_0,
    xdrecouvr_0,

    DECODE(rep_0, ' ', 'N/A', rep_0) AS rep,
    DECODE(rep_1, ' ', 'N/A', rep_1) AS rep_gest,

    ROUND((SYSDATE - credat_0) / 365, 2) AS anc,

    DECODE(xtyp_0_0,
        '1', 'COMPTANT A ECHEANCE',
        '2', 'EN COMPTE',
        '3', 'COMPTANT',
        'N/R'
    ) AS type_client,

    ysauv_clt_0

FROM bpcustomer

WHERE 
    LENGTH(bpcnum_0) > 5
    AND bpcnum_0 NOT LIKE 'Q%'