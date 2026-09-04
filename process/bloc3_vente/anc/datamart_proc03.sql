

drop table datamart_bl_facture_x3
/
commit
/
create table datamart_bl_facture_x3 as select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib, s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag  ,'PROCESS2021'  base,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl between '01/01/2021' and '31/12/2021'  union  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'PROCESS2022' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl  between '01/01/2022' and '31/12/2022' union  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'PROCESS2023' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl  between '01/01/2023' and '31/12/2023' 

/
insert into datamart_bl_facture_x3  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'PROCESS2024' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl  between '01/01/2024' and '31/12/2024' 
/
commit
/
insert into datamart_bl_facture_x3  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'PROCESS2025' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl  between '01/01/2025' and '31/12/2025' 
/
commit
/
insert into datamart_bl_facture_x3  select (select d.bpcnam_0 from datamart_client_corresp d where d.bpcnum_0=s.tiers) nom,s.tiers nouv_tiers,s.categ,(select t.yancode_0  from datamart_article_corresp t where t.itmref_0=s.article) Ar_ref,s.lib_art_bl lib,s.article nouv_code,'3' typ_ligne,s.bl num_piece,s.date_bl do_date,0 do_totalht ,s.qte dl_qte ,s.tarif dl_prixunitaire ,0 discount_per ,s.htb-s.htn discount_amount ,s.htn amount ,s.agence ag ,'PROCESS2026' base ,s.ligne ligne ,s.Fc fc ,s.FT ft ,s.FD fd ,(select d.rep from client_datamart d where d.tiers=s.tiers) rep  from commercial02 s where  s.date_bl  between '01/01/2026' and '31/12/2026' 
/
commit
/
drop table datamart_bl_facture
/
--create table datamart_bl_facture as  select  nom, nouv_tiers,categ, Ar_ref, lib,  nouv_code, typ_ligne, num_piece, do_date, do_totalht ,dl_qte , dl_prixunitaire ,discount_per , discount_amount , amount , ag  ,cast(base as nvarchar2(32)) base , ligne , fc , ft , fd ,rep  from datamart_bl_facture_precedent union  ALL select  nom, nouv_tiers,categ, Ar_ref, lib,  nouv_code, typ_ligne, num_piece, do_date, do_totalht ,dl_qte , dl_prixunitaire ,discount_per , discount_amount , amount , ag  ,cast(base as nvarchar2(32)) base , ligne , fc , ft , fd ,rep  from datamart_bl_facture_x3 
create table datamart_bl_facture as  select  nom, nouv_tiers,categ, Ar_ref, lib,  nouv_code, typ_ligne, num_piece, do_date, do_totalht ,dl_qte , dl_prixunitaire ,discount_per , discount_amount , amount , ag  ,cast(base as nvarchar2(32)) base , ligne , fc , ft , fd ,rep  from datamart_bl_facture_x3 

/
commit
/
delete from datamart_bl_facture where num_piece like 'PROAM%' and base <> 'PROCESS2022'
/
commit
/
exit
/
