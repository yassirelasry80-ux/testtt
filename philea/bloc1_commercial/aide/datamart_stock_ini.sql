CREATE TABLE datamart_mvt_cmgp0_t AS
WITH cpr_data AS (
    SELECT 
        ii.pthnum_0,
        ii.ptdlin_0,
        MAX(ii.cpr_0) AS cpr,
        MAX(i.ratmlt_0) AS ratmlt
    FROM pinvoice i
    JOIN pinvoiced ii ON i.num_0 = ii.num_0
    WHERE i.ydanum_0 <> ' '
    GROUP BY ii.pthnum_0, ii.ptdlin_0
),
cpr2_data AS (
    SELECT 
        pa.pthnum_0,
        pa.itmref_0,
        SUM(p2.cpr_0) AS cpr2
    FROM preceiptd pa
    JOIN pinvoiced p1 
        ON pa.pthnum_0 = p1.numori_0 
       AND pa.ptdlin_0 = p1.linori_0
       AND pa.itmref_0 = p1.itmref_0
    JOIN pinvoiced p2 
        ON p1.num_0 = p2.numori_0 
       AND p1.pidlin_0 = p2.pidlin_0
    JOIN pinvoice xx 
        ON p1.num_0 = xx.num_0
    GROUP BY pa.pthnum_0, pa.itmref_0
),
change_data AS (
    SELECT 
        t.curden_0,
        MAX(t.revcours_0) KEEP (DENSE_RANK LAST ORDER BY t.chgstrdat_0) AS revcours
    FROM tabchange t
    WHERE t.chgtyp_0 = 1
    GROUP BY t.curden_0
)
SELECT
    p.pthnum_0,
    p.rcpdat_0,
    p.itmref_0,
    p.itmdes1_0,
    p.qtypuu_0,
    p.netpri_0,
    kk.xprirev_0,
    kk.mltcur_0,
    c.cpr,
    c2.cpr2,
    NVL(c.ratmlt, ch.revcours) AS ratcur
FROM preceiptd p
LEFT JOIN xgpohlin k 
    ON p.pthnum_0 = k.pthnum_0 
   AND p.ptdlin_0 = k.ptdlin_0
LEFT JOIN xgdetpri kk 
    ON k.itmref_0 = kk.itmref_0 
   AND k.xdanum_0 = kk.xdanum_0
LEFT JOIN cpr_data c 
    ON p.pthnum_0 = c.pthnum_0 
   AND p.ptdlin_0 = c.ptdlin_0
LEFT JOIN cpr2_data c2 
    ON p.pthnum_0 = c2.pthnum_0 
   AND p.itmref_0 = c2.itmref_0
LEFT JOIN preceipt pr 
    ON p.pthnum_0 = pr.pthnum_0
LEFT JOIN change_data ch 
    ON pr.cur_0 = ch.curden_0
WHERE p.rcpdat_0 BETWEEN TO_DATE('2020-01-01','YYYY-MM-DD')
                      AND TO_DATE('2026-12-31','YYYY-MM-DD')
  AND p.bpsnum_0 >= '0' 
  AND p.bpsnum_0 < '2';
  
/


create table datamart_mvt_cmgp_t as 
(SELECT
    pthnum_0,
    itmref_0,
    mois,
    SUM(qte) qte,
    AVG(prixrev) prixrev
FROM (
    
    /* SOURCE 1 */
    SELECT
        rr.pthnum_0,
        rr.itmref_0,
        TRUNC(rr.rcpdat_0) AS mois,
        rr.qtypuu_0 AS qte,
        CASE
            WHEN (CASE 
                    WHEN rr.xprirev_0 IS NULL 
                    THEN (rr.netpri_0 * rr.ratcur) + NVL(rr.cpr2,0)
                    ELSE rr.xprirev_0 + NVL(rr.cpr2,0)
                  END) < 0
            THEN ABS(
                  CASE 
                      WHEN rr.xprirev_0 IS NULL 
                      THEN (rr.netpri_0 * rr.ratcur) + NVL(rr.cpr2,0)
                      ELSE rr.xprirev_0 + NVL(rr.cpr2,0)
                  END)
            ELSE
                  CASE 
                      WHEN rr.xprirev_0 IS NULL 
                      THEN (rr.netpri_0 * rr.ratcur) + NVL(rr.cpr2,0)
                      ELSE rr.xprirev_0 + NVL(rr.cpr2,0)
                  END
        END AS prixrev
    FROM datamart_mvt_cmgp0_t rr
    UNION ALL
    SELECT
        x.pthnum_0,
        x.itmref_0,
        TRUNC(x.rcpdat_0) AS mois,
        SUM(x.qtypuu_0) AS qte,
        CASE 
            WHEN x.netpri_0 < 0 THEN ABS(x.netpri_0)
            ELSE x.netpri_0
        END AS prixrev
    FROM preceiptd x
    WHERE x.rcpdat_0 BETWEEN DATE '2020-01-01' AND DATE '2026-12-31'
      AND SUBSTR(x.bpsnum_0,1,1) BETWEEN '2' AND '9'
    GROUP BY x.pthnum_0, x.itmref_0, TRUNC(x.rcpdat_0), x.netpri_0
    UNION ALL
    SELECT
        x.vcrnum_0 AS pthnum_0,
        x.itmref_0,
        TRUNC(x.iptdat_0) AS mois,
        SUM(x.qtypcu_0) AS qte,
        CASE 
            WHEN x.priord_0 < 0 THEN ABS(x.priord_0)
            ELSE x.priord_0
        END AS prixrev
    FROM stojou x
    WHERE (
            (SUBSTR(x.vcrnum_0,1,3) IN ('BFM','ATL','ENT','MTK')
             AND x.iptdat_0 BETWEEN DATE '2020-01-01' AND DATE '2026-12-31'
             AND x.trstyp_0 IN (1,5))
          OR 
            (x.vcrnum_0 NOT LIKE 'INV%' 
             AND x.vcrnum_0 LIKE 'IN%'
             AND x.iptdat_0 BETWEEN DATE '2020-01-01' AND DATE '2026-12-31')
          )
    GROUP BY x.vcrnum_0, x.itmref_0, TRUNC(x.iptdat_0), x.priord_0
)

GROUP BY pthnum_0, itmref_0, mois);
/



WITH datamart_sta_art_glb AS (
    SELECT 
        vv1.itmref_0 AS code,
        SUM(
            DECODE(v1.gte_0,'FAC',vv1.qty_0,0) +
            DECODE(v1.gte_0,'FCP',vv1.qty_0,0) -
            DECODE(v1.gte_0,'AVC',vv1.qty_0,0) -
            DECODE(v1.gte_0,'AVP',vv1.qty_0,0) -
            DECODE(v1.gte_0,'AFV',vv1.qty_0,0)
        ) AS qte
    FROM sinvoice v1
    JOIN sinvoiced vv1 ON v1.num_0 = vv1.num_0
    WHERE v1.accdat_0 BETWEEN DATE '2020-01-01' AND DATE '2026-12-31'
      AND v1.bpr_0 LIKE 'Y%'
    GROUP BY vv1.itmref_0
),
mvt AS (
    SELECT 
        itmref_0,
        mois,
        prixrev,
        SUM(qte) qte
    FROM datamart_mvt_cmgp_t
    GROUP BY itmref_0, mois, prixrev
),
stock AS (
    SELECT code AS itmref_0, qte AS stock
    FROM datamart_sta_art_glb
),
fifo_calc AS (
    SELECT 
        m.itmref_0,
        m.mois,
        m.prixrev,
        m.qte,
        s.stock,
        SUM(m.qte) OVER (
            PARTITION BY m.itmref_0 
            ORDER BY m.mois DESC
        ) cumul_qte
    FROM mvt m
    JOIN stock s ON s.itmref_0 = m.itmref_0
),
fifo_final AS (
    SELECT 
        itmref_0,
        prixrev,
        CASE 
            WHEN cumul_qte <= stock THEN qte
            WHEN cumul_qte - qte < stock THEN stock - (cumul_qte - qte)
            ELSE 0
        END qte_fifo
    FROM fifo_calc
)

(SELECT 
    s.itmref_0 AS code,
    s.stock,
    NVL(
        SUM(f.prixrev * f.qte_fifo) / NULLIF(SUM(f.qte_fifo),0),
        0
    ) prixrev,
    TO_CHAR(DATE '2019-01-01','DD/MM/YYYY') dat_fifo
FROM stock s
LEFT JOIN fifo_final f 
    ON f.itmref_0 = s.itmref_0
GROUP BY s.itmref_0, s.stock)  

/

DROP TABLE datamart_mvt_cmgp0_t PURGE;
DROP TABLE datamart_mvt_cmgp_t PURGE;
/