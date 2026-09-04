drop table datamart_bl_facture_x3 purge ;
/
create table datamart_bl_facture_x3t as 
SELECT 
    d.bpcnam_0 AS nom,
    s.tiers AS nouv_tiers,
    s.categ,
    t.yancode_0 AS Ar_ref,
    s.lib_art_bl AS lib,
    s.article AS nouv_code,
    '3' AS typ_ligne,
    s.bl AS num_piece,
    s.date_bl AS do_date,
    0 AS do_totalht,
    s.qte AS dl_qte,
    s.tarif AS dl_prixunitaire,
    0 AS discount_per,
    s.htb - s.htn AS discount_amount,
    s.htn AS amount,
    s.agence AS ag,
    CASE 
        WHEN s.date_bl BETWEEN '01/01/2021' AND '31/12/2021' THEN 'PROCESS2021'
        WHEN s.date_bl BETWEEN '01/01/2022' AND '31/12/2022' THEN 'PROCESS2022'
        WHEN s.date_bl BETWEEN '01/01/2023' AND '31/12/2023' THEN 'PROCESS2023'
        WHEN s.date_bl BETWEEN '01/01/2024' AND '31/12/2024' THEN 'PROCESS2024'
        WHEN s.date_bl BETWEEN '01/01/2025' AND '31/12/2025' THEN 'PROCESS2025'
        WHEN s.date_bl BETWEEN '01/01/2026' AND '31/12/2026' THEN 'PROCESS2026'
    END AS base,
    s.ligne,
    s.Fc,
    s.FT,
    s.FD,
    c.rep
FROM commercial02 s
LEFT JOIN datamart_client_corresp d ON d.bpcnum_0 = s.tiers
LEFT JOIN datamart_article_corresp t ON t.itmref_0 = s.article
LEFT JOIN client_datamart c ON c.tiers = s.tiers
WHERE s.date_bl BETWEEN '01/01/2021' AND '31/12/2026';
/
drop table datamart_bl_facture ;
/
create table datamart_bl_facturet as
SELECT 
    nom, 
    nouv_tiers, 
    categ, 
    Ar_ref, 
    lib,  
    nouv_code, 
    typ_ligne, 
    num_piece, 
    do_date, 
    do_totalht, 
    dl_qte, 
    dl_prixunitaire, 
    discount_per, 
    discount_amount, 
    amount, 
    ag,  
    CAST(base AS NVARCHAR2(32)) AS base, 
    ligne, 
    fc, 
    ft, 
    fd, 
    rep  
FROM datamart_bl_facture_x3
WHERE NOT (num_piece LIKE 'PROAM%' AND base <> 'PROCESS2022');