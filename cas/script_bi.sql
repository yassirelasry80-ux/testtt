delete from datamart_bl_facture where base in ('CAS2025','CAS2026')
/
insert into datamart_bl_facture SELECT 
    d_client.bpcnam_0 AS nom,
    s.tiers AS nouv_tiers,
    s.categ,
    d_art.yancode_0 AS Ar_ref,
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
    'CAS2025' AS base,
    s.ligne,
    s.Fc AS fc,
    s.FT AS ft,
    s.FD AS fd,
    sub_rep.rep AS rep,
    CASE WHEN s.reg = 'MAR' THEN 0 ELSE 1 END AS export,
    s.ttcn
FROM commercial02 s
LEFT OUTER JOIN datamart_client_corresp d_client 
    ON d_client.bpcnum_0 = s.tiers
LEFT OUTER JOIN datamart_article_corresp d_art 
    ON d_art.itmref_0 = s.article
LEFT OUTER JOIN (
    SELECT tiers, MIN(rep) AS rep
    FROM client_datamart
    GROUP BY tiers
) sub_rep 
    ON sub_rep.tiers = s.tiers
WHERE s.date_bl BETWEEN TO_DATE('01/01/2025','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
/
commit
/
update datamart_bl_facture set nouv_tiers = nvl((select max(bpcnum_0)   from datamart_client_corresp where yanccod_0=nouv_tiers or YSAUV_CLT_0 =nouv_tiers),nouv_tiers)
/
commit
/
update datamart_bl_facture set  AG=nvl((select max(ysite_0)   from datamart_client_corresp where yanccod_0=nouv_tiers),AG) 
/
commit
/
delete from datamart_bl_facture where num_piece like 'PROAM%' and base <> 'CAS2022'
/
commit
/