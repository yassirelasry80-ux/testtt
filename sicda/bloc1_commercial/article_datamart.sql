SELECT DISTINCT
    e.tclcod_0   AS categ_art,
    e.tsicod_0   AS FC,
    e.tsicod_1   AS FT,
    e.tsicod_2   AS FD,

    e.itmref_0   AS article,
    e.des1axx_0  AS lib_article,

    NVL(
        (SELECT t.baspri_0
         FROM itmsales t
         WHERE t.itmref_0 = e.itmref_0),
        0
    ) AS tarif,

    e.vacitm_0   AS regime,

    (SELECT MAX(u.bpsnum_0)
     FROM itmbps u
     WHERE u.itmref_0 = e.itmref_0
    ) AS art_frs,

    (SELECT tt.bpsnam_0
     FROM bpsupplier tt
     WHERE tt.bpsnum_0 =
           (SELECT MAX(u.bpsnum_0)
            FROM itmbps u
            WHERE u.itmref_0 = e.itmref_0)
    ) AS lib_frs,

    e.itmwei_0   AS poids,
    e.xbusline_0,
    e.xsbusline_0,
    e.xcentre_0

FROM itmmaster e