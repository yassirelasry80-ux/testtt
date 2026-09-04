SELECT
    x.sdhnum_0 bl,
    y.sddlin_0 lig,
    DECODE(SUBSTR(x.bpcord_0,1,1),
        'X','C','Y','C','Z','C',
        SUBSTR(x.bpcord_0,1,1)
    ) agence,
    x.dlvdat_0 date_bl,
    x.bpcord_0 tiers,
    y.itmref_0 article,
    y.itmdes1_0 lib_art_bl,
    y.tsicod_0 FC,
    y.tsicod_1 FT,
    y.tsicod_2 FD,
    y.tsicod_0 FCMKT,
    ' ' FCLIBMKT,
    y.tsicod_1 FTMKT,
    ' ' FTLIBMKT,
    y.tsicod_2 FDMKT,
    ' ' FDLIBMKT,
    y.gropri_0 tarif,
    y.qty_0 qte,
    (y.qty_0 * y.netpri_0) HTN,
    (y.qty_0 * y.gropri_0) HTB,
    SUBSTR(x.bpcord_0,2,1) categ,
    ' ' proj,
    ' ' canal,
    ' ' sicda,
    ' ' ARTF,

    (SELECT MAX(u.bpsnum_0)
     FROM itmbps u
     WHERE u.itmref_0 = y.itmref_0) frs,

    (SELECT t.bpsnam_0
     FROM bpsupplier t
     WHERE t.bpsnum_0 =
        (SELECT MAX(u.bpsnum_0)
         FROM itmbps u
         WHERE u.itmref_0 = y.itmref_0)
    ) lib_frs2,

    ' ' xclasse

FROM sdelivery x, sdeliveryd y
WHERE x.sdhnum_0 = y.sdhnum_0
  AND x.sdhnum_0 LIKE 'B%'
  AND x.dlvdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND x.invflg_0 = 1
  AND x.bpcord_0 NOT LIKE 'PZ%'


UNION


SELECT
    xx.srhnum_0 numret,
    yy.srdlin_0 lig,
    DECODE(SUBSTR(xx.bpcord_0,1,1),
        'X','C','Y','C','Z','C',
        SUBSTR(xx.bpcord_0,1,1)
    ) ag,
    xx.rtndat_0 date_bl,
    xx.bpcord_0 tiers,
    yy.itmref_0 article,
    yy.itmdes1_0 lib,

    (SELECT tt.tsicod_0 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FCMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FTMKT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FDMKT,

    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FC,
    ' ' FCLIBMKT,
    (SELECT tt.tsicod_1 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FT,
    ' ' FTLIBMKT,
    (SELECT tt.tsicod_2 FROM itmmaster tt WHERE tt.itmref_0 = yy.itmref_0) FD,
    ' ' FDLIBMKT,

    yy.netpri_0 tarif,
    yy.qty_0 * -1 qte,
    (yy.qty_0 * yy.netpri_0) * -1 HTN,
    (yy.qty_0 * yy.netpri_0) * -1 HTB,

    SUBSTR(xx.bpcord_0,2,1) categ,
    ' ' proj,
    ' ' canal,
    ' ' sicda,
    ' ' ARTF,

    (SELECT MAX(u.bpsnum_0)
     FROM itmbps u
     WHERE u.itmref_0 = yy.itmref_0) frs,

    (SELECT t.bpsnam_0
     FROM bpsupplier t
     WHERE t.bpsnum_0 =
        (SELECT MAX(u.bpsnum_0)
         FROM itmbps u
         WHERE u.itmref_0 = yy.itmref_0)
    ) lib_frs2,

    ' ' xclasse

FROM sreturn xx, sreturnd yy
WHERE xx.srhnum_0 = yy.srhnum_0
  AND xx.rtndat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')
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