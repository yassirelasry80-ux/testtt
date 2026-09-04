WITH frs_max AS (
    SELECT itmref_0, MAX(bpsnum_0) AS bpsnum_0
    FROM itmbps
    GROUP BY itmref_0
),
frs AS (
    SELECT u.itmref_0,
           u.bpsnum_0,
           t.bpsnam_0
    FROM frs_max u
    LEFT JOIN bpsupplier t
        ON t.bpsnum_0 = u.bpsnum_0
)

SELECT
    x.sdhnum_0 AS bl,
    y.sddlin_0 AS lig,

    DECODE(SUBSTR(x.bpcord_0,7,1),
           'X','C','Y','C','Z','C',
           SUBSTR(x.bpcord_0,7,1)) AS agence,

    x.dlvdat_0 AS date_bl,
    x.bpcord_0 AS tiers,

    y.itmref_0 AS Article,
    y.itmdes1_0 AS Lib_art_bl,

    y.tsicod_0 AS FC,
    y.tsicod_1 AS FT,
    y.tsicod_2 AS FD,

    y.tsicod_0 AS FCMKT,
    ' ' AS FCLIBMKT,
    y.tsicod_1 AS FTMKT,
    ' ' AS FTLIBMKT,
    y.tsicod_2 AS FDMKT,
    ' ' AS FDLIBMKT,

    y.gropri_0 AS tarif,
    y.qty_0 AS qte,

    (y.qty_0 * y.netpri_0) AS HTN,
    (y.qty_0 * y.gropri_0) AS HTB,

    SUBSTR(x.bpcord_0,2,1) AS categ,

    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,

    frs.bpsnum_0 AS frs,
    frs.bpsnam_0 AS lib_frs2,

    ' ' AS xclasse

FROM sdelivery x
JOIN sdeliveryd y
    ON x.sdhnum_0 = y.sdhnum_0

LEFT JOIN frs
    ON frs.itmref_0 = y.itmref_0

WHERE x.sdhnum_0 LIKE 'B%'
  AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND x.invflg_0 = 1
  AND x.bpcord_0 NOT LIKE 'PZ%'