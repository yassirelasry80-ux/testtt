drop table datamart_stock_initial
/

create table datamart_stock_initial as select a.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=a.itmref_0) libelle,sum(a.qtypcu_0) qte from stojou a where a.iptdat_0 between '01/01/2023' and '01/01/2024'    group by a.itmref_0
/

drop table  datamart_receptions
/
create table  datamart_receptions as select r.pthnum_0 num_rec,r.rcpdat_0 date_rec,r.bpsnum_0 fr ,(select bpsnam_0 from bpsupplier s where s.bpsnum_0=r.bpsnum_0) nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0 qte,r.netpri_0 prixrcp ,t.chgcoe_0 coursprovisoirerecp ,p.netpri_0 prixcde ,d.netpri_0 prixfac ,(select distinct max(ratmlt_0)  from pinvoice ee where ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock,r.prhfcy_0 site_rec,r.pohnum_0 cmd,r.ptdlin_0 ligne_rec from preceipt t,preceiptd r,itmmaster rr ,pinvoiced d,porderp p where t.pthnum_0=r.pthnum_0 and rr.itmref_0=r.itmref_0 and  r.rcpdat_0 between '01/01/2024' and '31/12/2026'  and  r.pthnum_0=d.pthnum_0(+) and r.ptdlin_0=d.ptdlin_0(+) and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0 
/
drop table datamart_retour_frs
/
create table  datamart_retour_frs as select n.pnhnum_0,n.rtndat_0 date_,rr.itmref_0 art,rr.itmdes_0 des,sum(qtypuu_0) qte,netpri_0 prix ,decode(r.STOMGTCOD_0,2,'OUI','NON') gerernstock ,decode(n.CFMFLG_0,2,'OUI','NON')  valider  ,rr.pthnum_0 rec from preturnd rr,preturn n,itmmaster r where  rr.itmref_0=r.itmref_0 and  n.pnhnum_0=rr.pnhnum_0 and n.rtndat_0 between '01/01/2024' and '31/12/2026' group by rr.pthnum_0,n.pnhnum_0,n.rtndat_0,rr.itmref_0,rr.itmdes_0,netpri_0,n.CFMFLG_0,r.STOMGTCOD_0 
/
drop table datamart_assemblage
/
create table datamart_assemblage as select distinct vcrnum_0,trstyp_0,decode(vcrtyp_0,31,'Assemblage',32,'Désassemblage') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=1 and iptdat_0 between '01/01/2024' and '31/12/2026'),0) qtefabacompose ,nvl((select sum(qtypcu_0) from stojou s where s.itmref_0=ss.itmref_0 and s.vcrnum_0=ss.vcrnum_0 and trstyp_0=2 and iptdat_0 between '01/01/2024' and '31/12/2026'),0) qtefabacomposant,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2024' and '31/12/2026' 
/
drop table datamart_production
/
create table datamart_production as select distinct vcrnum_0,trstyp_0,decode(trstyp_0,5,'qtefabacompose',6,'qtefabacomposant') typ,iptdat_0 date_, itmref_0,(select des1axx_0 from itmmaster m where m.itmref_0=ss.itmref_0) des,sum(qtypcu_0) qte ,pcu_0 unitstk from stojou ss where iptdat_0 between  '01/01/2024' and '31/12/2026' and vcrnumori_0 like 'OF%' group by vcrnum_0,trstyp_0,iptdat_0 , itmref_0 ,pcu_0 
/
drop table datamart_entre_sortie
/
create table datamart_entre_sortie as select decode(vcrtyp_0,19,'ENTREE',20,'SORTIE') typ,iptdat_0,(select vcrdes_0 from smvth h where h.vcrnum_0=s.vcrnum_0) ref ,(select nomusr_0 from autilis e where e.usr_0=s.creusr_0) usr ,vcrnum_0,vcrlin_0,itmref_0,(select des1axx_0 from itmmaster i where i.itmref_0=s.itmref_0) des,qtypcu_0 from stojou s where vcrtyp_0 in ('19','20') and iptdat_0 between '01/01/2024' and '31/12/2026' 
/

drop table datamart_facture_frs
/
create table datamart_facture_frs as select aa.accdat_0 Dfac,aa.num_0 Nfac,aa.bpr_0 Frs,(select oo.bpsnam_0 from bpsupplier oo where oo.bpsnum_0=aa.bpr_0) nom,kk.pthnum_0 NumRec,kk.pnhnum_0 NumRet,(select u.rcpdat_0 from preceipt u where u.pthnum_0=kk.pthnum_0) date_Rec,(select t.rtndat_0 from preturn t where t.pnhnum_0=kk.pnhnum_0) date_ret,kk.itmref_0 CodeArt,kk.itmdes1_0 Designation,(select l.cry_0 from bpartner l where l.bprnum_0=aa.bpr_0) Pays,kk.qtypuu_0 Qté,kk.netpri_0 PUHT,kk.amttaxlin1_0+kk.amttaxlin2_0 tva,kk.amtatilin_0 TTC,aa.cur_0,aa.ratmlt_0 cours from pinvoice aa,pinvoiced kk where aa.num_0=kk.num_0 and aa.accdat_0 between '01/01/2023' and '31/12/2026' and aa.fcy_0<>'FR' and (kk.qtypuu_0 <> 0) 
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


drop table  datamart_facture_achat

/
create table datamart_facture_achat as select a.pihtyp_0 type,a.num_0 as num_fact,a.bpr_0 fourn_code,a.bprnam_0 fourn_name,a.accdat_0 date_facture,b.itmref_0  article,y.itmdes1_0 lib_article,b.qtyuom_0 qte_fact,b.uom_0 unite,b.NETPRI_0 prix_net,CUR_0,ratmlt_0 cours,b.pthnum_0 num_rec,b.ptdlin_0 ligne_rec,b.pohnum_0 num_cmd,b.poplin_0 ligne_cmd from pinvoice a,pinvoiced b,itmmaster y where a.num_0=b.num_0  and y.itmref_0=b.itmref_0  order by a.accdat_0 desc;
/


drop table  datamart_reception_achat

/

create table  datamart_reception_achat as select r.pthnum_0 num_rec,r.rcpdat_0 date_rec,r.bpsnum_0 fr ,BPONAM_0 nom_fr,r.itmref_0 art,r.itmdes1_0 des,r.qtypuu_0 qte,r.netpri_0 prixrcp ,t.chgcoe_0 coursprovisoirerecp ,p.netpri_0 prixcde ,d.netpri_0 prixfac ,(select distinct max(ratmlt_0)  from pinvoice ee where ee.num_0=d.num_0 ) coursfac ,decode(rr.STOMGTCOD_0,2,'OUI','NON') gerernstock,r.prhfcy_0 site_rec,r.pohnum_0 cmd,r.ptdlin_0 ligne_rec from preceipt t,preceiptd r,itmmaster rr ,pinvoiced d,porderp p where t.pthnum_0=r.pthnum_0 and rr.itmref_0=r.itmref_0  AND BETFCY_0<>2 and  r.pthnum_0=d.pthnum_0(+) and r.ptdlin_0=d.ptdlin_0(+) and p.pohnum_0(+)=r.pohnum_0 and p.poplin_0(+)=r.poplin_0 
/

--update datamart_commande_achat set qte_commande=qte_commande*1000,qte_rec=qte_rec*1000,prix_net=prix_net*1000,unite='KG' where article='EC031-KNITRHG-2500';
--/
--update datamart_stojou set qtypcu_0=qtypcu_0*1000 where itmref_0='EC031-KNITRHG-2500';
--/

exit
/


