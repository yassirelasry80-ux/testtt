-- ====================================================================
-- EXTRACTION : MOOVAPPS (Oracle DB)
-- Base source : Moovapps Oracle
-- ====================================================================
-- Adaptez cette requête SQL selon les tables et colonnes de votre
-- base de données Moovapps.
-- Les colonnes cibles correspondent au format standard de balance_analytique :
--   - NUM_PIECE       : Identifiant de la pièce / demande / document
--   - COMPTE          : Numéro de compte comptable
--   - SENS            : Sens (1 = Débit, -1 = Crédit)
--   - AXE_CENTRE      : Axe analytique Centre de coût
--   - AXE_ENTITE      : Axe analytique Entité / Société
--   - AXE_BLINE       : Axe analytique Business Line
--   - AXE_SITE        : Axe analytique Site / Agence
--   - MONTANT         : Montant
--   - TIERS_CODE      : Code Tiers / Fournisseur / Client
--   - ARTICLE_CODE    : Code Article
--   - DATE_COMPTABLE  : Date comptable ou de la pièce
--   - SOURCE          : Identifiant de la source (ex: 'MOOVAPPS')
--   - TYPE_LIGNE      : Type de ligne (ex: 'DETAIL MOOVAPPS')
--
-- Le paramètre :start_date est disponible et passé lors de l'extraction.
-- ====================================================================

SELECT 
    sysreference AS NUM_PIECE,
    NULL AS COMPTE,
    0 AS SENS,
    centrecharge AS AXE_CENTRE,
    NULL AS AXE_ENTITE,
    NULL AS AXE_BLINE,
    'MA' || axeanalytiqueagence || '1' AS AXE_SITE,
    0.0 AS MONTANT,
    NULL AS TIERS_CODE,
    NULL AS ARTICLE_CODE,
    datecomptable AS DATE_COMPTABLE,
    'MOOVAPPS' AS SOURCE,
    'DETAIL MOOVAPPS' AS TYPE_LIGNE
FROM moovapps.r_woravance
WHERE documentstate = 'Comptabilisée'
AND  datecomptable >= :start_date
