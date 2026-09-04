SELECT 
    r.pthnum_0        AS num_rec,
    r.rcpdat_0        AS date_rec,
    r.bpsnum_0        AS fr,

    s.bpsnam_0        AS nom_fr,

    r.itmref_0        AS art,
    r.itmdes1_0       AS des,
    r.qtypuu_0        AS qte,
    r.netpri_0        AS prixrcp,
    t.chgcoe_0        AS coursprovisoirerecp,
    p.netpri_0        AS prixcde,
    d.netpri_0        AS prixfac,

    (
        SELECT MAX(ee.ratmlt_0)
        FROM pinvoice ee
        WHERE ee.num_0 = d.num_0
    ) AS coursfac,

    CASE 
        WHEN rr.STOMGTCOD_0 = 2 THEN 'OUI'
        ELSE 'NON'
    END AS gerernstock

FROM preceiptd r

JOIN preceipt t 
    ON t.pthnum_0 = r.pthnum_0

JOIN itmmaster rr 
    ON rr.itmref_0 = r.itmref_0

LEFT JOIN bpsupplier s 
    ON s.bpsnum_0 = r.bpsnum_0

LEFT JOIN pinvoiced d 
    ON d.pthnum_0 = r.pthnum_0 
   AND d.ptdlin_0 = r.ptdlin_0

LEFT JOIN porderp p 
    ON p.pohnum_0 = r.pohnum_0 
   AND p.poplin_0 = r.poplin_0

WHERE r.rcpdat_0 BETWEEN TO_DATE('01/01/2022','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')