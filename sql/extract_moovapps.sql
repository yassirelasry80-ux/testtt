
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
  AND datecomptable >= :start_date
  AND datecomptable <= :end_date
