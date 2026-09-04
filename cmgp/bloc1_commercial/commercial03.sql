select 
    x.num_0 fac,
    decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)) agence,
    x.accdat_0 date_fac,
    x.bpr_0 tiers,
    y.itmref_0 article,
    y.itmdes1_0 lib_art_fac,
    y.tsicod_0 FC,
    y.tsicod_1 FT,
    y.tsicod_2 FD,
    xfc_0 FCMKT,
    xfclib_0 FCLIBMKT,
    xfT_0 FTMKT,
    xfTlib_0 FTLIBMKT,
    xfD_0 FDMKT,
    xfDlib_0 FDLIBMKT,
    y.gropri_0 * ratmlt_0 tarif,
    decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0 * -1) qte,
    decode(
        substr(x.gte_0,1,1),
        'F',
        (y.qty_0 * y.netpri_0 * ratmlt_0),
        'A',
        (y.qty_0 * y.netpri_0) * ratmlt_0 * -1
    ) HTN,
    decode(
        substr(x.gte_0,1,1),
        'F',
        (y.qty_0 * y.gropri_0 * ratmlt_0),
        'A',
        (y.qty_0 * y.gropri_0 * ratmlt_0) * -1
    ) HTB,
    (
        select substr(ysauv_clt_0,2,1)
        from bpcustomer
        where bpcnum_0 = x.bpr_0
    ) categ,
    (
        select max(uu.bpsnum_0)
        from itmbps uu
        where uu.itmref_0 = y.itmref_0
    ) frs,
    decode(
        substr(x.gte_0,1,1),
        'F',
        (y.qty_0 * y.netpriati_0 * ratmlt_0),
        'A',
        (y.qty_0 * y.netpriati_0 * ratmlt_0) * -1
    ) TTCN
from sinvoice x
join sinvoiced y 
    on x.num_0 = y.num_0
join itmmaster t 
    on t.itmref_0 = y.itmref_0
where 
    x.accdat_0  BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')