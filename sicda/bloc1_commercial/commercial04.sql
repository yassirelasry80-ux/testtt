SELECT 
    a.invdat_0 AS periode,
    a.bpcinv_0 AS tiers,
    DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)) AS agence,
    SUBSTR(a.bpcinv_0, 2, 1) AS categ,
    SUM(
        CASE 
            WHEN a.sivtyp_0 IN ('FAC', 'FCP') THEN b.dtanot_0 * -1
            WHEN a.sivtyp_0 IN ('AVO', 'AVP') THEN b.dtanot_0
            ELSE 0
        END
    ) AS remise_except
FROM 
    sinvoicev a
JOIN 
    svcrfoot b ON a.num_0 = b.vcrnum_0
WHERE 
    a.invdat_0 BETWEEN '01/01/2016' AND '31/12/2026'
    AND a.invdtaamt_1 <> 0
    AND a.sivtyp_0 IN ('FAC', 'FCP', 'AVO', 'AVP')
GROUP BY 
    a.invdat_0,
    a.bpcinv_0,
    DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)),
    SUBSTR(a.bpcinv_0, 2, 1)