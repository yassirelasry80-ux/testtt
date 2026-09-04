WITH base_mvt AS (
    -- Branche 1 : données pré-calculées depuis datamart_mvt_cmgp0
    SELECT
        rr.pthnum_0,
        rr.itmref_0,
        TO_CHAR(rr.rcpdat_0, 'YYMMDD')                                        AS mois,
        rr.qtypuu_0                                                             AS qte,
        ABS(                                                                    -- Intègre le UPDATE post-INSERT (prixrev * -1 WHERE prixrev < 0)
            ROUND(
                CASE
                    WHEN rr.xprirev_0 IS NULL
                        THEN (rr.netpri_0 * rr.ratcur) + NVL(rr.cpr2, 0)
                    ELSE NVL(rr.xprirev_0, 0)      + NVL(rr.cpr2, 0)
                END,
                6
            )
        )                                                                       AS prixrev
    FROM datamart_mvt_cmgp0 rr

    UNION ALL

    -- Branche 2 : réceptions fournisseurs filtées (preceiptd)
    SELECT
        x.pthnum_0,
        x.itmref_0,
        TO_CHAR(x.rcpdat_0, 'YYMMDD')                                          AS mois,
        x.qtypuu_0                                                              AS qte,
        ABS(x.netpri_0)                                                         AS prixrev
    FROM preceiptd x
    WHERE x.rcpdat_0 BETWEEN :date_debut AND :date_fin
      AND SUBSTR(x.bpsnum_0, 1, 1) BETWEEN '2' AND '9'

    UNION ALL

    -- Branche 3 : mouvements de stock (stojou)
    SELECT
        x.vcrnum_0,
        x.itmref_0,
        TO_CHAR(x.iptdat_0, 'YYMMDD')                                          AS mois,
        x.qtypcu_0                                                              AS qte,
        ABS(x.priord_0)                                                         AS prixrev
    FROM stojou x
    WHERE x.iptdat_0 BETWEEN :date_debut AND :date_fin
      AND (
            (   SUBSTR(x.vcrnum_0, 1, 3) IN ('BFM', 'ATL', 'ENT', 'MTK')
            AND x.trstyp_0 IN (1, 5)
            )
          OR
            (   x.vcrnum_0 NOT LIKE 'INV%'
            AND x.vcrnum_0 LIKE 'IN%'
            )
      )
),

aggregated AS (
    -- Agrégation finale commune aux 3 branches
    SELECT
        pthnum_0,
        itmref_0,
        mois,
        SUM(qte)              AS qte,
        AVG(prixrev)          AS prixrev
    FROM base_mvt
    GROUP BY
        pthnum_0,
        itmref_0,
        mois,
        qte          -- cohérent avec le GROUP BY d'origine branche 1
)

SELECT
    pthnum_0,
    itmref_0,
    mois,
    qte,
    prixrev
FROM aggregated
ORDER BY
    mois,
    pthnum_0,
    itmref_0
;