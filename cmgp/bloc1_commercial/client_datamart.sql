SELECT 
    a.bpcnum_0 AS tiers,
    INITCAP(bpcnam_0) AS lib_tiers,

    DECODE(bus_0,
        '1','G',
        '2','S',
        '3','B',
        '4','N',
        bus_0
    ) AS classe,

    credat_0,
    ostauz_0,
    xech_0,
    xdrecouvr_0,

    DECODE(
        (SELECT MAX(j.rep_0)
         FROM bpdlvcust j
         WHERE j.bpcnum_0 = a.bpcnum_0),
        ' ','N/A',
        (SELECT MAX(j.rep_0)
         FROM bpdlvcust j
         WHERE j.bpcnum_0 = a.bpcnum_0)
    ) AS rep,

    DECODE(
        (SELECT MAX(j.rep_1)
         FROM bpdlvcust j
         WHERE j.bpcnum_0 = a.bpcnum_0),
        ' ','N/A',
        (SELECT MAX(j.rep_1)
         FROM bpdlvcust j
         WHERE j.bpcnum_0 = a.bpcnum_0)
    ) AS rep_gest,

    ROUND((SYSDATE - credat_0) / 365, 2) AS anc,

    DECODE(
        xtyp_0_0,
        '1','COMPTANT A ECHEANCE',
        '2','EN COMPTE',
        '3','COMPTANT',
        'N/R'
    ) AS type_client,

    xregion_0 AS region,
    xville_0 AS ville,
    ysynergie_0,
    ysoc_0,
    ycommun_0,
    ysoccom_0,
    a.ysauv_clt_0

FROM bpcustomer a

WHERE 
    LENGTH(bpcnum_0) > 5
    AND SUBSTR(bpcnum_0, 1, 1) NOT IN ('G','Q')