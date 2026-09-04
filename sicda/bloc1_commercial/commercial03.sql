SELECT
    cast(DECODE(SUBSTR(x.bpr_0, 1, 2),
        'IE', 'BTP',
        'IA', 'Régies-Concessions',
        'IP', 'Particuliers',
        'IR', 'Revendeurs',
        'IS', 'Associations',
        'IZ', 'Divers',
        'IG', 'IntraGroupe',
        'IB', 'BTP GrandCmpt',
        'AGRIC'
    ) as varchar2(50) ) AS secteur,

    x.num_0 AS fac,

    COALESCE(NULLIF(c.rep_0, ' '), 'AUTRES') AS agence,

    x.accdat_0 AS date_fac,
    x.bpr_0 AS tiers,

    y.itmref_0 AS article,
    y.itmdes1_0 AS lib_art_fac,

    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,

    ' ' AS FCMKT,
    ' ' AS FCLIBMKT,
    ' ' AS FTMKT,
    ' ' AS FTLIBMKT,
    ' ' AS FDMKT,
    ' ' AS FDLIBMKT,

    y.gropri_0 AS tarif,

    CASE x.gte_0
        WHEN 'FAC' THEN y.qty_0
        WHEN 'FCP' THEN y.qty_0
        WHEN 'AVC' THEN -y.qty_0
        WHEN 'AVP' THEN -y.qty_0
        WHEN 'AFV' THEN -y.qty_0
    END AS qte,

    CASE x.gte_0
        WHEN 'FAC' THEN y.qty_0 * y.netpri_0
        WHEN 'FCP' THEN y.qty_0 * y.netpri_0
        WHEN 'AVC' THEN -y.qty_0 * y.netpri_0
        WHEN 'AVP' THEN -y.qty_0 * y.netpri_0
        WHEN 'AFV' THEN -y.qty_0 * y.netpri_0
    END AS HTN,

    CASE x.gte_0
        WHEN 'FAC' THEN y.qty_0 * y.gropri_0
        WHEN 'FCP' THEN y.qty_0 * y.gropri_0
        WHEN 'AVC' THEN -y.qty_0 * y.gropri_0
        WHEN 'AVP' THEN -y.qty_0 * y.gropri_0
        WHEN 'AFV' THEN -y.qty_0 * y.gropri_0
    END AS HTB,

    SUBSTR(c.ysauv_clt_0, 2, 1) AS categ

FROM sinvoice x
JOIN sinvoiced y
    ON y.num_0 = x.num_0

LEFT JOIN bpcustomer c
    ON c.bpcnum_0 = x.bpr_0

WHERE x.accdat_0 BETWEEN TO_DATE('01/01/2016','DD/MM/YYYY')
                      AND TO_DATE('31/12/2026','DD/MM/YYYY')