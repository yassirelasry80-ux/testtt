SELECT 
    x.num_0 AS fac,
    DECODE(c.rep_0, ' ', 'AUTRES', c.rep_0) AS agence,
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

    DECODE(x.gte_0,
        'FAC', y.qty_0,
        'FCP', y.qty_0,
        'AVC', -y.qty_0,
        'AVP', -y.qty_0,
        'AFV', -y.qty_0
    ) AS qte,

    DECODE(x.gte_0,
        'FAC', y.qty_0 * y.netpri_0,
        'FCP', y.qty_0 * y.netpri_0,
        'AVC', -y.qty_0 * y.netpri_0,
        'AVP', -y.qty_0 * y.netpri_0,
        'AFV', -y.qty_0 * y.netpri_0
    ) AS HTN,

    DECODE(x.gte_0,
        'FAC', y.qty_0 * y.gropri_0,
        'FCP', y.qty_0 * y.gropri_0,
        'AVC', -y.qty_0 * y.gropri_0,
        'AVP', -y.qty_0 * y.gropri_0,
        'AFV', -y.qty_0 * y.gropri_0
    ) AS HTB,

    SUBSTR(c.ysauv_clt_0, 2, 1) AS categ

FROM 
    sinvoice x
JOIN 
    sinvoiced y ON x.num_0 = y.num_0
LEFT JOIN 
    bpcustomer c ON c.bpcnum_0 = x.bpr_0

WHERE 
    x.accdat_0 BETWEEN TO_DATE('01/01/2019','DD/MM/YYYY') 
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')