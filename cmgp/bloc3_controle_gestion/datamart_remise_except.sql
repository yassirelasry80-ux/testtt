SELECT 
    periode,
    tiers,
    fac,
    agence,
    categ,
    SUM(remise_except) AS remise_except
FROM (
    SELECT 
        a.invdat_0 AS periode,
        a.bpcinv_0 AS tiers,
        a.num_0 AS fac,
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)) AS agence,
        SUBSTR(a.bpcinv_0, 2, 1) AS categ,
        SUM(CASE 
            WHEN SUBSTR(a.sivtyp_0, 1, 1) = 'F' THEN b.dtanot_0 * -1 
            ELSE b.dtanot_0 
        END) AS remise_except
    FROM sinvoicev a
    JOIN svcrfoot b ON a.num_0 = b.vcrnum_0
    WHERE a.invdtaamt_1 <> 0 
      AND a.invdat_0 BETWEEN TO_DATE('01/01/2018','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
      AND (
          (SUBSTR(a.sivtyp_0, 1, 1) = 'F' AND a.invdat_0 >= TO_DATE('01/01/2020','DD/MM/YYYY')) 
          OR 
          (a.sivtyp_0 IN ('AVO', 'AVP'))
      )
    GROUP BY 
        a.invdat_0, 
        a.bpcinv_0, 
        a.num_0, 
        DECODE(SUBSTR(a.bpcinv_0, 1, 1), 'X', 'C', 'Y', 'C', 'Z', 'C', SUBSTR(a.bpcinv_0, 1, 1)), 
        SUBSTR(a.bpcinv_0, 2, 1)
)
GROUP BY periode, tiers, fac, agence, categ