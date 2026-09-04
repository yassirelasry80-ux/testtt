WITH base_data AS (
    SELECT
        a.invdat_0                                      AS periode,
        a.bpcinv_0                                      AS tiers,
        DECODE(LENGTH(a.bpcinv_0), 6,
            SUBSTR(a.bpcinv_0, 1, 1),
            SUBSTR(a.bpcinv_0, 7, 1))                   AS agence,
        SUBSTR(a.bpcinv_0, 1, 2)                        AS categ,
        DECODE(SUBSTR(a.num_0, 1, 1),
            'F', 'N',
            'P', 'P',
            DECODE(SUBSTR(a.num_0, 1, 2),
                'AP', 'P',
                'AV', 'P'))                             AS proj,
        b.dtanot_0 * ratmlt_0                        AS montant_brut,
        SUBSTR(a.sivtyp_0, 1, 1)                        AS type_piece
    FROM       sinvoicev  a
    INNER JOIN sinvoice   e  ON e.num_0    = a.num_0
    INNER JOIN svcrfoot   b  ON b.vcrnum_0 = a.num_0
    WHERE a.invdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
      AND a.invdtaamt_1 <> 0
      AND SUBSTR(a.sivtyp_0, 1, 1) IN ('F', 'A')
),

remises_par_piece AS (
    SELECT
        periode,
        tiers,
        agence,
        categ,
        proj,
        SUM(
            CASE type_piece
                WHEN 'F' THEN montant_brut * -1
                ELSE          montant_brut
            END
        ) AS remise_except
    FROM base_data
    GROUP BY
        periode,
        tiers,
        agence,
        categ,
        proj,
        type_piece
)

SELECT
    periode,
    tiers,
    agence,
    categ,
    proj,
    SUM(remise_except) AS remise_except
FROM remises_par_piece
GROUP BY
    periode,
    tiers,
    agence,
    categ,
    proj
ORDER BY
    periode,
    tiers