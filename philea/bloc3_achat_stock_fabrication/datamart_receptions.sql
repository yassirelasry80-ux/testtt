SELECT 
    r.pthnum_0 num_rec,
    r.rcpdat_0 date_rec,
    r.bpsnum_0 fr,
    (SELECT bpsnam_0 FROM bpsupplier s WHERE s.bpsnum_0 = r.bpsnum_0) nom_fr,
    r.itmref_0 art,
    r.itmdes1_0 des,
    r.qtypuu_0 qte,
    r.netpri_0 prixrcp,
    t.chgcoe_0 coursprovisoirerecp,
    p.netpri_0 prixcde,
    d.netpri_0 prixfac,
    (SELECT DISTINCT MAX(ratmlt_0) FROM pinvoice ee WHERE ee.num_0 = d.num_0) coursfac,
    DECODE(rr.STOMGTCOD_0, 2, 'OUI', 'NON') gerernstock 
FROM 
    preceipt t,
    preceiptd r,
    itmmaster rr,
    pinvoiced d,
    porderp p 
WHERE 
    t.pthnum_0 = r.pthnum_0 
    AND rr.itmref_0 = r.itmref_0 
    AND r.rcpdat_0 BETWEEN '01/01/2021' AND '31/12/2025' 
    AND r.pthnum_0 = d.pthnum_0(+) 
    AND r.ptdlin_0 = d.ptdlin_0(+) 
    AND p.pohnum_0(+) = r.pohnum_0 
    AND p.poplin_0(+) = r.poplin_0