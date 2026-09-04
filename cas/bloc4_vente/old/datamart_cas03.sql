
--drop table datamart_bl_facture_x3
--/
--create table datamart_bl_facture_x3 as 
delete from datamart_bl_facture where base in ('CAS2025','CAS2026')
/

insert into datamart_bl_facture  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'CAS2025' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers and ROWNUM=1) rep,case when s.reg ='MAR' then 0 else 1 end as export,s.ttcn as ttcn  from commercial02 s where  s.date_bl  between '01/01/2025' and '31/12/2025' 
 
/
commit
/
insert into datamart_bl_facture  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'CAS2026' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers and ROWNUM=1) rep,case when s.reg ='MAR' then 0 else 1 end as export,s.ttcn as ttcn  from commercial02 s where  s.date_bl  between '01/01/2026' and '31/12/2026' 
 
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
exit
/