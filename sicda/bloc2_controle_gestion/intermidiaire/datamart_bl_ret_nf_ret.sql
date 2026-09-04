SELECT
    xx.srhnum_0 AS numret,
    yy.srdlin_0 AS lig,

    DECODE(
        SUBSTR(xx.bpcord_0, 7, 1),
        'X', 'C',
        'Y', 'C',
        'Z', 'C',
        SUBSTR(xx.bpcord_0, 7, 1)
    ) AS ag,

    xx.rtndat_0 AS date_bl,
    xx.bpcord_0 AS tiers,

    yy.itmref_0 AS article,
    yy.itmdes1_0 AS lib,

    (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FCMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FTMKT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FDMKT,

    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FC,
    ' ' AS FCLIBMKT,

    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FT,
    ' ' AS FTLIBMKT,

    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) AS FD,
    ' ' AS FDLIBMKT,

    yy.netpri_0 AS tarif,
    yy.qty_0 * -1 AS qte,
    (yy.qty_0 * yy.netpri_0) * -1 AS HTN,
    (yy.qty_0 * yy.netpri_0) * -1 AS HTB,

    SUBSTR(xx.bpcord_0, 2, 1) AS categ,
    ' ' AS proj,
    ' ' AS canal,
    ' ' AS sicda,
    ' ' AS ARTF,

    (SELECT MAX(u.bpsnum_0)
     FROM itmbps u
     WHERE u.itmref_0 = yy.itmref_0) AS frs,

    (SELECT t.bpsnam_0
     FROM bpsupplier t
     WHERE t.bpsnum_0 = (
         SELECT MAX(u.bpsnum_0)
         FROM itmbps u
         WHERE u.itmref_0 = yy.itmref_0
     )) AS lib_frs2,

    (SELECT ' '
     FROM bpcustomer f
     WHERE f.bpcnum_0 = xx.bpcord_0) AS xclasse

FROM sreturn xx
JOIN sreturnd yy
    ON xx.srhnum_0 = yy.srhnum_0

WHERE
    xx.rtndat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')
                    AND TO_DATE('31/12/2026','DD/MM/YYYY')

    AND (xx.srhnum_0 LIKE 'RV%' OR xx.srhnum_0 LIKE 'RP%')

    AND (yy.srhnum_0, yy.srdlin_0) NOT IN (
        SELECT pp.srhnum_0, pp.srdlin_0
        FROM sinvoiced pp
        WHERE pp.invdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')
                              AND TO_DATE('31/12/2026','DD/MM/YYYY')
          AND pp.srhnum_0 <> ' '
          AND pp.bpcinv_0 = xx.bpcord_0
    )

    AND xx.bpcord_0 NOT LIKE 'PZ%'