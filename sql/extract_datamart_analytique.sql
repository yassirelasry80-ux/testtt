SELECT 
    num_0 AS NUM_PIECE,
    acc_0 AS COMPTE,
    
    NVL(sns_0, CASE WHEN NVL(amtled_0, amtcur_0) < 0 THEN -1 ELSE 1 END) AS SENS,

    NVL(cce_4) AS AXE_CENTRE,
    NVL(cce_7)     AS AXE_ENTITE,
    NVL(cce_5) AS AXE_BLINE,
    NVL(cce_6) AS AXE_SITE,

    ABS(NVL(amtled_0, amtcur_0)) AS MONTANT,

    NULL AS TIERS_CODE,
    NULL AS ARTICLE_CODE,
    accdat_0 AS DATE_COMPTABLE,

    'DATAMART_ANALYTIQUE' AS SOURCE,
    'DETAIL OD'           AS TYPE_LIGNE

FROM datamart_analytique

WHERE accdat_0 >= :start_date
  AND num_0 NOT IN (
      SELECT DISTINCT NUM_PIECE 
      FROM balance_analytique
      WHERE NUM_PIECE IS NOT NULL
  )
