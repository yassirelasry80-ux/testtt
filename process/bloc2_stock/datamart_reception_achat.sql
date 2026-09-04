SELECT 
    r.pthnum_0 AS num_rec,
    r.rcpdat_0 AS date_rec,
    r.bpsnum_0 AS fr,
    t.BPONAM_0 AS nom_fr,
    r.itmref_0 AS art,
    r.itmdes1_0 AS des,
    r.qtypuu_0 AS qte,
    r.netpri_0 AS prixrcp,
    t.chgcoe_0 AS coursprovisoirerecp,
    p.netpri_0 AS prixcde,
    d.netpri_0 AS prixfac,
    sub_inv.ratmlt_0 AS coursfac,
    DECODE(rr.STOMGTCOD_0, 2, 'OUI', 'NON') AS gerernstock,
    r.prhfcy_0 AS site_rec,
    r.pohnum_0 AS cmd,
    r.ptdlin_0 AS ligne_rec 
FROM preceiptd r
JOIN preceipt t 
    ON t.pthnum_0 = r.pthnum_0
JOIN itmmaster rr 
    ON rr.itmref_0 = r.itmref_0  
LEFT JOIN pinvoiced d 
    ON r.pthnum_0 = d.pthnum_0 
   AND r.ptdlin_0 = d.ptdlin_0
LEFT JOIN porderp p 
    ON p.pohnum_0 = r.pohnum_0 
   AND p.poplin_0 = r.poplin_0
LEFT JOIN (
    SELECT num_0, MAX(ratmlt_0) AS ratmlt_0 
    FROM pinvoice 
    GROUP BY num_0
) sub_inv 
    ON sub_inv.num_0 = d.num_0
WHERE t.BETFCY_0 <> 2