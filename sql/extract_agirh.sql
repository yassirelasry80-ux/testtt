-- ====================================================================
-- EXTRACTION : AGIRH (Comptabilité analytique Paie AGIRH)
-- Base source : AGIRH SQL Server
-- ====================================================================

SELECT *
FROM [AGIRH_CMPG].[dbo].[COMPTA_ANALYTIQUE_CMGP_SI]
WHERE [DT_COMPTA] IN ({placeholders})
  AND [CODE_interne] LIKE '6%'
