create table  datamart_sta_art_t as select (select f1.tsicod_2 from itmmaster f1 where f1.itmref_0=vv1.itmref_0)  fam,vv1.itmref_0 code,(select d1.des1axx_0 from itmmaster d1 where d1.itmref_0=vv1.itmref_0) libelle,sum(decode(v1.gte_0,'FAC',vv1.qty_0,0))+sum(decode(v1.gte_0,'FCP',vv1.qty_0,0)) + sum(decode(v1.gte_0,'AVC',-1*vv1.qty_0,0))+ sum(decode(v1.gte_0,'AVP',-1*vv1.qty_0,0))+ sum(decode(v1.gte_0,'AFV',-1*vv1.qty_0,0)) QTE,sum(decode(v1.gte_0,'FAC',vv1.amtnotlin_0,0)) + sum(decode(v1.gte_0,'FCP',vv1.amtnotlin_0,0)) + sum(decode(v1.gte_0,'AVC',vv1.amtnotlin_0*-1,0)) + sum(decode(v1.gte_0,'AVP',vv1.amtnotlin_0*-1,0))+sum(decode(v1.gte_0,'AFV',vv1.amtnotlin_0*-1,0))  CA_NET_HT from sinvoice v1,sinvoiced vv1 where v1.num_0=vv1.num_0 and v1.accdat_0 between '01/01/2025' and '31/12/2026' group by vv1.itmref_0
/
insert into datamart_sta_art_t (select  (select f2.tsicod_2 from itmmaster f2 where f2.itmref_0=vv2.itmref_0)  fam,vv2.itmref_0 code,(select d2.des1axx_0 from itmmaster d2 where d2.itmref_0=vv2.itmref_0) libelle,sum(vv2.qty_0) Qte,sum(vv2.netprinot_0*vv2.qty_0) CA_NET_HT from sdelivery v2,sdeliveryd vv2 where  v2.sdhnum_0=vv2.sdhnum_0 and v2.dlvdat_0 between '01/01/2025' and '31/12/2026' and v2.bpcord_0 not in ('A','B','G','C','M','I','K','L','M','N','D','T','S','E','U','J','Q','MKT') and v2.invflg_0=1 and v2.betfcy_0=1 and v2.sdhnum_0 like 'B%' group by vv2.itmref_0) union (select (select f.tsicod_2 from itmmaster f where f.itmref_0=vv.itmref_0)  fam,vv.itmref_0 code,(select d.des1axx_0 from itmmaster d where d.itmref_0=vv.itmref_0) libelle,sum(vv.qty_0)*-1 Qte,sum(vv.netpri_0*vv.qty_0) *-1 CA_NET_HT from sreturn v,sreturnd vv where  v.srhnum_0=vv.srhnum_0 and v.rtndat_0 between '01/01/2025' and '31/12/2026' and v.betfcy_0=1 and v.bpcord_0 not in ('A','B','G','C','M','I','K','L','M','N','D','T','S','E','U','J','Q','MKT')  and (v.srhnum_0,vv.srdlin_0) in (select d.srhnum_0,dd.srdlin_0 from sreturn d,sreturnd dd where d.srhnum_0=dd.srhnum_0 and d.rtndat_0 between '01/01/2025' and '31/12/2026' and d.bpcord_0=v.bpcord_0 minus select bb.srhnum_0,bb.srdlin_0  from sinvoice b,sinvoiced bb where b.num_0=bb.num_0 and b.gte_0 in ('AVC','AVP')  and b.bpr_0=v.bpcord_0) group by vv.itmref_0 )
/
commit
/
create table  datamart_sta_art_glb_t as select code,sum(qte) qte,sum(ca_net_ht) ca_net_ht from datamart_sta_art_t group by code
/
create table datamart_mvt_cmgp0_t as 
select   p.pthnum_0,p.rcpdat_0,p.itmref_0,p.itmdes1_0,p.qtypuu_0,p.netpri_0,kk.xprirev_0,kk.mltcur_0 ,      (select ii.cpr_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0  and i.ydanum_0<>' ') cpr,(select  sum(p2.cpr_0 ) from preceiptd pa, pinvoiced p1, pinvoiced p2, pinvoice xx where pa.pthnum_0=p1.numori_0 and pa.ptdlin_0=p1.linori_0 and pa.itmref_0=p1.itmref_0 and p1.num_0=xx.num_0 and p1.num_0=p2.numori_0 and p1.pidlin_0=p2.pidlin_0 and pa.pthnum_0=p.pthnum_0 and pa.itmref_0=p.itmref_0) cpr2, decode((select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.ydanum_0<>' ') , null,(select distinct revcours_0 from tabchange where curden_0 =(select distinct CUR_0 from preceipt x where x.pthnum_0=p.pthnum_0) and chgtyp_0=1 and chgstrdat_0=(select max(chgstrdat_0) from TABCHANGE where  curden_0 =(select distinct CUR_0 from preceipt x where x.pthnum_0=p.pthnum_0))),(select i.ratmlt_0 from pinvoice i,pinvoiced ii where i.num_0=ii.num_0 and ii.pthnum_0=p.pthnum_0 and ii.ptdlin_0=p.ptdlin_0 and i.ydanum_0<>' ')) ratcur from preceiptd p,xgpohlin  k ,xgdetpri kk where p.pthnum_0=k.pthnum_0 (+) and p.ptdlin_0=k.ptdlin_0 (+) and p.rcpdat_0  between '01/01/2025' and '31/12/2026'  and substr(p.bpsnum_0,1,1) between '0' and '1' and k.itmref_0=kk.itmref_0 (+) and k.xdanum_0=kk.xdanum_0 (+)
/
create table datamart_mvt_cmgp_t as select * from (select pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD') mois,qte qte,avg(round(prixrev,6)) prixrev from  (select rr.pthnum_0,rr.rcpdat_0,rr.itmref_0,rr.qtypuu_0 qte,rr.netpri_0,decode(rr.mltcur_0,null,rr.ratcur,rr.mltcur_0) cur, decode(rr.xprirev_0,null,(rr.netpri_0*rr.ratcur)+nvl(cpr2,0),nvl(rr.xprirev_0,0)+nvl(cpr2,0)) prixrev,cpr2 from datamart_mvt_cmgp0_t rr ) group by pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD'),qte union (select x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD') Mois,sum(x.qtypuu_0 ) qte,x.netpri_0 PrixRev from preceiptd x where x.rcpdat_0 between  '01/01/2025' and '31/12/2026'  and   substr(x.bpsnum_0,1,1) between '2' and '9' group by x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD'),x.netpri_0 ) union select x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD') Mois,sum(x.qtypcu_0) qte,x.priord_0 PrixRev from stojou x where   ((substr(x.vcrnum_0,1,3) in ('BFM','ATL','ENT','MTK') and x.iptdat_0 between '01/01/2025' and '31/12/2026'   and x.trstyp_0 in (1,5))  or (x.vcrnum_0 not like 'INV%' and x.vcrnum_0 like 'IN%' and x.iptdat_0 between '01/01/2025' and '31/12/2026' )) group by x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD'),x.priord_0 ) order by 2,3
/
update datamart_mvt_cmgp_t set prixrev = prixrev *-1 where prixrev < 0
/
commit
/
create table datamart_fifo_cmgp_t as select ff.mois,ff.itmref_0,ff.prixrev,sum(ff.qte) qte from datamart_mvt_cmgp_t ff group by ff.mois,ff.itmref_0,ff.prixrev
/
create table datamart_synthesefifo_t as select itmref_0,mois,prixrev,sum(qte) qte,max(0) montant,max(0) qtetraiter,max(0) prix_rec from datamart_fifo_cmgp_t group by mois,itmref_0,prixrev
/
create table datamart_stock_ini_fifo_t as select   distinct  code,  qte stock,0 prixrev,'01/01/2025' dat_fifo  from   datamart_sta_art_glb_t
/
declare cursor cur2 is select rowid,t.itmref_0,t.mois,t.prixrev,qte,qtetraiter from datamart_synthesefifo_t t order by 2,3 desc ;
cursor cur1 is select code, stock from  datamart_stock_ini_fifo_t order by 1;
wcode_cur2 varchar2(60);wmois_cur2 varchar2(6);wprix_cur2 number;wqte_cur2 number;wwprix_sauv number;wcode_cur1 varchar2(60);wqte_cur1 number;wid varchar2(100);wqte number;wreliquat number;wsauv_reliquat number;wmontant number;passe integer;neg integer;wqtetraiter number(22);
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
      
      update datamart_synthesefifo_t a set a.montant=wmontant, a.qtetraiter=wqte where a.itmref_0=wcode_cur2 and a.mois=wmois_cur2       and a.qte=wqte_cur2 and a.rowid=wid;
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
update datamart_stock_ini_fifo_t z set z.prixrev= nvl((select sum(prixrev*qtetraiter  )/decode(sum(qtetraiter ),0,9999999999999999,sum(qtetraiter )) from datamart_synthesefifo zz where trim(zz.itmref_0)=trim(z.code)),0)
/
commit
/
update datamart_stock_ini_fifo_t set prixrev = prixrev * -1 where prixrev < 0
/
select * from datamart_stock_ini_fifo_t
/
DROP TABLE DATAMART_STA_ART_T PURGE;
/
DROP TABLE DATAMART_STA_ART_GLB_T PURGE;
/
DROP TABLE DATAMART_MVT_CMGP0_T PURGE;
/
DROP TABLE DATAMART_MVT_CMGP_T PURGE;
/
DROP TABLE DATAMART_FIFO_CMGP_T PURGE;
/
DROP TABLE DATAMART_SYNTHESEFIFO_T PURGE;
/
DROP TABLE DATAMART_STOCK_INI_FIFO_T PURGE;
/