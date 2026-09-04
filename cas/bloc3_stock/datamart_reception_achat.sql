SELECT 
    r.pthnum_0 AS num_rec,
    r.rcpdat_0 AS date_rec,
    r.bpsnum_0 AS fr,
    bponam_0 AS nom_fr,
    r.itmref_0 AS art,
    r.itmdes1_0 AS des,
    r.qtypuu_0 AS qte,
    COALESCE(pf.prixfac, r.netpri_0) AS prixrcp, 
    t.chgcoe_0 AS coursprovisoirerecp,
    p.netpri_0 AS prixcde,
    pf.prixfac,
    pf.coursfac,
    DECODE(rr.stomgtcod_0, 2, 'OUI', 'NON') AS gerernstock,
    r.prhfcy_0 AS site_rec,
    r.pohnum_0 AS cmd,
    r.ptdlin_0 AS ligne_rec 
FROM preceipt t 
JOIN preceiptd r ON t.pthnum_0 = r.pthnum_0 
JOIN itmmaster rr ON rr.itmref_0 = r.itmref_0 
LEFT JOIN porderp p ON p.pohnum_0 = r.pohnum_0 AND p.poplin_0 = r.poplin_0 
LEFT JOIN (
    SELECT d.pthnum_0, d.ptdlin_0, MIN(d.netpri_0) AS prixfac, MAX(e.ratmlt_0) AS coursfac 
    FROM pinvoiced d 
    LEFT JOIN pinvoice e ON e.num_0 = d.num_0 
    GROUP BY d.pthnum_0, d.ptdlin_0
) pf ON pf.pthnum_0 = r.pthnum_0 AND pf.ptdlin_0 = r.ptdlin_0 
WHERE t.betfcy_0 <> 2