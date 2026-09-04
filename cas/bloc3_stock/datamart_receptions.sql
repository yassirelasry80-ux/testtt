WITH base_receptions AS (
    SELECT 
        r.pthnum_0 AS num_rec, 
        r.rcpdat_0 AS date_rec, 
        r.bpsnum_0 AS fr, 
        BPONAM_0 AS nom_fr, 
        r.itmref_0 AS art, 
        r.itmdes1_0 AS des, 
        r.qtypuu_0 AS qte, 
        r.netpri_0 AS prixrcp, 
        t.chgcoe_0 AS coursprovisoirerecp, 
        p.netpri_0 AS prixcde, 
        pf.prixfac, 
        pf.coursfac, 
        DECODE(rr.stomgtcod_0, 2, 'OUI', 'NON') AS gerernstock, 
        r.prhfcy_0 AS site_rec, 
        r.pohnum_0 AS cmd, 
        r.ptdlin_0 AS ligne_rec,
        ' ' AS DI, 
        r.POPLIN_0 AS ligne_cmd,
        r.INVQTYSTU_0 AS qte_fact 
    FROM preceipt t 
    INNER JOIN preceiptd r ON t.pthnum_0 = r.pthnum_0 
    INNER JOIN itmmaster rr ON rr.itmref_0 = r.itmref_0 
    LEFT JOIN porderp p ON p.pohnum_0 = r.pohnum_0 AND p.poplin_0 = r.poplin_0 
    LEFT JOIN (
        SELECT d.pthnum_0, d.ptdlin_0, MIN(d.netpri_0) AS prixfac, MAX(e.ratmlt_0) AS coursfac 
        FROM pinvoiced d 
        INNER JOIN pinvoice e ON e.num_0 = d.num_0 
        GROUP BY d.pthnum_0, d.ptdlin_0
    ) pf ON pf.pthnum_0 = r.pthnum_0 AND pf.ptdlin_0 = r.ptdlin_0 
    WHERE t.betfcy_0 <> 2

    UNION ALL

    SELECT 
        r.PNHNUM_0,
        r.RTNDAT_0, 
        r.bpsnum_0, 
        (SELECT bpsnam_0 FROM bpsupplier s WHERE s.bpsnum_0 = r.bpsnum_0) AS nom_fr,
        r.itmref_0,
        r.itmdes1_0,
        r.qtypuu_0 * -1,
        r.netpri_0, 
        NVL((SELECT h.chgcoe_0 FROM preceipt h WHERE h.pthnum_0 = r.pthnum_0), 1), 
        p.netpri_0, 
        d.netpri_0, 
        (SELECT DISTINCT MAX(ratmlt_0) FROM pinvoice ee WHERE ee.num_0 = d.num_0), 
        DECODE(rr.STOMGTCOD_0, 2, 'OUI', 'NON'),
        r.PNHFCY_0,
        r.pohnum_0,
        r.ptdlin_0,
        ' ', 
        r.POPLIN_0,
        r.INVQTYSTU_0 
    FROM preturn t
    INNER JOIN preturnd r ON t.PNHNUM_0 = r.PNHNUM_0
    INNER JOIN itmmaster rr ON rr.itmref_0 = r.itmref_0 
    LEFT JOIN pinvoiced d ON r.PNHNUM_0 = d.PNHNUM_0 AND r.PNDLIN_0 = d.PNDLIN_0
    LEFT JOIN porderp p ON p.pohnum_0 = r.pohnum_0 AND p.poplin_0 = r.poplin_0
    WHERE r.RTNDAT_0 BETWEEN '01/01/2023' AND '31/12/2026'  
      AND t.betfcy_0 = 1 
      AND t.xstrnum_0 NOT IN ('ANR', 'AIMO')
)
SELECT 
    num_rec, 
    date_rec, 
    fr, 
    nom_fr, 
    art, 
    des, 
    qte, 
    CASE 
        WHEN prixfac IS NOT NULL AND prixrcp <> prixfac THEN prixfac 
        ELSE prixrcp 
    END AS prixrcp, 
    coursprovisoirerecp, 
    prixcde, 
    prixfac, 
    coursfac, 
    gerernstock, 
    site_rec, 
    cmd, 
    ligne_rec, 
    DI, 
    ligne_cmd, 
    qte_fact
FROM base_receptions;