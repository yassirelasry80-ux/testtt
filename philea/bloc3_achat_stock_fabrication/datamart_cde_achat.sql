SELECT
    a.pohnum_0,
    a.bpsnum_0,
    a.pohfcy_0,
    a.bprnam_0,
    a.orddat_0,
    a.rcpflg_0,
    a.invflg_0,
    a.xstatus_0,
    a.xetape_0,
    a.xetaped2_0,
    b.itmref_0,
    b.itmdes1_0,
    b.netpri_0,
    b.vat_0,
    c.qtypuu_0,
    c.rcpqtypuu_0,
    c.rcpcleflg_0,
    a.cur_0
FROM porder  a
JOIN porderp b
    ON b.pohnum_0 = a.pohnum_0
JOIN porderq c
    ON c.pohnum_0 = b.pohnum_0
   AND c.poplin_0 = b.poplin_0
   AND c.poqseq_0 = b.popseq_0
WHERE a.orddat_0 >= TO_DATE('01/01/2021','DD/MM/YYYY')