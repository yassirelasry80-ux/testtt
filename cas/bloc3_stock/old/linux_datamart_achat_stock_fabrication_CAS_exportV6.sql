drop table datamart_stock_initial
/

create table datamart_stock_initial as select a.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=a.itmref_0) libelle,sum(a.qtypcu_0) qte from stojou a where a.iptdat_0 between '01/01/2026' and '01/01/2026'    group by a.itmref_0
/

drop table  datamart_receptions
/
--create table  datamart_receptions as select r.pthnum_0 num_rec,r.rcpdat_0 date_rec,r.bpsnum_0 fr ,BPONAM_0 nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0 qte,r.netpri_0 prixrcp ,t.chgcoe_0 coursprovisoirerecp ,p.netpri_0 prixcde ,(select  d.netpri_0 from pinvoiced d where  r.pthnum_0=d.pthnum_0 and r.ptdlin_0=d.ptdlin_0 and rownum=1) prixfac,(select distinct max(ratmlt_0)  from pinvoice ee ,pinvoiced d where  r.pthnum_0=d.pthnum_0 and r.ptdlin_0=d.ptdlin_0 and ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock,r.prhfcy_0 site_rec,r.pohnum_0 cmd,r.ptdlin_0 ligne_rec from preceipt t,preceiptd r,itmmaster rr ,porderp p where t.pthnum_0=r.pthnum_0 and rr.itmref_0=r.itmref_0  AND BETFCY_0<>2  and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0  
create table  datamart_receptions as SELECT r.pthnum_0 AS num_rec, r.rcpdat_0 AS date_rec, r.bpsnum_0 AS fr, BPONAM_0 AS nom_fr, r.itmref_0 AS art, r.itmdes1_0 AS des, r.qtypuu_0 AS qte, r.netpri_0 AS prixrcp, t.chgcoe_0 AS coursprovisoirerecp, p.netpri_0 AS prixcde, pf.prixfac, pf.coursfac, DECODE(rr.stomgtcod_0,2,'OUI','NON') AS gerernstock, r.prhfcy_0 AS site_rec, r.pohnum_0 AS cmd, r.ptdlin_0 AS ligne_rec,' ' DI ,r.POPLIN_0 ligne_cmd,r.INVQTYSTU_0 qte_fact FROM preceipt t INNER JOIN preceiptd r ON t.pthnum_0 = r.pthnum_0 INNER JOIN itmmaster rr ON rr.itmref_0 = r.itmref_0 LEFT JOIN porderp p ON p.pohnum_0 = r.pohnum_0 AND p.poplin_0 = r.poplin_0 LEFT JOIN (SELECT d.pthnum_0, d.ptdlin_0, MIN(d.netpri_0) AS prixfac, MAX(e.ratmlt_0) AS coursfac FROM pinvoiced d INNER JOIN pinvoice e ON e.num_0 = d.num_0 GROUP BY d.pthnum_0, d.ptdlin_0) pf ON pf.pthnum_0 = r.pthnum_0 AND pf.ptdlin_0 = r.ptdlin_0 WHERE t.betfcy_0 <> 2;
/
INSERT INTO datamart_receptions SELECT r.PNHNUM_0,r.RTNDAT_0 ,r.bpsnum_0 fr ,(select bpsnam_0 from bpsupplier s where s.bpsnum_0=r.bpsnum_0) nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0*-1 qte,r.netpri_0 prixrcp ,nvl((select h.chgcoe_0 from preceipt h where h.pthnum_0=r.pthnum_0),1) ,p.netpri_0 prixcde ,d.netpri_0 prixfac ,(select distinct max(ratmlt_0)  from pinvoice ee where ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock,r.PNHFCY_0 site_rec,r.pohnum_0 cmd,r.ptdlin_0 ligne_rec,' ' DI ,r.POPLIN_0 ligne_cmd,r.INVQTYSTU_0 qte_fact from preturn t,preturnd r,itmmaster rr ,pinvoiced d,porderp p where t.PNHNUM_0=r.PNHNUM_0 and rr.itmref_0=r.itmref_0 and  r.RTNDAT_0 between '01/01/2023' and '31/12/2026'  and  r.PNHNUM_0=d.PNHNUM_0(+) and r.PNDLIN_0=d.PNDLIN_0(+) and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0 and t.betfcy_0=1 and t.xstrnum_0 not in ('ANR','AIMO');
/
update datamart_receptions set prixrcp=PRIXFAC where PRIXFAC is not null and prixrcp<>PRIXFAC
/
drop table datamart_retour_frs
/
create table  datamart_retour_frs as select n.pnhnum_0,n.rtndat_0 date_,rr.itmref_0 art,rr.itmdes_0 des,sum(qtypuu_0) qte,netpri_0 prix ,decode(r.STOMGTCOD_0,2,'OUI','NON') gerernstock ,decode(n.CFMFLG_0,2,'OUI','NON')  valider  ,rr.pthnum_0 rec from preturnd rr,preturn n,itmmaster r where  rr.itmref_0=r.itmref_0 and  n.pnhnum_0=rr.pnhnum_0 and n.rtndat_0 between '01/01/2026' and '31/12/2026' group by rr.pthnum_0,n.pnhnum_0,n.rtndat_0,rr.itmref_0,rr.itmdes_0,netpri_0,n.CFMFLG_0,r.STOMGTCOD_0 
/
drop table datamart_assemblage
/
create table datamart_assemblage as select distinct vcrnum_0,trstyp_0,decode(vcrtyp_0,31,'Assemblage',32,'Désassemblage') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=1 and iptdat_0 between '01/01/2026' and '31/12/2026'),0) qtefabacompose ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=2 and iptdat_0 between '01/01/2026' and '31/12/2026'),0) qtefabacomposant,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2026' and '31/12/2026' 
/
drop table datamart_production
/
create table datamart_production as select distinct vcrnum_0,trstyp_0,decode(trstyp_0,5,'qtefabacompose',6,'qtefabacomposant') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des,sum(qtypcu_0) qte ,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2026' and '31/12/2026' and vcrnumori_0 like 'OF%' group by vcrnum_0,trstyp_0,iptdat_0 , itmref_0 ,pcu_0 
/
drop table datamart_entre_sortie
/
create table datamart_entre_sortie as select decode(vcrtyp_0,19,'ENTREE',20,'SORTIE') typ,iptdat_0,(select vcrdes_0 from smvth h where h.vcrnum_0=s.vcrnum_0) ref ,(select nomusr_0 from autilis e where e.usr_0=s.creusr_0) usr ,vcrnum_0,vcrlin_0,itmref_0,(select des1axx_0 from itmmaster i where i.itmref_0=s.itmref_0) des,qtypcu_0 from stojou s where vcrtyp_0 in ('19','20') and iptdat_0 between '01/01/2026' and '31/12/2026' 
/

drop table datamart_facture_frs
/
create table datamart_facture_frs as select aa.accdat_0 Dfac,aa.num_0 Nfac,aa.bpr_0 Frs,(select oo.bpsnam_0 from bpsupplier oo where oo.bpsnum_0=aa.bpr_0) nom,kk.pthnum_0 NumRec,kk.pnhnum_0 NumRet,(select u.rcpdat_0 from preceipt u where u.pthnum_0=kk.pthnum_0) date_Rec,(select t.rtndat_0 from preturn t where t.pnhnum_0=kk.pnhnum_0) date_ret,kk.itmref_0 CodeArt,kk.itmdes1_0 Designation,(select l.cry_0 from bpartner l where l.bprnum_0=aa.bpr_0) Pays,kk.qtypuu_0 Qté,kk.netpri_0 PUHT,kk.amttaxlin1_0+kk.amttaxlin2_0 tva,kk.amtatilin_0 TTC,aa.cur_0,aa.ratmlt_0 cours from pinvoice aa,pinvoiced kk where aa.num_0=kk.num_0 and aa.accdat_0 between '01/01/2024' and '31/12/2026' and aa.fcy_0<>'FR' and (kk.qtypuu_0 <> 0) 
/





drop table datamart_stock_theorique
/
create table datamart_stock_theorique as select stofcy_0,to_char(sysdate,'dd/mm/yyyy') dateinv,itmref_0,sum(qtypcu_0) stk from stock  group by stofcy_0,itmref_0
/
drop table datamart_stojou
/

update itmmaster set xlastpricepo_0=nvl((select dernier_prix_achat_year(itmref_0,2025) FROM dual),xprixrev_0)
/
create table datamart_stojou as select iptdat_0,vcrnum_0,vcrtyp_0,vcrlin_0,vcrnumori_0,vcrlinori_0,stofcy_0,stojou.itmref_0,qtypcu_0, nvl(xlastpricepo_0,priord_0) priord_0,bprnum_0,case when TRSTYP_0 in (5,6) then 1 else 0 end fabrique  from stojou,itmmaster  where itmmaster.itmref_0=stojou.itmref_0 and iptdat_0 between '01/01/2024' and '31/12/2026' and REGFLG_0=1 

/

drop table  datamart_suivicommande_import

/
create table datamart_suivicommande_import as  select a.POHNUM_0 as num_cmd,a.bpsnum_0 fourn_code,a.bprnam_0 fourn_name,a.orddat_0 date_commande,a.crynam_0 pays,b.itmref_0  article,y.itmdes1_0 lib_article,b.qtystu_0 qte_commande,b.stu_0 unite,b.RCPQTYSTU_0 qte_rec,b.LINAMT_0/b.qtystu_0 prix_net,xtc_0 contener,EXTRCPDAT_0 date_prevu ,case when LINCLEFLG_0 =2 then 'Oui' else 'Non' end solder ,b.POHFCY_0 site_recept,CUR_0 from porder a,porderq b,itmmaster y where a.POHNUM_0=b.POHNUM_0 and   substr(a.bpsnum_0,1,1) in ('0') and y.itmref_0=b.itmref_0   order by a.orddat_0 desc;

/

drop table  datamart_commande_achat

/

create table datamart_commande_achat as select a.POHNUM_0 as num_cmd,a.bpsnum_0 fourn_code,a.bprnam_0 fourn_name,a.orddat_0 date_commande,a.crynam_0 pays,b.itmref_0  article,y.itmdes1_0 lib_article,b.qtystu_0 qte_commande,b.stu_0 unite,b.RCPQTYSTU_0 qte_rec,b.LINAMT_0/b.qtystu_0 prix_net,case when to_date(a.xetaped1_0, 'dd/mm/yyyy') <> to_date('31/12/99', 'dd/mm/yyyy') then a.xetaped1_0 when to_date(a.xetaped0_0, 'dd/mm/yyyy') <> to_date('31/12/99', 'dd/mm/yyyy') then a.xetaped0_0 else EXTRCPDAT_0 end    date_prevu ,case when LINCLEFLG_0 =2 then 'Oui' else 'Non' end solder ,b.POHFCY_0 site_recept,CUR_0,b.poplin_0 ligne_cmd,case when a.bpsnum_0 like '0%' then 2 else 1 end as type from porder a,porderq b,itmmaster y where a.POHNUM_0=b.POHNUM_0  and y.itmref_0=b.itmref_0  AND BETFCY_0<>2 order by a.orddat_0 desc;

/

drop table  datamart_da
/
create table datamart_da as select a.pshnum_0,a.pshfcy_0,a.cleflg_0,a.requsr_0,a.ordflg_0,a.prqdat_0,a.xclient_0,get_da_type(a.XSTRNUM_0) XSTRNUM_0,a.XOBSERVATION_0,a.YSTATUS_0,a.YNIV_0,a.credat_0,a.creusr_0,b.itmref_0,b.itmdes1_0,b.gropri_0,b.discrgval1_0, b.netpri_0,b.psdlin_0,b.bpsnum_0,b.qtypuu_0,ordqtypuu_0,cur_0,vat_0 ,  vat_1 ,lincleflg_0,linordflg_0   ,linappflg_0  ,(select max(l.CCE_4) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) centre,(select max(l.CCE_5) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) bline,(select max(l.CCE_6) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) site,(select max(l.CCE_7) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) entite,(select max(l.CCE_8) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) cce8,(select max(l.CCE_9) from cptanalin l where l.vcrnum_0=a.pshnum_0 and l.vcrlin_0=b.psdlin_0) cce9,' ' as PROJET,' ' as VEHICULE,' ' as MATRICULE,yvalidateur_0 as validateur from prequis a, prequisd b where a.prqdat_0  between '01/01/2025' and '31/12/2026' and a.pshnum_0=b.pshnum_0


/

drop table datamart_cde_achat
/
create table datamart_cde_achat as select a.pohnum_0,a.bpsnum_0,a.pohfcy_0,a.bprnam_0,a.orddat_0,a.rcpflg_0,a.invflg_0,a.ystatus_0,a.xetape_0,a.xetaped2_0 ,b.itmref_0,b.itmdes1_0,b.netpri_0,b.vat_0,c.qtypuu_0,c.rcpqtypuu_0 ,c.rcpcleflg_0,a.cur_0,' ' trtime,' ' dateprliv,b.poplin_0 ,get_DA(a.pohnum_0) DA,(select get_da_type(l.xstrnum_0) from prequis l where l.pshnum_0 =  get_da(a.pohnum_0) )  typ_DA,get_bc_type(xstrnum_0) type_bc,' ' agence,' ' projet,' ' vehicule,' ' salarie,(select max(l.CCE_4) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) centre,(select max(l.CCE_5) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) bline,(select max(l.CCE_6) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) sites,(select max(l.CCE_7) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) entite,(select max(l.CCE_8) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) cce8,(select max(l.CCE_9) from cptanalin l where l.vcrnum_0=a.pohnum_0 and l.vcrlin_0=b.poplin_0) cce9 ,(select max(PREQUISO.PSDLIN_0) from PREQUISO where PREQUISO.pohnum_0=a.pohnum_0 and PREQUISO.poplin_0=c.poplin_0) lin_da,case when LINCLEFLG_0 =2 then 'Oui' else 'Non' end solder ,case when xtype_0='CDI' then 'IMPORT' else 'LOCALE' end TYPE_CMD from porder a,porderp b,porderq c where a.pohnum_0=b.pohnum_0 and a.pohnum_0=c.pohnum_0 and b.poplin_0=c.poplin_0 and b.popseq_0=c.poqseq_0 and a.orddat_0 >= '01/11/2025'  and betfcy_0<>2

/

drop table  datamart_facture_achat

/
create table datamart_facture_achat as select a.pihtyp_0 type,a.num_0 as num_fact,a.bpr_0 fourn_code,a.bprnam_0 fourn_name,a.accdat_0 date_facture,b.itmref_0  article,y.itmdes1_0 lib_article,b.qtyuom_0 qte_fact,b.uom_0 unite,b.NETPRI_0 prix_net,CUR_0,ratmlt_0 cours,b.pthnum_0 num_rec,b.ptdlin_0 ligne_rec,b.pohnum_0 num_cmd,b.poplin_0 ligne_cmd from pinvoice a,pinvoiced b,itmmaster y where a.num_0=b.num_0  and y.itmref_0=b.itmref_0  order by a.accdat_0 desc;
/


drop table  datamart_reception_achat

/

--create table  datamart_reception_achat as select r.pthnum_0 num_rec,r.rcpdat_0 date_rec,r.bpsnum_0 fr ,BPONAM_0 nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0 qte,r.netpri_0 prixrcp ,t.chgcoe_0 coursprovisoirerecp ,p.netpri_0 prixcde ,(select  d.netpri_0 from pinvoiced d where  r.pthnum_0=d.pthnum_0 and r.ptdlin_0=d.ptdlin_0 and rownum=1) prixfac,(select distinct max(ratmlt_0)  from pinvoice ee ,pinvoiced d where  r.pthnum_0=d.pthnum_0 and r.ptdlin_0=d.ptdlin_0 and ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock,r.prhfcy_0 site_rec,r.pohnum_0 cmd,r.ptdlin_0 ligne_rec from preceipt t,preceiptd r,itmmaster rr ,pinvoiced d,porderp p where t.pthnum_0=r.pthnum_0 and rr.itmref_0=r.itmref_0  AND BETFCY_0<>2 and  r.pthnum_0=d.pthnum_0(+) and r.ptdlin_0=d.ptdlin_0(+) and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0 
create table  datamart_reception_achat as SELECT r.pthnum_0 AS num_rec,r.rcpdat_0 AS date_rec,r.bpsnum_0 AS fr,bponam_0 AS nom_fr,r.itmref_0 AS art,r.itmdes1_0 AS des,r.qtypuu_0 AS qte,r.netpri_0 AS prixrcp,t.chgcoe_0 AS coursprovisoirerecp,p.netpri_0 AS prixcde,pf.prixfac,pf.coursfac,DECODE(rr.stomgtcod_0,2,'OUI','NON') AS gerernstock,r.prhfcy_0 AS site_rec,r.pohnum_0 AS cmd,r.ptdlin_0 AS ligne_rec FROM preceipt t JOIN preceiptd r ON t.pthnum_0=r.pthnum_0 JOIN itmmaster rr ON rr.itmref_0=r.itmref_0 LEFT JOIN porderp p ON p.pohnum_0=r.pohnum_0 AND p.poplin_0=r.poplin_0 LEFT JOIN (SELECT d.pthnum_0,d.ptdlin_0,MIN(d.netpri_0) prixfac,MAX(e.ratmlt_0) coursfac FROM pinvoiced d LEFT JOIN pinvoice e ON e.num_0=d.num_0 GROUP BY d.pthnum_0,d.ptdlin_0) pf ON pf.pthnum_0=r.pthnum_0 AND pf.ptdlin_0=r.ptdlin_0 WHERE t.betfcy_0<>2;
/
update datamart_reception_achat set prixrcp=PRIXFAC where PRIXFAC is not null and prixrcp<>PRIXFAC
/
update sorder set ordsta_0=2 where betfcy_0=2 and orddat_0<ADD_MONTHS(CURRENT_DATE,-1)  and ordsta_0=1
/

update porder set cleflg_0=2 where betfcy_0=2 and orddat_0<ADD_MONTHS(CURRENT_DATE,-1)  and cleflg_0=1
/
update sorder set clelinnbr_0=linnbr_0 where betfcy_0=2 and orddat_0<ADD_MONTHS(CURRENT_DATE,-1)  and clelinnbr_0<>linnbr_0
/
drop table DATAMART_XHISVAL
/
create table DATAMART_XHISVAL as select * from XHISVAL
/
commit
/
exit
/


