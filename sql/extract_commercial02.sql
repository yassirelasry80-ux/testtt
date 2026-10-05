-- ====================================================================
-- EXTRACTION : COMMERCIAL02 (Chiffre d'Affaires Lignes Ventes)
-- Base source : Oracle BI (Schéma bi_{entite_name})
-- ====================================================================

SELECT 
    BL AS NUM_PIECE,
    COMPTE,
    CASE 
        WHEN NVL(HTN, 0) < 0 THEN -1 
        ELSE 1 
    END AS SENS,
    CCE_4 AS AXE_CENTRE,
    CCE_7 AS AXE_ENTITE,
    CCE_5 AS AXE_BLINE,
    CCE_6 AS AXE_SITE,
    ABS(NVL(HTN, 0)) AS MONTANT,
    TIERS AS TIERS_CODE,
    ARTICLE AS ARTICLE_CODE,
    DATE_BL AS DATE_COMPTABLE,
    'COMMERCIAL02' AS SOURCE,
    'DETAIL CA' AS TYPE_LIGNE
FROM commercial02
WHERE DATE_BL >= :start_date
