drop table datamart_agences
/
create table  datamart_agences as select fcy_0 as agence,fcynam_0  as lib_agance from facility

/
drop table commercial01
/
create table commercial01 as select a.sohnum_0 cde,decode(length(a.bpcord_0),6,substr(a.bpcord_0,1,1),substr(a.bpcord_0,7,1)) agence,a.orddat_0 date_BC, a.bpcord_0 tiers,b.itmref_0 Article,b.itmdes1_0 lib_art_cde,b.tsicod_0 FC,b.tsicod_1 FT,b.tsicod_2 FD,' ' FCMKT,' ' FCLIBMKT,' ' FTMKT,' '  FTLIBMKT,' ' FDMKT,' ' as xfDlib_0, ' ' FDLIBMKT,b.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) tarif,c.qty_0 qte,(c.qty_0*b.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) HTN,(c.qty_0*b.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) HTB,substr(r.ysauv_clt_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=b.itmref_0) frs ,b.soplin_0,b.sopseq_0,b.sqhnum_0,b.sqdlin_0,c.dlvqty_0,t.xbusline_0, case when b.SOQSTA_0=3 then 'Oui' else 'Non' end solde from sorder a,sorderp b,sorderq c,itmmaster t,bpcustomer r where r.bpcnum_0=a.bpcord_0 and t.itmref_0=b.itmref_0 and a.sohnum_0=b.sohnum_0 and a.sohnum_0=c.sohnum_0 and b.soplin_0=c.soplin_0 and b.soplin_0=c.soplin_0 and a.sohnum_0 like 'C%' and a.orddat_0 between '01/01/2020' and '31/12/2026' 
/
drop table commercial02_BL 
/
create table commercial02_BL  as select x.sdhnum_0 bl,substr(x.salfcy_0,1,1) agence,x.dlvdat_0 date_bl,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,(select t.tsicod_0 from itmmaster t where t.itmref_0=y.itmref_0) FCMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FCLIBMKT,(select t.tsicod_1 from itmmaster t where t.itmref_0=y.itmref_0) FTMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FTLIBMKT,(select t.tsicod_2 from itmmaster t where t.itmref_0=y.itmref_0) FDMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FDLIBMKT,y.gropri_0 tarif,y.qty_0 qte,(y.qty_0*(y.netprinot_0*CHGRAT_0)) HTN,(y.qty_0*(y.netprinot_0*CHGRAT_0)) HTB,substr(x.bpcord_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sddlin_0 ligne,(y.qty_0*(y.netpriati_0*CHGRAT_0)) TTCN,VACBPR_0 as reg from sdelivery x,sdeliveryd y where x.sdhnum_0=y.sdhnum_0 and x.invflg_0<> 2 and x.betfcy_0=1 and x.dlvdat_0 between '01/01/2024' and '31/12/2026' and (qty_0-rtnqty_0 > 0)
/
drop table commercial02_ret
/
create table commercial02_ret as select xx.srhnum_0 numret,substr(yy.stofcy_0,1,1) ag,xx.rtndat_0,xx.bpcord_0,yy.itmref_0,yy.itmdes1_0,(select tt.tsicod_0 from itmmaster tt where tt.itmref_0=yy.itmref_0)  FC,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FT, (select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FD,(select t.tsicod_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCMKT,(select ' ' from itmmaster t where t.itmref_0=yy.itmref_0) FCLIBMKT,(select t.tsicod_1 from itmmaster t where t.itmref_0=yy.itmref_0) FTMKT,(select ' ' from itmmaster t where t.itmref_0=yy.itmref_0) FTLIBMKT,(select t.tsicod_2 from itmmaster t where t.itmref_0=yy.itmref_0) FDMKT,(select ' ' from itmmaster t where t.itmref_0=yy.itmref_0) FDLIBMKT,yy.netpri_0,yy.qty_0*-1 qty_0,(yy.qty_0*yy.netprinot_0)*-1 HTN,(yy.qty_0*yy.netprinot_0)*-1 HTB,substr(xx.bpcord_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=yy.itmref_0) frs , yy.srdlin_0 ligne,(yy.qty_0*yy.netpriati_0)*-1 TTCN, 'MAR' as reg from sreturn xx, sreturnd yy where xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2024' and '31/12/2026'  and (yy.srhnum_0,yy.srdlin_0) not in (select pp.srhnum_0,pp.srdlin_0 from sinvoiced pp where pp.invdat_0 between '01/01/2024' and '31/12/2026' and pp.srhnum_0<>' ' and pp.bpcinv_0=xx.bpcord_0) AND (yy.sdhnum_0= ' ' or yy.sdhnum_0 in (select BL FROM commercial02_BL )) 

/
drop table commercial02_fac
/
create table commercial02_fac as select x.num_0 fac,substr(x.fcy_0,1,1) agence,x.accdat_0 date_fac,x.bpr_0 tiers, y.itmref_0 article,y.itmdes1_0 lib_art_fac, y.tsicod_0 FC,y.tsicod_1 FT,(select tt.tsicod_2 from itmmaster tt where tt.itmref_0=y.itmref_0) FD, (select t.tsicod_0 from itmmaster t where t.itmref_0=y.itmref_0) FCMKT, (select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FCLIBMKT, (select t.tsicod_1 from itmmaster t where t.itmref_0=y.itmref_0) FTMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FTLIBMKT,(select t.tsicod_2 from itmmaster t where t.itmref_0=y.itmref_0) FDMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FDLIBMKT, y.gropri_0 tarif,y.qty_0*x.sns_0 qte,(y.AMTNOTLIN_0*ratmlt_0*x.sns_0) HTN ,(y.AMTNOTLIN_0*ratmlt_0*x.sns_0) HTB,substr(x.bpr_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sidlin_0 ligne,(y.AMTATILIN_0*ratmlt_0*x.sns_0) TTCN,VAC_0 as reg from sinvoice x,sinvoiced y where x.num_0=y.num_0  and x.accdat_0 between '01/01/2024' and '31/12/2026' 
/
drop table commercial02 
/
create table commercial02 as select * from commercial02_BL  union select * from commercial02_ret union select * from commercial02_fac
/
alter table commercial02 add xdev varchar2(100)
/
drop table commercial03
/
create table commercial03 as select x.num_0 fac,decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence,x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,(select t.tsicod_0 from itmmaster t where t.itmref_0=y.itmref_0) FCMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FCLIBMKT,(select t.tsicod_1 from itmmaster t where t.itmref_0=y.itmref_0) FTMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FTLIBMKT,(select t.tsicod_2 from itmmaster t where t.itmref_0=y.itmref_0) FDMKT,(select ' ' from itmmaster t where t.itmref_0=y.itmref_0) FDLIBMKT,y.gropri_0 tarif,decode(x.gte_0,'FAC',y.qty_0,'FCP',y.qty_0,'AVC',y.qty_0*-1,'AVP',y.qty_0*-1,'AFV',y.qty_0*-1) qte,decode(x.gte_0,'FAC',(y.qty_0*y.netpri_0),'FCP',(y.qty_0*y.netpri_0),'AVC',(y.qty_0*y.netpri_0)*-1,'AVP',(y.qty_0*y.netpri_0)*-1,'AFV',(y.qty_0*y.netpri_0)*-1) HTN ,decode(x.gte_0,'FAC',(y.qty_0*y.gropri_0),'FCP',(y.qty_0*y.gropri_0),'AVC',(y.qty_0*y.gropri_0)*-1,'AVP',(y.qty_0*y.gropri_0)*-1,'AFV',(y.qty_0*y.gropri_0)*-1) HTB,substr(x.bpr_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,decode(x.gte_0,'FAC',(y.qty_0*y.netpriati_0),'FCP',(y.qty_0*y.netpriati_0),'AVC',(y.qty_0*y.netpriati_0)*-1,'AVP',(y.qty_0*y.netpriati_0)*-1,'AFV',(y.qty_0*y.netpriati_0)*-1) TTCN from sinvoice x,sinvoiced y where x.num_0=y.num_0  and x.accdat_0 between '01/01/2024' and '31/12/2026' 
/
drop table commercial04
/

create table commercial04 as select periode,tiers,agence,categ,proj,sum(remise_except) remise_except from ( select a.invdat_0 periode,a.bpcinv_0 tiers,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0)*-1 remise_except ,decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P')) proj from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2016' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and a.sivtyp_0 in ('FAC','FCP') group by a.invdat_0 ,a.bpcinv_0 ,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1),decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P'))  union  select a.invdat_0 periode,a.bpcinv_0 tiers,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0) remise_except , decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P')) proj  from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2016' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and a.sivtyp_0 in ('AVO','AVP')  group by a.invdat_0 ,a.bpcinv_0 ,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1) , decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P'))  ) group by periode,tiers,agence,categ,proj 
/

drop table commercial06
/
create table commercial06 as  select kk.bpr_0 tiers,kk.accdat_0 periode, substr(kk.bpr_0,2,1) categ,decode(substr(kk.bpr_0,1,1),'X','C','Y','C','Z','C',substr(kk.bpr_0,1,1)) agence,kk.amtnot_0 HT,kk.amtati_0 TTC  from sinvoice kk where kk.accdat_0 between '01/01/2024' and '31/12/2026' and kk.num_0 like 'AF%'
/
drop table FC_datamart
/
create table FC_datamart as select a1.code_0 FC,a2.texte_0 lib_FC from atabdiv a1,atextra a2 where a1.numtab_0='20' and a2.codfic_0='ATABDIV' and a2.ident1_0=20 and a2.zone_0='LNGDES' and a2.ident2_0=a1.code_0
/
drop table FT_datamart
/
create table FT_datamart as select a1.code_0 FT,a2.texte_0 lib_FT from atabdiv a1,atextra a2 where a1.numtab_0='21' and a2.codfic_0='ATABDIV' and a2.ident1_0=21 and a2.zone_0='LNGDES' and a2.ident2_0=a1.code_0
/
drop table FD_datamart
/
create table FD_datamart as select a1.code_0 FD,a2.texte_0 LIB_FD from atabdiv a1,atextra a2 where a1.numtab_0='22' and a2.codfic_0='ATABDIV' and a2.ident1_0=22 and a2.zone_0='LNGDES' and a2.ident2_0=a1.code_0 union select 'SOLAIRE' FD,'SOLAIRE' LIB_FD from dual
/
drop table datamart_client_corresp
/
create table datamart_client_corresp as select t.bpcnum_0,t.BPCNAM_0,t.BCGCOD_0,t.rep_0,t.YANCCOD_0,t.YANCPT_0,t.YSITE_0,YSAUV_CLT_0 from bpcustomer t where length(t.bpcnum_0) > 5
/
drop table DATAMART_ARTICLE_CORRESP
/
create table DATAMART_ARTICLE_CORRESP as select tclcod_0,tsicod_0,tsicod_1,tsicod_2,itmref_0,itmdes1_0,vacitm_0 ,yancode_0,yancint_0         from itmmaster where itmsta_0=1
/
drop table datamart_salesrep 
/
create table datamart_salesrep as select repnum_0 agence,repnam_0 lib_rep from salesrep
/
drop table groupe_datamart
/
create table groupe_datamart as select * from ( select f.bpcnum_0 tiers,initcap(f.bpcnam_0) lib_tiers,f.bpcgru_0 cltgrp,initcap((select y.bpcnam_0 from bpcustomer y where y.bpcnum_0=f.bpcgru_0)) lib_grp_tiers from bpcustomer f where f.bpcsta_0=2 and length(f.bpcnum_0) >= 5 and f.bpcnum_0 not like 'G%' ) where cltgrp like 'G%' order by 3,1
/
drop table client_datamart 
/
create table client_datamart as select a.bpcnum_0 tiers,initcap(bpcnam_0) lib_tiers,decode(BPCTYP_0,'2','G','3','S','4','B','1','N',BPCTYP_0) classe,credat_0,ostauz_0,xech_0,xdrecouvr_0,decode((select max(j.rep_0)  from bpcustomer j where j.bpcnum_0=a.bpcnum_0),' ','N/A',(select max(j.rep_0)  from bpcustomer j where j.bpcnum_0=a.bpcnum_0)) rep, decode((select max(j.rep_1)  from bpcustomer j where j.bpcnum_0=a.bpcnum_0),' ','N/A',(select max(j.rep_1)  from bpcustomer j where j.bpcnum_0=a.bpcnum_0)) rep_gest, round((sysdate - credat_0)/365,2) anc ,(select lanmes_0 from APLSTD where LANCHP_0=6003 and lannum_0=a.xtype_0)  type_client, bcgcod_0 categ_clt,case when  a.ysynergie_0=2 then 1 else 0 end  synergie,case when  a.ysynergie_0=2 then (select lanmes_0 from APLSTD where lanchp_0='6011' and lannum_0=ysoc_0) else ' ' end syn_name,case when  a.ycommun_0=2 then 1 else 0 end commun, case when  a.ycommun_0=2 then (select lanmes_0 from APLSTD where lanchp_0='6011' and lannum_0=a.ysoccom_0) else ' ' end com_name,xdmp_0,round(ydso_0,1)  ydso_0 from bpcustomer a where length(bpcnum_0) > 3 and bpcnum_0 not like 'Q%'  

/
BEGIN PRIX_REVIENT_PROD(to_date('2025-01-01','yyyy-MM-dd'),to_date('2025-12-31','yyyy-MM-dd'));  END; 

/

drop table frs_datamart
/
create table frs_datamart as select bpsnum_0 frs,bpsnam_0 lib_frs from bpsupplier where substr(bpsnum_0,1,1) between '0' and '9' and length(bpsnum_0) > 1
/


drop table article_datamart
/
create table article_datamart as select distinct e.tclcod_0 categ_art ,e.tsicod_0 FC,e.tsicod_1 FT,e.tsicod_2 FD, e.itmref_0 article,e.des1axx_0 lib_article,nvl((select t.baspri_0 from itmsales t where t.itmref_0=e.itmref_0),0) tarif  ,e.vacitm_0 regime, (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=e.itmref_0) art_frs,(select tt.bpsnam_0 from bpsupplier tt where tt.bpsnum_0= (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=e.itmref_0) ) lib_frs, xtype_0 art_typ,nvl((select dernier_prix_achat_year(itmref_0,2025) FROM dual),nvl((select round(prix,2) from SYNTHESE_PR_PROD where code=e.itmref_0),xprixrev_0))  dernier_prix_achat,xva_0,cce_0 XBUSLINE_0, cce_0 xsbusline_0 from itmmaster e 
/

update article_datamart set lib_frs=nvl((select fourn_name from datamart_commande_achat where article=article_datamart.article and rownum=1 ),''),art_frs=nvl((select fourn_name from datamart_commande_achat where article=article_datamart.article and rownum=1 ),'')
/

commit
/
exit
/
