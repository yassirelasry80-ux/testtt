drop table datamart_bl_ret_nf_bl
/
create table datamart_bl_ret_nf_bl as    select x.sdhnum_0 bl,y.sddlin_0 lig,x.salfcy_0 agence,x.dlvdat_0 date_bl,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,y.tsicod_0 FCMKT,' ' FCLIBMKT,y.tsicod_1 FTMKT,' ' FTLIBMKT,y.tsicod_2 FDMKT,' ' FDLIBMKT ,y.gropri_0 tarif,y.qty_0 qte,(y.qty_0*y.netpri_0) HTN,(y.qty_0*y.NETPRIATI_0) TTCN,(y.qty_0*y.gropri_0) HTB,substr(x.bpcord_0,2,1) categ,' ' proj,' ' canal,' ' sicda,  ' ' ARTF,  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) frs,   (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) ) lib_frs2,(select ' ' from bpcustomer f where f.bpcnum_0=x.bpcord_0) xclasse      from sdelivery x,sdeliveryd y where x.sdhnum_0=y.sdhnum_0 and x.betfcy_0=1 and y.qty_0<>y.rtnqty_0 and  x.dlvdat_0 between '01/01/2017' and '31/12/2026' and x.invflg_0=1  AND x.xstrnum_0 <> 'PRE' 
/

drop table datamart_bl_ret_nf_ret
/
create table datamart_bl_ret_nf_ret as select xx.srhnum_0 numret,yy.srdlin_0 lig,xx.salfcy_0 ag,xx.rtndat_0 date_bl,xx.bpcord_0 tiers,yy.itmref_0 article ,yy.itmdes1_0 lib,  (select tt.tsicod_0 from itmmaster tt where tt.itmref_0=yy.itmref_0) FCMKT,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FTMKT,(select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FDMKT,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FC,' ' FCLIBMKT,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0)  FT,' ' FTLIBMKT,(select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FD,' ' FDLIBMKT,  yy.netpri_0 tarif,yy.qty_0*-1 qte,(yy.qty_0*yy.NETPRINOT_0)*-1 HTN, (yy.qty_0*yy.NETPRIATI_0)*-1  HTTC ,(yy.qty_0*yy.netpri_0)*-1 HTB,  substr(xx.bpcord_0,2,1) categ,' ' proj,  ' ' canal,            ' ' sicda,   ' ' ARTF,    (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) frs,    (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) ) lib_frs2,(select ' ' from bpcustomer f where f.bpcnum_0=xx.bpcord_0) xclasse    from sreturn xx, sreturnd yy where xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2017' and '31/12/2026' and (yy.srhnum_0,yy.srdlin_0) not in (select pp.srhnum_0,pp.srdlin_0 from sinvoiced pp where pp.invdat_0 between '01/01/2017' and '31/12/2026' and pp.srhnum_0<>' ' and pp.bpcinv_0=xx.bpcord_0) AND (yy.sdhnum_0= ' ' or yy.sdhnum_0 in (select BL FROM datamart_bl_ret_nf_bl )) AND xx.xstrnum_0 <> 'PRE'
/

drop table datamart_BL_RET_NF
/
create table datamart_BL_RET_NF as select * from datamart_BL_RET_NF_bl union select * from datamart_BL_RET_NF_ret
/
commit
/
drop table datamart_BL_RET_FAC
/
create table datamart_BL_RET_FAC as select decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0) piece,decode(x.gte_0,'FAC',(select dlvdat_0 from sdelivery where sdhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)) , 'FCP', (select dlvdat_0 from sdelivery where sdhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)),'AVC',(select rtndat_0 from sreturn where srhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)),'AVP',(select rtndat_0 from sreturn where srhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)) ) date_piece,x.num_0 fac,decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence, x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,'              ' FCMKT,'                                        ' FCLIBMKT,'      ' FTMKT,'                             ' FTLIBMKT,'                ' FDMKT,'                              ' FDLIBMKT,y.gropri_0 tarif,decode(x.gte_0,'FAC',y.qty_0,'FCP',y.qty_0,'AVC',y.qty_0*-1,'AVP',y.qty_0*-1,'AFV',y.qty_0*-1) qte,decode(x.gte_0,'FAC',(y.qty_0*y.netpri_0*x.ratmlt_0),'FCP',(y.qty_0*y.netpri_0*x.ratmlt_0),'AVC',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1,'AVP',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1,'AFV',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1) HTN ,decode(x.gte_0,'FAC',(y.qty_0*y.gropri_0*x.ratmlt_0),'FCP',(y.qty_0*y.gropri_0*x.ratmlt_0),'AVC',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1,'AVP',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1,'AFV',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1) HTB ,substr(x.bpr_0,2,1) categ,'       ' proj,' '  canal,'                     ' sicda,'          ' ARTF, '      ' frs,'                                                  ' lib_frs2,(select ' ' from bpcustomer f where f.bpcnum_0=x.bpr_0) xclasse  from sinvoice x,sinvoiced y where x.num_0=y.num_0  and x.accdat_0 between '01/01/2017' and '31/12/2026' and x.gte_0 <> 'AFV' 
/
-------------------------------------
update datamart_bl_ret_fac y set 
fcmkt = (select t.tsicod_0 from itmmaster t where t.itmref_0=y.article),
FCLIBMKT=(select ' ' from itmmaster t where t.itmref_0=y.article) ,
FTMKT=(select t.tsicod_1 from itmmaster t where t.itmref_0=y.article) ,
FTLIBMKT=(select ' ' from itmmaster t where t.itmref_0=y.article) ,
FDMKT=(select t.tsicod_2 from itmmaster t where t.itmref_0=y.article) ,
FDLIBMKT=(select ' ' from itmmaster t where t.itmref_0=y.article) ,
proj = ' ' ,
sicda = ' ' ,
ARTF = ' ',
frs = (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article),
lib_frs2 = (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article) )
/

------------------------------------

update datamart_BL_RET_FAC set piece ='FORFAIT' where piece is null or piece=' '
/
update datamart_BL_RET_FAC set date_piece=date_fac where piece='FORFAIT'
/
update datamart_BL_RET_FAC z set z.proj=' '
/
commit
/
drop table datamart_remise_except
/
create table datamart_remise_except as select periode,tiers,fac,agence,categ,sum(remise_except) remise_except from ( select a.invdat_0 periode,a.bpcinv_0 tiers,a.num_0 fac,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0)*-1 remise_except from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2018' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and a.sivtyp_0 in ('FAC','FCP') group by a.invdat_0 ,a.bpcinv_0 ,a.num_0,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1) union select a.invdat_0 periode,a.bpcinv_0 tiers,a.num_0 fac,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0) remise_except from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2018' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and a.sivtyp_0 in ('AVO','AVP') group by a.invdat_0 ,a.bpcinv_0 ,a.num_0,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1) ) group by periode,tiers,fac,agence,categ
/
drop table datamart_av_financier
/
create table datamart_av_financier as select kk.bpr_0 tiers,kk.accdat_0 periode, substr(kk.bpr_0,2,1) categ,decode(substr(kk.bpr_0,1,1),'X','C','Y','C','Z','C',substr(kk.bpr_0,1,1)) agence,kk.num_0,kk.amtnot_0 HT,kk.amtati_0 TTC,(select ' ' from bpcustomer f where f.bpcnum_0=kk.bpr_0) xclasse   from sinvoice kk where kk.accdat_0 between '01/01/2017' and '31/12/2026' and kk.num_0 like 'AF%'
/


drop table datamart_code_ag
/
create table datamart_code_ag as select fcy_0 code_ag, fcynam_0 lib  from facility where fcy_0 not in ('PRC','AGR')
/

drop table datamart_creances_client
/
create table datamart_creances_client as  select a.num_0,a.sta_0,a.accdat_0 dat,b.mtc_0,a.jou_0,b.acc_0,substr(b.acc_0,1,4) racine,b.bpr_0 tiers ,(select bpcnam_0 from bpcustomer c where c.bpcnum_0=b.bpr_0) nomclt ,substr(b.bpr_0,2,1) categ,b.sns_0*b.amtled_0 MNT,case when  jou_0='VE' then (a.accdat_0+(select XDRECOUVR_0 from bpcustomer where bpcnum_0=b.bpr_0)) else a.duddat_0 end date_ech,b.des_0,0 solde,b.SNS_0,b.accnum_0,case when a.num_0 like '%IMP%' then 1 else 0 end as impaye  from gaccentry a,gaccentryd b where a.typ_0=b.typ_0 and a.num_0=b.num_0 and a.accdat_0 between '01/01/2008' and '31/12/2026' and substr(b.acc_0,1,4) in ('3425','3426','3424','3421','3427','3428','3429') and (b.mtc_0=' ' or b.mtc_0 between 'a' and 'z') and b.bpr_0<>'ZZZZ'  and    ( a.typ_0 <> 'RANX1' or  ( a.typ_0= 'RANX1' AND EXTRACT(YEAR FROM a.accdat_0)=2021 ))  and b.ledtyp_0=1 union select  nnum,3 typ,dat,mtc,' ' jou,acc,substr(acc,1,4) racine,code,nom,substr(code,2,1) categ,mnt_ttc-mnt mnt_ttc,datec,des,0 solde,sns,0 accnum, 0 impaye  from (select x.bpr_0 code,x.bpanam_0 nom,x.num_0 nnum,x.duddat_0 datec,x.amtcur_0 mnt_ttc,decode(cc.chk_0,' ',0,null,0,(select sum(paycur_0*e.sns_0) from gaccdudate e where e.num_0 = c.num_0 and e.bpr_0=c.bpr_0 and e.lig_0=c.lin_0)) mnt,c.mtc_0 mtc,c.acc_0 acc,x.accdat_0 dat,c.des_0 des,cc.sns_0 sns from paymenth x ,gaccentryd c,gaccentryd cc where  c.accnum_0(+)=x.accnumtre_2  and x.sta_0 between 2 and 10  and   cc.accnum_0(+)=x.accnumtre_8 and ( x.sta_0 > 2 and    x.sta_0 <> 10) and (x.bprsac_0='CL1' and x.pam_0 in ('CHQ','TAC')) )where mnt_ttc-mnt<>0
/
 update datamart_creances_client set solde =mnt-nvl((select sum(payloc_0) from gaccdudate where gaccdudate.accnum_0=datamart_creances_client.accnum_0),0)*sns_0 where accnum_0<>0
/

drop table datamart_tiers
/
create table datamart_tiers as select bprnum_0 ,bprnam_0  from bpartner 
/
drop table datamart_facture_ncompt
/
create table datamart_facture_ncompt as select a.num_0,a.bpr_0,a.accdat_0,decode(a.gte_0,'AVC',a.amtnot_0*-1,a.amtnot_0) ht,decode(a.gte_0,'AVC',a.amtati_0*-1,a.amtati_0) ttc,decode(a.gte_0,'AVC',(a.amtati_0-a.amtnot_0)*-1,(a.amtati_0-a.amtnot_0)) tva from sinvoice a where a.accdat_0 > '01/01/2010' and a.amtnot_0 > 0 and a.sta_0<>3
/
commit
/

exit
/