SELECT 
    periode,
    tiers,
    fac,
    agence,
    categ,
    SUM(remise_except) remise_except 
FROM (
    SELECT 
        a.invdat_0 periode,
        a.bpcinv_0 tiers,
        a.num_0 fac,
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)) agence,
        SUBSTR(a.bpcinv_0, 2, 1) categ,
        SUM(b.dtanot_0) * -1 remise_except 
    FROM 
        sinvoicev a, 
        svcrfoot b 
    WHERE  
        a.num_0 = b.vcrnum_0 
        AND a.invdat_0 BETWEEN '01/01/2018' AND '31/12/2026' 
        AND a.invdtaamt_1 <> 0 
        AND a.sivtyp_0 IN ('FAC', 'FCP') 
    GROUP BY 
        a.invdat_0,
        a.bpcinv_0,
        a.num_0,
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)),
        SUBSTR(a.bpcinv_0, 2, 1)

    UNION 

    SELECT 
        a.invdat_0 periode,
        a.bpcinv_0 tiers,
        a.num_0 fac,
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)) agence,
        SUBSTR(a.bpcinv_0, 2, 1) categ,
        SUM(b.dtanot_0) remise_except 
    FROM 
        sinvoicev a, 
        svcrfoot b 
    WHERE  
        a.num_0 = b.vcrnum_0 
        AND a.invdat_0 BETWEEN '01/01/2018' AND '31/12/2026' 
        AND a.invdtaamt_1 <> 0 
        AND a.sivtyp_0 IN ('AVO', 'AVP') 
    GROUP BY 
        a.invdat_0,
        a.bpcinv_0,
        a.num_0,
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)),
        SUBSTR(a.bpcinv_0, 2, 1)
) 
GROUP BY 
    periode,
    tiers,
    fac,
    agence,
    categ