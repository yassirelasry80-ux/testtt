-- ============================================================
-- BIND VARIABLES Python : :date_debut / :date_fin
-- Exemple d'appel :
--   cursor.execute(sql, date_debut='01/01/2024', date_fin='31/12/2024')
-- ============================================================

WITH
-- ─── Bloc 1 : Données de facturation (SINVOICE) ──────────────
fac AS (
    SELECT
        vv1.itmref_0,
        SUM(
            CASE v1.gte_0
                WHEN 'FAC' THEN  vv1.qty_0
                WHEN 'FCP' THEN  vv1.qty_0
                WHEN 'AVC' THEN -vv1.qty_0
                WHEN 'AVP' THEN -vv1.qty_0
                WHEN 'AFV' THEN -vv1.qty_0
                ELSE 0
            END
        )                          AS qte,
        SUM(
            CASE v1.gte_0
                WHEN 'FAC' THEN  vv1.amtnotlin_0
                WHEN 'FCP' THEN  vv1.amtnotlin_0
                WHEN 'AVC' THEN -vv1.amtnotlin_0
                WHEN 'AVP' THEN -vv1.amtnotlin_0
                WHEN 'AFV' THEN -vv1.amtnotlin_0
                ELSE 0
            END
        )                          AS ca_net_ht
    FROM      sinvoice  v1
    INNER JOIN sinvoiced vv1 ON v1.num_0 = vv1.num_0
    WHERE v1.accdat_0 BETWEEN :date_debut AND :date_fin
    GROUP BY vv1.itmref_0
),

-- ─── Bloc 2 : Livraisons non facturées (SDELIVERY) ───────────
liv AS (
    SELECT
        vv2.itmref_0,
        SUM(vv2.qty_0)                        AS qte,
        SUM(vv2.netprinot_0 * vv2.qty_0)      AS ca_net_ht
    FROM      sdelivery  v2
    INNER JOIN sdeliveryd vv2 ON v2.sdhnum_0 = vv2.sdhnum_0
    WHERE v2.dlvdat_0  BETWEEN :date_debut AND :date_fin
      AND v2.invflg_0  = 1
      AND v2.betfcy_0  = 1
      AND v2.sdhnum_0  LIKE 'B%'
      AND v2.bpcord_0  NOT IN ('A','B','C','D','E','G','I','J','K','L','M','N','Q','S','T','U','MKT')
    GROUP BY vv2.itmref_0
),

-- ─── Bloc 3a : Retours dans la période (candidats) ───────────
ret_candidats AS (
    SELECT
        vv.itmref_0,
        v.srhnum_0,
        vv.srdlin_0,
        vv.qty_0,
        vv.netpri_0,
        v.bpcord_0
    FROM      sreturn  v
    INNER JOIN sreturnd vv ON v.srhnum_0 = vv.srhnum_0
    WHERE v.rtndat_0  BETWEEN :date_debut AND :date_fin
      AND v.betfcy_0  = 1
      AND v.bpcord_0  NOT IN ('A','B','C','D','E','G','I','J','K','L','M','N','Q','S','T','U','MKT')
),

-- ─── Bloc 3b : Lignes de retours déjà avoirs (AVC/AVP) ───────
ret_avoirs AS (
    SELECT DISTINCT bb.srhnum_0, bb.srdlin_0, b.bpr_0
    FROM      sinvoice  b
    INNER JOIN sinvoiced bb ON b.num_0 = bb.num_0
    WHERE b.gte_0 IN ('AVC', 'AVP')
),

-- ─── Bloc 3 : Retours nets (candidats MINUS avoirs) ──────────
ret AS (
    SELECT
        rc.itmref_0,
        SUM(-rc.qty_0)                  AS qte,
        SUM(-rc.netpri_0 * rc.qty_0)   AS ca_net_ht
    FROM  ret_candidats rc
    WHERE NOT EXISTS (
        SELECT 1
        FROM   ret_avoirs ra
        WHERE  ra.srhnum_0 = rc.srhnum_0
          AND  ra.srdlin_0 = rc.srdlin_0
          AND  ra.bpr_0    = rc.bpcord_0
    )
    GROUP BY rc.itmref_0
),

-- ─── Union des 3 flux ────────────────────────────────────────
tous_flux AS (
    SELECT itmref_0, qte, ca_net_ht FROM fac
    UNION ALL
    SELECT itmref_0, qte, ca_net_ht FROM liv
    UNION ALL
    SELECT itmref_0, qte, ca_net_ht FROM ret
),

-- ─── Agrégation finale ───────────────────────────────────────
agreg AS (
    SELECT
        itmref_0,
        SUM(qte)       AS qte,
        SUM(ca_net_ht) AS ca_net_ht
    FROM  tous_flux
    GROUP BY itmref_0
)

-- ─── Enrichissement article (1 seule jointure ITMMASTER) ─────
SELECT
    im.tsicod_2   AS fam,
    ag.itmref_0   AS code,
    im.des1axx_0  AS libelle,
    ag.qte,
    ag.ca_net_ht
FROM       agreg    ag
LEFT OUTER JOIN itmmaster im ON im.itmref_0 = ag.itmref_0
ORDER BY ag.itmref_0