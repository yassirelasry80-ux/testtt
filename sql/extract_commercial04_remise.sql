-- ====================================================================
-- EXTRACTION : COMMERCIAL04 (Remises Exceptionnelles en pied de facture)
-- Base source : Sage X3 Prod (Oracle X3)
-- ====================================================================

SELECT 
    a.num_0 AS NUM_PIECE,

    DECODE(
        SUBSTR(a.bpcinv_0, 1, 1),
        'P', '71241000',
        'D', '71110000',
        '71110000'
    ) AS COMPTE,

    DECODE(SUBSTR(a.sivtyp_0, 1, 1), 'F', -1, 'A', 1, -1) AS SENS,

    c.cce_4 AS AXE_CENTRE,
    c.cce_7 AS AXE_ENTITE,
    c.cce_5 AS AXE_BLINE,
    c.cce_6 AS AXE_SITE,

    ABS(b.dtanot_0 * NVL(e.ratmlt_0, 1)) AS MONTANT,

    a.bpcinv_0 AS TIERS_CODE,
    NULL       AS ARTICLE_CODE,
    a.invdat_0 AS DATE_COMPTABLE,

    'COMMERCIAL04'  AS SOURCE,
    'DETAIL REMISE' AS TYPE_LIGNE

FROM sinvoicev a
JOIN svcrfoot b   ON a.num_0 = b.vcrnum_0
JOIN sinvoice e   ON e.num_0 = a.num_0
LEFT JOIN cptanalin c ON c.vcrnum_0 = a.num_0 
                     AND c.vcrlin_0 = 0

WHERE a.invdat_0 >= :start_date
  AND a.invdtaamt_1 <> 0
  AND SUBSTR(a.sivtyp_0, 1, 1) IN ('F', 'A')
