WITH projet_dates AS (
    SELECT projet_analytique, MIN(date_depot) as date_cloture
    FROM suivinst.i_projet
    WHERE projet_analytique IS NOT NULL
    GROUP BY projet_analytique
)
SELECT /*+ parallel(xp, 4) */ DISTINCT 
    xp.sdhnum_0, xp.bpcord_0, xp.sohnum_0, xp.axeproj_0, xp.cusquoref_0,
    pd.date_cloture
FROM xprojet xp
LEFT JOIN projet_dates pd ON xp.axeproj_0 = pd.projet_analytique
WHERE xp.axeproj_0 IS NOT NULL

-- oblige d integrer hint optimizer sinon ca dure