SELECT 
    num_0 AS NUM_PIECE,
    acc_0 AS COMPTE,
    
    NVL(sns_0, CASE WHEN NVL(amtled_0, amtcur_0) < 0 THEN -1 ELSE 1 END) AS SENS,

    cce_4 AS AXE_CENTRE,
    cce_7    AS AXE_ENTITE,
    cce_5 AS AXE_BLINE,
    cce_6 AS AXE_SITE,

    ABS(NVL(amtled_0, amtcur_0)) AS MONTANT,

    NULL AS TIERS_CODE,
    NULL AS ARTICLE_CODE,
    accdat_0 AS DATE_COMPTABLE,

    'DATAMART_ANALYTIQUE' AS SOURCE,
    'DETAIL OD'           AS TYPE_LIGNE

FROM datamart_analytique

WHERE accdat_0 >= :start_date
  AND accdat_0 <= :end_date
  AND acc_0 NOT LIKE '7%' AND acc_0 NOT LIKE '611%'

  AND num_0 NOT IN 
    (
        SELECT DISTINCT NUM_PIECE 
        FROM balance_analytique
        WHERE SOURCE <> 'DATAMART_ANALYTIQUE' 
        AND DATE_COMPTABLE >= :start_date
        AND DATE_COMPTABLE <= :end_date
    )
