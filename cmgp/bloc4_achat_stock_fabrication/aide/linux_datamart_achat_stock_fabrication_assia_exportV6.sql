drop table datamart_stock_initial
/

create table datamart_stock_initial as select a.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=a.itmref_0) libelle,sum(a.qtypcu_0) qte from stojou a where a.iptdat_0 between '01/01/2025' and '31/12/2026'  and a.vcrnum_0 not like 'INV%' and a.vcrnum_0 like 'INI%200%_9%'  group by a.itmref_0
/

drop table  datamart_receptions
/
create table  datamart_receptions as select r.pthnum_0 num_rec,r.rcpdat_0 date_rec,r.bpsnum_0 fr ,(select bpsnam_0 from bpsupplier s where s.bpsnum_0=r.bpsnum_0) nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0 qte,r.netpri_0 prixrcp ,t.chgcoe_0 coursprovisoirerecp ,p.netpri_0 prixcde ,d.netpri_0 prixfac ,(select distinct max(ratmlt_0)  from pinvoice ee where ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock from preceipt t,preceiptd r,itmmaster rr ,pinvoiced d,porderp p where t.pthnum_0=r.pthnum_0 and rr.itmref_0=r.itmref_0 and  r.rcpdat_0 between '01/01/2022' and '31/12/2026' and  r.pthnum_0=d.pthnum_0(+) and r.ptdlin_0=d.ptdlin_0(+) and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0 
/
drop table datamart_retour_frs
/
create table  datamart_retour_frs as select n.pnhnum_0,n.rtndat_0 date_,rr.itmref_0 art,rr.itmdes_0 des,sum(qtypuu_0) qte,netpri_0 prix ,decode(r.STOMGTCOD_0,2,'OUI','NON') gerernstock ,decode(n.CFMFLG_0,2,'OUI','NON')  valider  ,rr.pthnum_0 rec from preturnd rr,preturn n,itmmaster r where  rr.itmref_0=r.itmref_0 and  n.pnhnum_0=rr.pnhnum_0 and n.rtndat_0 between '01/01/2021' and '31/12/2022' group by rr.pthnum_0,n.pnhnum_0,n.rtndat_0,rr.itmref_0,rr.itmdes_0,netpri_0,n.CFMFLG_0,r.STOMGTCOD_0 
/
drop table datamart_assemblage
/
create table datamart_assemblage as select distinct vcrnum_0,trstyp_0,decode(vcrtyp_0,31,'Assemblage',32,'D�sassemblage') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=1 and iptdat_0 between '01/01/2019' and '31/12/2026'),0) qtefabacompose ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=2 and iptdat_0 between '01/01/2019' and '31/12/2026'),0) qtefabacomposant,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2019' and '31/12/2026' and (vcrnum_0 like 'BFM%' or vcrnum_0 like 'DES%')
/
drop table datamart_production
/
create table datamart_production as select distinct vcrnum_0,trstyp_0,decode(trstyp_0,5,'qtefabacompose',6,'qtefabacomposant') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des,sum(qtypcu_0) qte ,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2022' and '31/12/2026' and vcrnumori_0 like 'OF%' group by vcrnum_0,trstyp_0,iptdat_0 , itmref_0 ,pcu_0 
/
drop table datamart_entre_sortie
/
create table datamart_entre_sortie as select decode(vcrtyp_0,19,'ENTREE',20,'SORTIE') typ,iptdat_0,(select max(vcrdes_0) from smvth h where h.vcrnum_0=s.vcrnum_0) ref ,(select max(nomusr_0) from autilis e where e.usr_0=s.creusr_0) usr ,vcrnum_0,vcrlin_0,itmref_0,(select des1axx_0 from itmmaster i where i.itmref_0=s.itmref_0) des,qtypcu_0 from stojou s where vcrtyp_0 in ('19','20') and iptdat_0 between '01/01/2022' and '31/12/2026' and vcrnum_0 not like 'INI%200%_9%' 
/

drop table datamart_facture_frs
/
create table datamart_facture_frs as select aa.accdat_0 Dfac,aa.num_0 Nfac,aa.bpr_0 Frs,(select oo.bpsnam_0 from bpsupplier oo where oo.bpsnum_0=aa.bpr_0) nom,kk.pthnum_0 NumRec,kk.pnhnum_0 NumRet,(select u.rcpdat_0 from preceipt u where u.pthnum_0=kk.pthnum_0) date_Rec,(select t.rtndat_0 from preturn t where t.pnhnum_0=kk.pnhnum_0) date_ret,kk.itmref_0 CodeArt,kk.itmdes1_0 Designation,(select l.cry_0 from bpartner l where l.bprnum_0=aa.bpr_0) Pays,kk.qtypuu_0 Qt�,kk.netpri_0 PUHT,kk.amttaxlin1_0+kk.amttaxlin2_0 tva,kk.amtatilin_0 TTC,aa.cur_0,aa.ratmlt_0 cours from pinvoice aa,pinvoiced kk where aa.num_0=kk.num_0 and aa.accdat_0 between '01/01/2022' and '31/12/2026' and aa.fcy_0<>'FR' and (kk.qtypuu_0 <> 0) 
/
drop table datamart_creances_client
/
create table datamart_creances_client as select * from (select a.num_0,a.sta_0,a.accdat_0 dat,b.mtc_0,a.jou_0,b.acc_0,substr(b.acc_0,1,4) racine,b.bpr_0 tiers ,(select bpcnam_0 from bpcustomer c where c.bpcnum_0=b.bpr_0) nomclt,(select sum(payloc_0*e.sns_0)from gaccdudate e where e.num_0 = b.num_0 and e.bpr_0=b.bpr_0 and e.lig_0=b.lin_0 )mntreg,substr(b.bpr_0,2,1) categ,b.sns_0*b.amtled_0 MNT,a.duddat_0 date_ech,b.des_0 from gaccentry a,gaccentryd b where a.typ_0=b.typ_0 and a.num_0=b.num_0 and a.accdat_0 between '01/01/2008' and sysdate and substr(b.acc_0,1,4) in ('3425','3426','3424','3421','3427','3428','3429')and (b.mtc_0=' ' or b.mtc_0 between 'a' and 'z') and b.bpr_0<>'ZZZZ'  and a.typ_0 not in ('RAN','AN')  order by bpr_0,mtc_0 )where mnt-mntreg<>0
/
drop table datamart_creances_client_fac 
/
create table datamart_creances_client_fac as  select  jou_0,decode(substr(c1.typ_0,1,1),'F','FACTURE','A','FACTURE','V','FACTURE','I','IMPAYE','REGLEMENT NON LETTRE') typ,  c.bpr_0 code,(select bpcnam_0 from bpcustomer r where r.bpcnum_0=bpr_0) nom , c1.num_0 num,c1.accdat_0 dat,acc_0 compte,c.amtled_0*c.sns_0  mnt_ttc ,nvl((select sum(payloc_0*e.sns_0) from gaccdudate e where e.num_0 = c.num_0 and e.bpr_0=c.bpr_0 and e.lig_0=c.lin_0),0) mntpaye ,c.amtled_0*c.sns_0-nvl((select sum(payloc_0*e.sns_0) from gaccdudate e where e.num_0 = c.num_0 and e.bpr_0=c.bpr_0 and e.lig_0=c.lin_0),0) mntrestapaye,mtc_0 lettrage     from gaccentry c1, gaccentryd c where c1.typ_0 = c.typ_0 and c1.num_0 = c.num_0 and c.acc_0 = '34210000' and c1.typ_0 <> 'RAN'  and  c1.accdat_0 >='01/01/2008'  and jou_0='VT' 
/
drop table datamart_stock_theorique
/
create table datamart_stock_theorique as select stofcy_0,to_char(sysdate,'dd/mm/yyyy') dateinv,itmref_0,sum(qtypcu_0) stk from stock where itmref_0 not like 'C%' group by stofcy_0,itmref_0
/
drop table datamart_stojou
/
create table datamart_stojou as select iptdat_0,vcrnum_0,vcrtyp_0,vcrlin_0,vcrnumori_0,vcrlinori_0,stofcy_0,itmref_0,qtypcu_0,priord_0,bprnum_0 from stojou where iptdat_0 between '01/01/2022' and '31/12/2026' and itmref_0 not like 'C%'
/
drop table datamart_cde_achat
/
create table datamart_cde_achat as select a.pohnum_0,a.bpsnum_0,a.pohfcy_0,a.bprnam_0,a.orddat_0,a.rcpflg_0,a.invflg_0,a.ystatus_0,a.xetape_0,a.xetaped2_0 ,b.itmref_0,b.itmdes1_0,b.netpri_0,b.vat_0,c.qtypuu_0,c.rcpqtypuu_0 ,c.rcpcleflg_0,a.cur_0,xtratime_0 trtime,xdelini_0 dateprliv,b.poplin_0 ,decode(a.cur_0,'MAD',decode(a.bpsnum_0,'208','simay',(select max(pshnum_0) from prequiso k where k.pohnum_0= a.pohnum_0)),get_da(a.pohnum_0,' ','1',b.itmref_0) ) DA,(select max(xstrnum_0) from prequis l where l.pshnum_0 =  decode(a.cur_0,'MAD',decode(a.bpsnum_0,'208','simay',(select max(pshnum_0) from prequiso k where k.pohnum_0= a.pohnum_0)) ,get_da(a.pohnum_0,' ','1',b.itmref_0) ))  typ_DA,(select max(l.CCE_0) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) agence,(select max(l.CCE_0) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) projet,(select max(l.CCE_2) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) vehicule,(select max(l.CCE_3) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) salarie,(select max(l.CCE_4) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) centre,(select max(l.CCE_5) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) bline,(select max(l.CCE_6) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) sites,(select max(l.CCE_7) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) entite,(select max(l.CCE_8) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) cce8,(select max(l.CCE_9) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) cce9,get_bc_type(xtype_0) type_bc ,(select max(PREQUISO.PSDLIN_0) from PREQUISO where PREQUISO.pohnum_0=a.pohnum_0 and PREQUISO.poplin_0=c.poplin_0) lin_da,case when LINCLEFLG_0 =2 then 'Oui' else 'Non' end solder ,case when xtype_0='CDI' then 'IMPORT' else 'LOCALE' end TYPE_CMD from porder a,porderp b,porderq c where a.pohnum_0=b.pohnum_0 and a.pohnum_0=c.pohnum_0 and b.poplin_0=c.poplin_0 and b.popseq_0=c.poqseq_0 and a.orddat_0 >= '01/01/2021'  and betfcy_0<>2
/
drop table datamart_dos_import_achat 
/
create table datamart_dos_import_achat as select xgetape.xdanum_0,xgetape.xetdat_0,xgpohlin.pohnum_0,xgpohlin.poplin_0,xgpohlin.xdaqty_0,xgpohlin.pthnum_0 from xgetape ,xgpohlin where xgetape.xdanum_0=xgpohlin.xdanum_0 and xetape_0=175
/
drop table datamart_XHISVAL
/
create table datamart_XHISVAL as select * from XHISVAL
/
drop table datamart_da
/
create table datamart_da as select a.pshnum_0,a.pshfcy_0,a.cleflg_0,a.requsr_0,a.ordflg_0,a.prqdat_0,a.xclient_0,a.XANNUL_0,a.XREVENDU_0,a.XREFUS_0,a.XSOUMIS_0,a.XSTATUS_0,a.XAFFECT_0,a.XHEURE_0,a.XTYPPROJ_0,a.XLIEU_0,a.XMARCHE_0,a.XDAIMPORT_0,a.YPOHINT_0,a.XETAPE_0,a.XETAPED1_0,a.XETAPED2_0,a.XSIGNER_0,a.XSOUMIS_1_0,a.XSTATUS_1_0,a.XDAT_SOUMI_0,a.XDAT_VALID_0,a.XUSR_SOUMI_0,a.XUSR_VALID_0,a.XUSR_SOUMA_0,a.XTCCRGCDE_0,a.XSITEUSINE_0,a.XNOMCONTCT_0,a.XNUMTELE_0,a.XNUMMATR_0,a.SOUMIUSINE_0,a.XUSINEDIR_0,get_da_type(a.XSTRNUM_0) XSTRNUM_0,a.XCDECLT_0,a.XTRAITEMENT_0,a.XHEUREVALID_0,a.XDATESIGN_0,a.XCHRGDA_0,a.YUN_0,a.ZSBU_0,a.XOBSERVATION_0,a.YSTATUS_0,a.YNIV_0,a.credat_0,a.creusr_0,b.itmref_0,b.itmdes1_0,b.gropri_0,b.discrgval1_0, b.netpri_0,b.psdlin_0,b.bpsnum_0,b.qtypuu_0,ordqtypuu_0,cur_0,vat_0 ,  vat_1 ,xtraiter_0 ,lincleflg_0,linordflg_0  ,xdaterec_0 ,linappflg_0 ,xobs_0 ,xvalide_0 ,(select max(l.CCE_0) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) agence,(select max(l.CCE_1) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) projet,(select max(l.CCE_2) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) vehicule,(select max(l.CCE_3) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) salarie,(select max(l.CCE_4) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) centre,(select max(l.CCE_5) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) bline,(select max(l.CCE_6) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) site,(select max(l.CCE_7) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) entite,(select max(l.CCE_8) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) cce8,(select max(l.CCE_9) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) cce9 from prequis a, prequisd b where a.prqdat_0  between '01/01/2025' and '31/12/2026' and a.pshnum_0=b.pshnum_0
/

drop table datamart_creances_client_hamza
/
create table datamart_creances_client_hamza as select * from (select a.num_0,a.sta_0,a.accdat_0 dat,b.mtc_0,a.jou_0,b.acc_0,substr(b.acc_0,1,4) racine,b.bpr_0 tiers ,(select bpcnam_0 from bpcustomer c where c.bpcnum_0=b.bpr_0) nomclt,(select sum(payloc_0*e.sns_0)from gaccdudate e where e.num_0 = b.num_0 and e.bpr_0=b.bpr_0 and e.lig_0=b.lin_0 )mntreg,substr(b.bpr_0,2,1) categ,b.sns_0*b.amtled_0 MNT,a.duddat_0 date_ech,b.des_0 from gaccentry a,gaccentryd b where a.typ_0=b.typ_0 and a.num_0=b.num_0 and a.accdat_0 between '01/01/2008' and sysdate and substr(b.acc_0,1,4) in ('3425','3426','3424','3421','3427','3428','3429')and  substr(b.mtc_0,1,1) not  between 'A' and 'Z' and b.bpr_0<>'ZZZZ' and substr(b.bpr_0,2,1) <> 'L'  and a.typ_0 not in ('RAN','AN')  order by bpr_0,mtc_0 )
/

exit
/


