-- ====================================================================
-- EXTRACTION : COMMERCIAL06 (Avoirs Financiers AF / RFA)
-- Base source : Sage X3 Prod (Oracle X3)
-- ====================================================================

SELECT 
    x.num_0 AS NUM_PIECE,
    x.accdat_0 AS DATE_COMPTABLE,
    x.bpr_0 AS TIERS_CODE,
    y.itmref_0 AS ARTICLE_CODE,

    ABS(y.qty_0 * y.netpri_0 * NVL(x.ratmlt_0, 1)) AS MONTANT,

    DECODE(SUBSTR(x.gte_0, 1, 1), 'F', 1, 'A', -1) AS SENS,

    c.cce_4 AS AXE_CENTRE,
    c.cce_5 AS AXE_BLINE,
    c.cce_6 AS AXE_SITE,
    c.cce_7 AS AXE_ENTITE,

    DECODE(SUBSTR(x.bpr_0, 1, 1), 
           'P', '71241000',
           'D', '71110000',
           '71110000'
    ) AS COMPTE,

    'COMMERCIAL06'       AS SOURCE,
    'DETAIL AVOIR FACT'  AS TYPE_LIGNE

FROM sinvoice x
JOIN sinvoiced y ON x.num_0 = y.num_0
JOIN itmmaster t ON t.itmref_0 = y.itmref_0
LEFT JOIN cptanalin c ON c.vcrnum_0 = y.num_0
                     AND c.vcrlin_0 = y.sidlin_0

WHERE x.accdat_0 >= :start_date
  AND SUBSTR(x.num_0, 1, 2) = 'AF'
