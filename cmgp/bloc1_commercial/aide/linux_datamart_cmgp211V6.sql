drop table commercial00 
/
create table commercial00  as select x.cusquoref_0,x.quosta_0, x.sqhnum_0 devis,decode(length(x.bpcord_0),6,substr(x.bpcord_0,1,1),substr(x.bpcord_0,7,1)) agence,x.quodat_0 date_dev,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,z.tsicod_0 FC,z.tsicod_1 FT,z.tsicod_2 FD,xfc_0 FCMKT,z.xfclib_0 FCLIBMKT,z.xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,y.gropri_0 tarif,y.qty_0 qte,(y.qty_0*y.netpri_0) HTN,(y.qty_0*y.gropri_0) HTB,y.ordflg_0,y.ordqty_0   ,substr(ysauv_clt_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sqdlin_0 ligne,(y.qty_0*y.netpriati_0) TTCN,z.xbusline_0 from squote x,squoted y,itmmaster z,bpcustomer r where r.bpcnum_0=x.bpcord_0 and z.itmref_0 = y.itmref_0 and x.sqhnum_0=y.sqhnum_0 and x.quodat_0 between '01/01/2019' and '31/12/2026' and substr(y.bpcord_0,2,1)='U'
/ 

drop table commercial01
/
create table commercial01 as select a.sohnum_0 cde,decode(length(a.bpcord_0),6,substr(a.bpcord_0,1,1),substr(a.bpcord_0,7,1)) agence,a.orddat_0 date_BC, a.bpcord_0 tiers,b.itmref_0 Article,b.itmdes1_0 lib_art_cde,b.tsicod_0 FC,b.tsicod_1 FT,b.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,b.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) tarif,c.qty_0 qte,(c.qty_0*b.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) HTN,(c.qty_0*b.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) HTB,substr(r.ysauv_clt_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=b.itmref_0) frs ,b.soplin_0,b.sopseq_0,b.sqhnum_0,b.sqdlin_0,c.dlvqty_0,t.xbusline_0 from sorder a,sorderp b,sorderq c,itmmaster t,bpcustomer r where r.bpcnum_0=a.bpcord_0 and t.itmref_0=b.itmref_0 and a.sohnum_0=b.sohnum_0 and a.sohnum_0=c.sohnum_0 and b.soplin_0=c.soplin_0 and b.soplin_0=c.soplin_0 and a.sohnum_0 like 'C%' and a.orddat_0 between '01/01/2020' and '31/12/2026' 
/
drop table commercial02_BL 
/
create table commercial02_BL  as SELECT x.sdhnum_0 AS bl,decode(length(x.bpcord_0),6,substr(x.bpcord_0,1,1),substr(x.bpcord_0,7,1)) AS agence, x.dlvdat_0 AS date_bl, x.bpcord_0 AS tiers, y.itmref_0 AS Article, y.itmdes1_0 AS Lib_art_bl, y.tsicod_0 AS FC, y.tsicod_1 AS FT, y.tsicod_2 AS FD, xfc_0 FCMKT,xfclib_0 AS FCLIBMKT, xft_0 AS FTMKT,xftlib_0 AS FTLIBMKT, xfd_0 AS FDMKT,xfdlib_0 AS FDLIBMKT, y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS tarif, y.qty_0 AS qte, (y.qty_0 * y.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTN, (y.qty_0 * y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTB,substr(ysauv_clt_0,2,1) AS categ, (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs, y.sddlin_0 AS ligne, (y.qty_0 * y.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS TTCN, y.sohnum_0, y.soplin_0, TO_CHAR(y.soqseq_0) AS soqseq_0, 0 AS lignebl,t.xbusline_0 AS xbusline_0 FROM sdelivery x, sdeliveryd y,itmmaster t,bpcustomer r WHERE r.bpcnum_0=x.bpcord_0 and t.itmref_0 = y.itmref_0 and x.sdhnum_0 = y.sdhnum_0 AND x.sdhnum_0 LIKE 'B%' AND x.dlvdat_0 BETWEEN '01/01/2020' AND '31/12/2026'
/
drop table commercial02_ret
/
create table commercial02_ret as select xx.srhnum_0 numret,decode(length(xx.bpcord_0),6,substr(xx.bpcord_0,1,1),substr(xx.bpcord_0,7,1)) ag,xx.rtndat_0,xx.bpcord_0,yy.itmref_0,yy.itmdes1_0,t.tsicod_0 FC,t.tsicod_1 FT,t.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) netpri_0,yy.qty_0*-1 qty_0,(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTN,(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTB,substr(ysauv_clt_0,2,1) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=yy.itmref_0) frs , yy.srdlin_0 ligne,(yy.qty_0*yy.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 TTCN ,yy.sdhnum_0,yy.sddlin_0,'0' soplig,0 ligret,xbusline_0 from sreturn xx, sreturnd yy,itmmaster t,bpcustomer r where r.bpcnum_0=xx.bpcord_0 and t.itmref_0=yy.itmref_0 and xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2019' and '31/12/2026' and substr(xx.srhnum_0,1,2) in ('RV','RP') 
/
drop table commercial02_fac
/
create table commercial02_fac as select x.num_0 fac,decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)) agence,x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,t.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,y.gropri_0*ratmlt_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*ratmlt_0),'A',(y.qty_0*y.netpri_0)*ratmlt_0*-1) HTN ,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*ratmlt_0),'A',(y.qty_0*y.gropri_0*ratmlt_0)*-1) HTB,(select substr(ysauv_clt_0,2,1) from bpcustomer where bpcnum_0=x.bpr_0) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sidlin_0 ligne,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpriati_0*ratmlt_0),'A',(y.qty_0*y.netpriati_0*ratmlt_0)*-1) TTCN ,y.sdhnum_0,y.sddlin_0,y.srhnum_0,y.srdlin_0,xbusline_0 from sinvoice x,sinvoiced y,itmmaster t where t.itmref_0=y.itmref_0 and x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' and ((substr(x.num_0,1,1) in ('F','P') and y.sdhnum_0=' ') or (substr(x.num_0,1,1) in ('A') and y.srhnum_0=' ')) and substr(x.num_0,1,2) not like 'AF%' 
/
drop table commercial02 
/
create table commercial02 as select * from commercial02_BL  union select * from commercial02_ret union select * from commercial02_fac
/
alter table commercial02 add xdev varchar2(100)
/
update commercial02 set xdev= (select xdevis_0 from sorder where sohnum_0=(select sohnum_0 from sdeliveryd where bl=sdhnum_0 and sddlin_0=ligne))
where bl like 'B%'
/
update commercial02 set xdev = (select distinct xdevis_0 from sorder where sohnum_0 in (select distinct sohnum_0 from sdeliveryd where sdhnum_0 in (select distinct sdhnum_0 from sreturnd where srhnum_0=bl and srdlin_0=ligne))) 
 where bl like 'RV%' 
/
commit
/
UPDATE commercial02 SET FD = 'RA01' WHERE ARTICLE LIKE 'RA02%'
/
COMMIT
/
drop table commercial03
/
create table commercial03 as select x.num_0 fac,decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)) agence,x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,y.gropri_0*ratmlt_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*ratmlt_0),'A',(y.qty_0*y.netpri_0)*ratmlt_0*-1) HTN ,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*ratmlt_0),'A',(y.qty_0*y.gropri_0*ratmlt_0)*-1) HTB,(select substr(ysauv_clt_0,2,1) from bpcustomer where bpcnum_0=x.bpr_0) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpriati_0*ratmlt_0),'A',(y.qty_0*y.netpriati_0*ratmlt_0)*-1) TTCN from sinvoice x,sinvoiced y,itmmaster t where t.itmref_0=y.itmref_0 and x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' 
/
drop table commercial04
/
create table commercial04 as select periode,tiers,agence,categ,proj,sum(remise_except) remise_except from ( select a.invdat_0 periode,a.bpcinv_0 tiers,decode(length(a.bpcinv_0),6,substr(a.bpcinv_0,1,1),substr(a.bpcinv_0,7,1)) agence,substr(a.bpcinv_0,1,2) categ, sum(b.dtanot_0*ratmlt_0)*-1 remise_except ,decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P')) proj from sinvoicev a, svcrfoot b,sinvoice e where e.num_0=a.num_0 and a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2020' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and substr(a.sivtyp_0,1,1)='F' group by a.invdat_0 ,a.bpcinv_0 ,substr(a.bpcinv_0,7,1) ,substr(a.bpcinv_0,1,2),decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P'))  union  select a.invdat_0 periode,a.bpcinv_0 tiers,decode(length(a.bpcinv_0),6,substr(a.bpcinv_0,1,1),substr(a.bpcinv_0,7,1)) agence,substr(a.bpcinv_0,1,2) categ, sum(b.dtanot_0*ratmlt_0) remise_except , decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P')) proj  from sinvoicev a, svcrfoot b ,sinvoice e where e.num_0=a.num_0  and a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2020' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and substr(a.sivtyp_0,1,1)='A'  group by a.invdat_0 ,a.bpcinv_0 ,substr(a.bpcinv_0,7,1) ,substr(a.bpcinv_0,1,2)  , decode(substr(a.num_0,1,1),'F','N','P','P',decode(substr(a.num_0,1,2),'AP','P','AV','P'))  ) group by periode,tiers,agence,categ,proj 
/
drop table commercial06
/
create table commercial06 as  select kk.bpr_0 tiers,kk.accdat_0 periode, substr(kk.bpr_0,1,2) categ,decode(length(kk.bpr_0),6,substr(kk.bpr_0,1,1),substr(kk.bpr_0,7,1)) agence,kk.amtnotl_0 HT,kk.amtatil_0 TTC  from sinvoice kk where kk.accdat_0 between '01/01/2020' and '31/12/2026' and kk.num_0 like 'AF%'
/

drop table frs_datamart
/
create table frs_datamart as select bpsnum_0 frs,bpsnam_0 lib_frs from bpsupplier where substr(bpsnum_0,1,1) between '0' and '9' and length(bpsnum_0) > 1
/
drop table article_datamart
/
create table article_datamart as select distinct e.tclcod_0 categ_art ,e.tsicod_0 FC,e.tsicod_1 FT,e.tsicod_2 FD, e.itmref_0 article,e.des1axx_0 lib_article,nvl((select distinct t.baspri_0 from itmsales t where t.itmref_0=e.itmref_0),0) tarif  ,e.vacitm_0 regime, (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=e.itmref_0) art_frs,(select max(tt.bpsnam_0 ) from bpsupplier tt where tt.bpsnum_0= (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=e.itmref_0) ) lib_frs,e.xclasse_0,e.itmsta_0,xstock_0,xbusline_0 ,decode(xfrs_0,1,'IMPORT',2,'LOCAL',3,'IMP/LOC',4,'FABRICATION',5,'TECHNIQUE') XFRS,xsbusline_0,xcentre_0,XVA_0,(select max( j.itmref_0) from simay.itmmaster j where j.xitmart_0 <>' ' and  j.xitmart_0= e.itmref_0) artsimay,(select max(j.itmwei_0) from simay.itmmaster j where j.xitmart_0 <>' ' and j.xitmart_0= e.itmref_0) poids,(select max( j.xdesgrp_0 ) from simay.itmmaster j where j.xitmart_0 <>' ' and  j.xitmart_0= e.itmref_0) categ from itmmaster e where e.tclcod_0 in ('NEG','NEGT','ARC','ART') 
/

UPDATE ARTICLE_DATAMART SET FD = 'RA01' WHERE ARTICLE LIKE 'RA02%'
/
COMMIT
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
drop table categ_datamart
/
create table categ_datamart as select  decode(bcgcod_0,'MULTI','MULTI','ASS','A','AGENC','AGENC','COOP','C','DOMA','D','MARC','M','PART','P','REVE','R','GROU','G','TRANS','TRANS','AO','U','MKT','MKT','RECON','S','EXP','Z') categ,initcap(bcgdes_0) lib_categ_client from bpccateg where bcgcod_0 in ('COOP','DOMA','MARC','PART','REVE','GROU','AO','RECON','EXP')
/
drop table groupe_datamart
/
create table groupe_datamart as select * from ( select f.bpcnum_0 tiers,initcap(f.bpcnam_0) lib_tiers,f.bpcgru_0 cltgrp,initcap((select y.bpcnam_0 from bpcustomer y where y.bpcnum_0=f.bpcgru_0)) lib_grp_tiers from bpcustomer f where f.bpcsta_0=2 and length(f.bpcnum_0) >= 5 and f.bpcnum_0 not like 'G%' ) where cltgrp like 'G%' order by 3,1
/
drop table agence
/
create table agence (agence varchar2(10),lib_agence varchar2(100),ville varchar2(100))
/
insert into Agence values ('A','AIT MELLOUL','AGADIR');
insert into Agence values ('B','BERKANE','BERKANE');
insert into Agence values ('C','CASABLANCA','CASABLANCA');
insert into Agence values ('I','AIT IAZAA','AGADIR');
insert into Agence values ('J','EL JADIDA','EL JADIDA');
insert into Agence values ('K','KENITRA','KENITRA');
insert into Agence values ('L','LARACHE','LARACHE');
insert into Agence values ('M','MARRAKECH','MARRAKECH');
insert into Agence values ('N','BENI MELLAL','BENI MELLAL');
insert into Agence values ('P','SAPINO','SAPINO');
insert into Agence values ('R','ERRACHIDIA','ERRACHIDIA');
insert into Agence values ('S','MEKNES','MEKNES');
insert into Agence values ('G','ZAGORA','ZAGORA');
/
commit
/
drop table DA_BU
/
create table DA_BU as select xstrnum_0,decode(xstrnum_0,'DAI','Ach Rev Import','DAN','Ach Netafim','DAT','Ach N/Rev Atelier','DGP','Ach N/Rev Groupe','DNC','Ach N/Rev Constr Soi/Même','DNR','Ach N/Rev','DRA','Ach Rev Atelier','DRC','Ach Rev Constr P/C Client','IMM','Ach N/Rev Immobilisé','SIC','Ach Marchandise simay','STD','Ach Rev Local') type_DA,pshnum_0,pshfcy_0,(select fcynam_0  from facility l where l.fcy_0=pshfcy_0 ) lib_site,requsr_0,(select nomusr_0 from autilis where usr_0=requsr_0) nom,prqdat_0,xaffect_0,xclient_0,a.yun_0,(select d.libunit_0  from yunit d where d.yun_0=a.yun_0) lib_UN,decode(xtypproj_0,1,'AppelOffre',2,'MarchéPrivé',3,'Stock',4,'AutreClients',5,'CONSTRUCTION') typ ,(select max(cce_1) from cptanalin j where j.vcrnum_0=pshnum_0) proj_analyt,(select max(cce_2) from cptanalin j where j.vcrnum_0=pshnum_0) vehicule_analyt,(select des_0 from cacce where die_0='AX3' and cce_0=(select max(cce_2) from cptanalin j where j.vcrnum_0=pshnum_0)) nom_vehicule,(select max(cce_3) from cptanalin j where j.vcrnum_0=pshnum_0) sal_analyt,(select BU ||' '|| Service from salarie_bu where axe_sal = (select max(cce_3) from cptanalin j where j.vcrnum_0=pshnum_0)) BU_SU,(select texte_0 from atextra where codfic_0 like 'ATA%' and ident1_0=6012 and langue_0='FRA' and zone_0='LNGDES' and ident2_0= (select xbusline_0 from itmmaster where itmref_0=(select min(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0))) BLine1,(select texte_0 from atextra where codfic_0 like 'ATA%' and ident1_0=6012 and langue_0='FRA' and zone_0='LNGDES' and ident2_0= (select xbusline_0 from itmmaster where itmref_0=(select max(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0))) BLine2,(select des_0 from cacce where die_0='AX4' and cce_0=(select max(cce_3) from cptanalin j where j.vcrnum_0=pshnum_0)) nom_sal,(select min(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0) min_art,(select max(r.itmdes1_0)  from prequisd r where r.pshnum_0=a.pshnum_0 and r.itmref_0=(select min(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0)) lib_art1,(select max(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0) max_art,(select max(r.itmdes1_0)  from prequisd r where r.pshnum_0=a.pshnum_0 and r.itmref_0=(select max(s.itmref_0) from prequisd s where s.pshnum_0=a.pshnum_0)) lib_art2 from prequis a where prqdat_0 between '01/01/2024' and '31/12/2024' order by 2,1,5
/
drop table datamart_sta_art
/
create table   datamart_sta_art as select (select f1.tsicod_2 from itmmaster f1 where f1.itmref_0=vv1.itmref_0)  fam,vv1.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=vv1.itmref_0) libelle,sum(decode(v1.gte_0,'FAC',vv1.qty_0,0))+sum(decode(v1.gte_0,'FCP',vv1.qty_0,0)) + sum(decode(v1.gte_0,'AVC',-1*vv1.qty_0,0))+ sum(decode(v1.gte_0,'AVP',-1*vv1.qty_0,0))+ sum(decode(v1.gte_0,'AFV',-1*vv1.qty_0,0)) QTE,sum(decode(v1.gte_0,'FAC',vv1.amtnotlin_0,0)) + sum(decode(v1.gte_0,'FCP',vv1.amtnotlin_0,0)) + sum(decode(v1.gte_0,'AVC',vv1.amtnotlin_0*-1,0)) + sum(decode(v1.gte_0,'AVP',vv1.amtnotlin_0*-1,0))+sum(decode(v1.gte_0,'AFV',vv1.amtnotlin_0*-1,0))  CA_NET_HT from sinvoice v1,sinvoiced vv1 where v1.num_0=vv1.num_0 and v1.accdat_0 between '01/01/2024' and '31/12/2024' group by vv1.itmref_0
/
insert into datamart_sta_art  (select  (select f2.tsicod_2 from itmmaster f2 where f2.itmref_0=vv2.itmref_0)  fam,vv2.itmref_0 code,(select d2.des1axx_0 from itmmaster d2 where d2.itmref_0=vv2.itmref_0) libelle,sum(vv2.qty_0) Qte,sum(vv2.netprinot_0*vv2.qty_0) CA_NET_HT from sdelivery v2,sdeliveryd vv2 where  v2.sdhnum_0=vv2.sdhnum_0 and v2.dlvdat_0 between '01/01/2024' and '31/12/2024' and v2.bpcord_0 not in ('A','B','G','C','M','I','K','L','M','N','D','T','S','E','U','J','Q','MKT') and v2.invflg_0=1 and v2.betfcy_0=1 and v2.sdhnum_0 like 'B%' group by vv2.itmref_0) union (select (select f.tsicod_2 from itmmaster f where f.itmref_0=vv.itmref_0)  fam,vv.itmref_0 code,(select d.des1axx_0 from itmmaster d where d.itmref_0=vv.itmref_0) libelle,sum(vv.qty_0)*-1 Qte,sum(vv.netpri_0*vv.qty_0) *-1 CA_NET_HT from sreturn v,sreturnd vv where  v.srhnum_0=vv.srhnum_0 and v.rtndat_0 between '01/01/2024' and '31/12/2024' and v.betfcy_0=1 and v.bpcord_0 not in ('A','B','G','C','M','I','K','L','M','N','D','T','S','E','U','J','Q','MKT')  and  (v.srhnum_0,vv.srdlin_0) in (select d.srhnum_0,dd.srdlin_0 from sreturn d,sreturnd dd where d.srhnum_0=dd.srhnum_0 and d.rtndat_0 between '01/01/2024' and '31/12/2024' and d.bpcord_0=v.bpcord_0 minus select bb.srhnum_0,bb.srdlin_0  from sinvoice b,sinvoiced bb where b.num_0=bb.num_0 and b.gte_0 in ('AVC','AVP')  and b.bpr_0=v.bpcord_0) group by vv.itmref_0 )
/
commit
/
drop table datamart_sta_art_glb
/
create table  datamart_sta_art_glb as select code,sum(qte) qte,sum(ca_net_ht) ca_net_ht from datamart_sta_art group by code
/
drop table datamart_mvt_assia0
/
create table datamart_mvt_assia0 as select p.pthnum_0,p.rcpdat_0,p.itmref_0,p.ptdlin_0 lin,p.itmdes1_0,p.qtypuu_0,(select oo.netpri_0 from porderp oo where oo.pohnum_0=p.pohnum_0 and oo.poplin_0=p.poplin_0 and oo.popseq_0=p.poqseq_0) netpri_0,kk.xprirev_0,kk.mltcur_0,(select ii.cpr_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' ') cpr,(select  sum(p2.cpr_0 )from preceiptd pa,pinvoiced p1,pinvoiced p2,pinvoice xx where pa.pthnum_0=p1.numori_0 and pa.ptdlin_0=p1.linori_0 and pa.itmref_0=p1.itmref_0 and p1.num_0=xx.num_0 and p1.num_0=p2.numori_0 and p1.pidlin_0=p2.pidlin_0 and pa.pthnum_0=p.pthnum_0 and pa.itmref_0=p.itmref_0)cpr2,decode((select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' '),null,(select distinct chgrat_0 from tabchange where curden_0='MAD' and cur_0=netcur_0 and chgtyp_0=1 and chgstrdat_0=(select max(chgstrdat_0) from TABCHANGE where  cur_0 =netcur_0)),(select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' '))ratcur from preceiptd p,xgpohlin k,xgdetpri kk where p.pthnum_0=k.pthnum_0(+) and p.ptdlin_0=k.ptdlin_0(+) and p.rcpdat_0 between '01/01/2024' and '31/12/2024' and substr(p.bpsnum_0,1,1) between '0' and '1' and k.itmref_0=kk.itmref_0(+) and k.xdanum_0=kk.xdanum_0(+)
/
drop table datamart_mvt_assia
/
create table datamart_mvt_assia as select * from (select pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD') mois,qte qte,avg(round(prixrev,6)) prixrev from        (select rr.pthnum_0,rr.rcpdat_0,rr.itmref_0,rr.qtypuu_0 qte,rr.netpri_0,decode(rr.mltcur_0,null,rr.ratcur,rr.mltcur_0) cur, decode(rr.xprirev_0,null,(rr.netpri_0*rr.ratcur)+nvl(cpr2,0),nvl(rr.xprirev_0,0)+nvl(cpr2,0)) prixrev,cpr2 from datamart_mvt_assia0 rr ) group by pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD'),qte union (select x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD') Mois,sum(x.qtypuu_0 ) qte,x.netpri_0 PrixRev from preceiptd x where x.rcpdat_0 between  '01/01/2024' and '31/12/2024'  and   substr(x.bpsnum_0,1,1) between '2' and '9' group by x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD'),x.netpri_0 ) union select x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD') Mois,sum(x.qtypcu_0) qte,x.priord_0 PrixRev from stojou x where   ((substr(x.vcrnum_0,1,3) in ('BFM','ATL','ENT','MTK') and x.iptdat_0 between '01/01/2024' and '31/12/2024'   and x.trstyp_0 in (1,5))   or (x.vcrnum_0 not like 'INV%' and x.vcrnum_0 like 'IN%' and x.iptdat_0 between '01/01/2024' and '31/12/2024' )) group by x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD'),x.priord_0 )
/
update datamart_mvt_assia set prixrev = prixrev *-1 where prixrev < 0
/
commit
/
drop table datamart_fifo_assia 
/
create table datamart_fifo_assia as select ff.mois,ff.itmref_0,ff.prixrev,sum(ff.qte) qte from datamart_mvt_assia ff group by ff.mois,ff.itmref_0,ff.prixrev
/
drop table datamart_synthesefifo
/
create table datamart_synthesefifo as select itmref_0,mois,prixrev,sum(qte) qte,max(0) montant,max(0) qtetraiter,max(0) prix_rec from datamart_fifo_assia group by mois,itmref_0,prixrev
/
drop table datamart_stock_ini_fifo
/
create table datamart_stock_ini_fifo as select   distinct  code,  qte stock,0 prixrev,'01/01/2024' dat_fifo  from   datamart_sta_art_glb 
/
declare 
cursor cur2 is 
select rowid,t.itmref_0,t.mois,t.prixrev,qte,qtetraiter from datamart_synthesefifo t order by 2,3 desc ;
cursor cur1 is select code, stock from  datamart_stock_ini_fifo order by 1;
wcode_cur2 varchar2(60);
wmois_cur2 varchar2(6);
wprix_cur2 number;
wqte_cur2 number;
wwprix_sauv number;
wcode_cur1 varchar2(60);
wqte_cur1 number;
wid varchar2(100);
wqte number;
wreliquat number;
wsauv_reliquat number;
wmontant number;
passe integer;
neg integer;
wqtetraiter number(22);
begin
open  cur1;
loop
open cur2;
fetch cur1 into wcode_cur1,wqte_cur1;
 if cur1%notfound then
  exit;
 end if;
wreliquat:=wqte_cur1;
wsauv_reliquat:=0;
passe:=0;
neg:=0;
loop
 fetch  cur2 into wid,wcode_cur2,wmois_cur2,wprix_cur2,wqte_cur2,wqtetraiter;
 if cur2%notfound then
 exit;
 end if;
   if wcode_cur1=wcode_cur2 then
      wsauv_reliquat := wreliquat;
      wreliquat:=wreliquat-wqte_cur2;
      
      if wreliquat > 0 then
        wmontant := wqte_cur2*wprix_cur2;
        wwprix_sauv := wprix_cur2;
        wqte := wqte_cur2;
       elsif wreliquat <=0 then
        wmontant:= wsauv_reliquat*wprix_cur2;
        wqte := wsauv_reliquat;
        neg:=1;
      end if;
      
      update datamart_synthesefifo a set a.montant=wmontant, a.qtetraiter=wqte where a.itmref_0=wcode_cur2 and a.mois=wmois_cur2 
      and a.qte=wqte_cur2 and a.rowid=wid;
      commit;
      passe:=1;
   end if;   
   if neg=1 then wqte:=0;exit; end if;
  if wcode_cur1<>wcode_cur2 and passe=1 then
  wqte:=0;
   exit;
  end if; 
end loop;
close cur2;
end loop;
close  cur1;
end;
/
update datamart_stock_ini_fifo z set z.prixrev= nvl((select sum(prixrev*qtetraiter  )/decode(sum(qtetraiter ),0,9999999999999999,sum(qtetraiter )) from datamart_synthesefifo zz where trim(zz.itmref_0)=trim(z.code)),0)
/
commit
/
update datamart_stock_ini_fifo set prixrev = prixrev * -1 where prixrev < 0
/
commit
/

drop table datamart_sta_art_bis
/
create table   datamart_sta_art_bis as select substr(a.itmref_0,1,4) fam,a.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=a.itmref_0) libelle,sum(a.qtypcu_0) qte,0 CA_NET_HT from stojou a where a.iptdat_0 between '01/01/2024' and '31/12/2024' and a.vcrnum_0 not like 'INV%' and a.vcrnum_0 not like 'OUT2112_9%' group by a.itmref_0
/
commit
/
drop table datamart_sta_art_glb_bis
/
create table  datamart_sta_art_glb_bis as select code,sum(qte) qte,sum(ca_net_ht) ca_net_ht from datamart_sta_art_bis group by code
/
drop table datamart_mvt_assia0_bis
/
create table datamart_mvt_assia0_bis as select p.pthnum_0,p.rcpdat_0,p.itmref_0,p.ptdlin_0 lin,p.itmdes1_0,p.qtypuu_0,(select oo.netpri_0 from porderp oo where oo.pohnum_0=p.pohnum_0 and oo.poplin_0=p.poplin_0 and oo.popseq_0=p.poqseq_0) netpri_0,kk.xprirev_0,kk.mltcur_0,(select ii.cpr_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' ') cpr,(select  sum(p2.cpr_0 )from preceiptd pa,pinvoiced p1,pinvoiced p2,pinvoice xx where pa.pthnum_0=p1.numori_0 and pa.ptdlin_0=p1.linori_0 and pa.itmref_0=p1.itmref_0 and p1.num_0=xx.num_0 and p1.num_0=p2.numori_0 and p1.pidlin_0=p2.pidlin_0 and pa.pthnum_0=p.pthnum_0 and pa.itmref_0=p.itmref_0)cpr2,decode((select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' '),null,(select distinct chgrat_0 from tabchange where curden_0='MAD' and cur_0=netcur_0 and chgtyp_0=1 and chgstrdat_0=(select max(chgstrdat_0) from TABCHANGE where  cur_0 =netcur_0)),(select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.xdanum_0<>' '))ratcur from preceiptd p,xgpohlin k,xgdetpri kk where p.pthnum_0=k.pthnum_0(+) and p.ptdlin_0=k.ptdlin_0(+) and p.rcpdat_0 between '01/01/2024' and '31/12/2024' and substr(p.bpsnum_0,1,1) between '0' and '1' and k.itmref_0=kk.itmref_0(+) and k.xdanum_0=kk.xdanum_0(+)
/
drop table datamart_mvt_assia_bis
/
create table datamart_mvt_assia_bis as select pthnum_0,itmref_0,lin,to_char(rcpdat_0,'YYMMDD') mois,qte qte,(round(prixrev,6)) prixrev from (select rr.pthnum_0,rr.rcpdat_0,rr.itmref_0,lin,rr.qtypuu_0 qte,rr.netpri_0,decode(rr.mltcur_0,null,rr.ratcur,rr.mltcur_0) cur, decode(rr.xprirev_0,null,(rr.netpri_0*rr.ratcur)+nvl(cpr2,0),nvl(rr.xprirev_0,0)+nvl(cpr2,0)) prixrev,cpr2 from datamart_mvt_assia0_bis rr ) union (select x.pthnum_0,x.itmref_0,ptdlin_0 lin,to_char(x.rcpdat_0,'YYMMDD') Mois,sum(x.qtypuu_0 ) qte,x.netpri_0 PrixRev from preceiptd x where x.rcpdat_0 between  '01/01/2024' and '31/12/2024'  and   substr(x.bpsnum_0,1,1) between '2' and '9' group by x.pthnum_0,ptdlin_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD'),x.netpri_0  union select x.vcrnum_0,x.itmref_0,vcrlin_0 lin,to_char(x.iptdat_0,'YYMMDD') Mois,sum(x.qtypcu_0) qte,x.priord_0 PrixRev from stojou x where   ((substr(x.vcrnum_0,1,3) in ('BFM','ATL','ENT','MTK') and x.iptdat_0 between '01/01/2024' and '31/12/2024'   and x.trstyp_0 in (1,5)) or (x.vcrnum_0 not like 'INV%' and x.vcrnum_0 like 'IN%' and x.iptdat_0 between '01/01/2024' and '31/12/2024' )) group by x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD'),x.priord_0,vcrlin_0)
/
update datamart_mvt_assia_bis set prixrev = prixrev *-1 where prixrev < 0
/
commit
/
drop table datamart_fifo_assia_bis 
/
create table datamart_fifo_assia_bis  as select ff.mois,ff.itmref_0,ff.prixrev,sum(ff.qte) qte from datamart_mvt_assia_bis  ff group by ff.mois,ff.itmref_0,ff.prixrev
/
drop table datamart_synthesefifo_bis 
/
create table datamart_synthesefifo_bis  as select itmref_0,mois,prixrev,sum(qte) qte,max(0) montant,max(0) qtetraiter,max(0) prix_rec from datamart_fifo_assia_bis  group by mois,itmref_0,prixrev
/
drop table datamart_stock_ini_fifo_bis 
/
create table datamart_stock_ini_fifo_bis  as select   distinct  code,  qte stock,0 prixrev,'01/01/2024' dat_fifo  from   datamart_sta_art_glb_bis  
/
grant select on datamart_stock_ini_fifo_bis to betude
/
declare 
cursor cur2 is 
select rowid,t.itmref_0,t.mois,t.prixrev,qte,qtetraiter from datamart_synthesefifo_bis t order by 2,3 desc;
cursor cur1 is select code, stock from  datamart_stock_ini_fifo_bis  order by 1;
wcode_cur2 varchar2(60);
wmois_cur2 varchar2(6);
wprix_cur2 number;
wqte_cur2 number;
wwprix_sauv number;
wcode_cur1 varchar2(60);
wqte_cur1 number;
wid varchar2(100);
wqte number;
wreliquat number;
wsauv_reliquat number;
wmontant number;
passe integer;
neg integer;
wqtetraiter number(22);
begin
open  cur1;
loop
open cur2;
fetch cur1 into wcode_cur1,wqte_cur1;
 if cur1%notfound then
  exit;
 end if;
wreliquat:=wqte_cur1;
wsauv_reliquat:=0;
passe:=0;
neg:=0;
loop
 fetch  cur2 into wid,wcode_cur2,wmois_cur2,wprix_cur2,wqte_cur2,wqtetraiter;
 if cur2%notfound then
 exit;
 end if;
   if wcode_cur1=wcode_cur2 then
      wsauv_reliquat := wreliquat;
      wreliquat:=wreliquat-wqte_cur2;
      
      if wreliquat > 0 then
        wmontant := wqte_cur2*wprix_cur2;
        wwprix_sauv := wprix_cur2;
        wqte := wqte_cur2;
       elsif wreliquat <=0 then
        wmontant:= wsauv_reliquat*wprix_cur2;
        wqte := wsauv_reliquat;
        neg:=1;
      end if;
      
      update datamart_synthesefifo_bis a set a.montant=wmontant, a.qtetraiter=wqte where a.itmref_0=wcode_cur2 and a.mois=wmois_cur2 
      and a.qte=wqte_cur2 and a.rowid=wid;
      commit;
      passe:=1;
   end if;   
   if neg=1 then wqte:=0;exit; end if;
  if wcode_cur1<>wcode_cur2 and passe=1 then
  wqte:=0;
   exit;
  end if; 
end loop;
close cur2;
end loop;
close  cur1;
end;
/
update datamart_stock_ini_fifo_bis  z set z.prixrev= nvl((select sum(prixrev*qtetraiter  )/decode(sum(qtetraiter ),0,9999999999999999,sum(qtetraiter )) from datamart_synthesefifo_bis  zz where trim(zz.itmref_0)=trim(z.code)),0)
/
commit
/
update datamart_stock_ini_fifo_bis  set prixrev = prixrev * -1 where prixrev < 0
/
commit
/
update datamart_stock_ini_fifo_bis s set prixrev=nvl(der_prix_achat(code),0) where prixrev <= 0
/
commit
/
drop table datamart_detail_devis
/
create table datamart_detail_devis as ( select a.numdev ,(select agence from betude.commercial where nom||' '||codec = a.commercial  and etat='A') agence,a.commercial,decode(a.etat,'1','A En Cours','2','C Perdu','4','D Pas Inter�ss�','5','B D�croch�','3','F Variantes P�rim�','6','E En Cours P�rim�','8','G D�croch� P�rim�',a.etat) etat,a.totalttcnet , to_char(date_maj_etat,'dd/mm/yyyy') date_maj_etat , clientadonix ,a.nom ,a.libelle ,a.date_creation,substr(a.numdev,1,7)||substr(a.numdev,9,23) racine,a.etat_prospect ,a.date_prospect ,a.classification,a.niveau_chaud from betude.e_devis  a  , betude.commercial cc where cc.nom||' '||cc.codec=a.commercial and cc.etat='A' and  a.numdev is not null and substr(a.agence,2,1)= 'B' and a.etat in ('1','2','4','6' ) and substr(a.numdev,40,1) <> 'S' and substr(a.numdev,1,8) <>'Devis-NT' and a. date_creation  between '01/01/2020'  and '31/12/2026' and a.totalttcnet <> 0 and a.commercial not like 'RECONV%' and a.numdev not like '%TST%'   union   select p. numdev, (select agence from betude.commercial where nom||' '||codec = p.commercial  and etat='A') agence,  p.commercial,decode(p.etat,'1','A En Cours','2','C Perdu','4','D Pas Inter�ss�','5','B D�croch�','3','F Variantes P�rim�','6','E En Cours P�rim�','8','G D�croch� P�rim�',p.etat) etat,  TOTALTTCNET ,to_char(p.date_maj_etat,'dd/mm/yyyy') date_maj , p.clientadonix ,p.nom ,p.libelle ,p.date_creation,substr(p.numdev,1,7)||substr(p.numdev,9,23) racine,p.etat_prospect ,  p.date_prospect,p.classification,p.niveau_chaud from betude.e_devis p where substr(p.numdev,1,8) <>'Devis-NT' and p.etat=5 and  p. date_creation  between '01/01/2024'  and '31/12/2024'   and TOTALTTCNET <> 0 and p.commercial not like 'RECONV%' and p.numdev not like '%TST%' and (((substr(p.numdev, 39, 2) =  '..') or   (  ( p.numdev =substr(p.numdev, 1, 38) || '/S' || substr(p.numdev, 41, length(p.numdev) - 40) and (substr(p.numdev, 1, 32) || '..' )   not in (select   substr(z.numdev, 1, 32) || '..'  from betude.e_devis z where z.numdev<> p.numdev and  substr(z.numdev,1,8) <>'Devis-NT' and z.etat=5 )) ))) )
/

drop table datamart_impayes
/
create table datamart_impayes as  select aa.num_0,bb.bpr_0,aa.bprvcr_0,aa.accdat_0,bb.acc_0,bb.amtled_0,bb.mtc_0  from gaccentry aa,gaccentryd bb where aa.typ_0=bb.typ_0 and aa.num_0=bb.num_0  and  aa.typ_0='IMP' and aa.accdat_0 between '01/01/'||'2023' and '31/12/'||'2023' and bb.acc_0='34210000'  and (select f.rennotpay_0 from paymenth f where f.num_0=aa.bprvcr_0)=20 
/
drop table datamart_garanties
/
create table datamart_garanties as select decode(k.xtypgar_0,1,'GP',2,'GS',3,'CS',4,'CB',k.xtypgar_0) typ_gar,k.num_0,k.amtcur_0,k.accdat_0,k.bpr_0    from paymenth k where k.num_0 like 'GAR%' and (k.xannule_0<>2) and k.xremisclt_0<>2 and k.xtypgar_0 in (1,2,3,4)
/
drop table datamart_DPM
/
create table datamart_DPM as select ll.bpr_0,DMP(ll.bpr_0,'31/12/2023') dmp from (select distinct bpr_0 from balance where fiy_0 between 10 and 14 and acc_0='34210000' and substr(bpr_0,1,1)='D') ll
/

drop table datamart_salesrep
/
create table datamart_salesrep as select  repnum_0 rep,repnam_0 nom_rep from salesrep
/
drop table client_datamart
/
create table client_datamart as select a.bpcnum_0 tiers,initcap(bpcnam_0) lib_tiers,decode(bus_0,'1','G','2','S','3','B','4','N',bus_0) classe,credat_0,ostauz_0,xech_0,xdrecouvr_0,decode((select max(j.rep_0)  from bpdlvcust j where j.bpcnum_0=a.bpcnum_0),' ','N/A',(select max(j.rep_0)  from bpdlvcust j where j.bpcnum_0=a.bpcnum_0)) rep, decode((select max(j.rep_1)  from bpdlvcust j where j.bpcnum_0=a.bpcnum_0),' ','N/A',(select max(j.rep_1)  from bpdlvcust j where j.bpcnum_0=a.bpcnum_0)) rep_gest, round((sysdate - credat_0)/365,2) anc ,decode(xtyp_0_0,'1','COMPTANT A ECHEANCE','2','EN COMPTE','3','COMPTANT','N/R') type_client ,xregion_0 region,xville_0 ville ,ysynergie_0,ysoc_0,ycommun_0,ysoccom_0,a.ysauv_clt_0 from bpcustomer a where length(bpcnum_0) > 5 and substr(bpcnum_0,1,1) not in ('G','Q') 
/
drop table datamart_region
/
create table datamart_region as select lannum_0 num_,a.lanmes_0 region_ from aplstd a where a.lan_0='FRA' and a.lanchp_0='6024' and lannum_0>0
/
drop table datamart_ville
/
create table datamart_ville as select lannum_0 num_,a.lanmes_0 ville_ from aplstd a where  a.lan_0='FRA' and a.lanchp_0='6025' and lannum_0>0
/
drop table datamart_reservation
/
create table datamart_reservation as SELECT a.stofcy_0, a.ypiece_0, a.ydatdem_0, (SELECT nomusr_0 FROM autilis WHERE usr_0 = a.ydem_0) demandeur, b.ybpcnum_0 client, (SELECT bpcnam_0 FROM bpcustomer ra WHERE bpcnum_0 = b.ybpcnum_0) nomclient, itmref_0, (SELECT des1axx_0 FROM itmmaster r WHERE r.itmref_0 = b.itmref_0) des, yqtedem_0 qtedemande, yqtysor_0 qteconsomme, a.ydatval_0 datevalidite, a.ydatdeb_0 datedebvalid, a.ydatfin_0 datefinvalid, a.yperval_0 periodevalidite FROM ydemstkh a, ydemstkd b WHERE a.ypiece_0 = b.ypiece_0 AND a.ysign_0 = 2 AND yqtedem_0 - yqtysor_0 <> 0

/
drop table datamart_prix_conso 
/
create table datamart_prix_conso as SELECT x.itmref_0,(SELECT t.des1axx_0 FROM itmmaster t WHERE t.itmref_0 = x.itmref_0) libelle,Max(x.iptdat_0) iptdat_0,Sum(x.qtypcu_0) qtypcu_0,Max(laspurpri_0) laspurpri_0,der_date_achat(x.itmref_0) as DER_DATE_ACHAT_CONSO,der_prix_achat(x.itmref_0) der_prix_achat FROM stojou x,itmmvt t WHERE t.itmref_0 = x.itmref_0 AND t.stofcy_0 = x.stofcy_0 AND iptdat_0 BETWEEN '01/01/2020' AND '31/12/2026' AND x.itmref_0 LIKE 'CAMI%' AND x.vcrnum_0 NOT LIKE 'INV%' GROUP BY x.itmref_0 ORDER BY 1,2
/  
exit
/