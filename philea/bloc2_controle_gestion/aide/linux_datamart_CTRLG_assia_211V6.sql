
drop table datamart_bl_ret_nf_bl
/
create table datamart_bl_ret_nf_bl as select x.sdhnum_0 bl,y.sddlin_0 lig,decode(substr(x.bpcord_0,1,1),'X','C','Y','C','Z','C',substr(x.bpcord_0,1,1)) agence,x.dlvdat_0 date_bl,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,(select xfc_0 from itmmaster t where t.itmref_0=y.itmref_0) FCMKT,(select xfclib_0 from itmmaster t where t.itmref_0=y.itmref_0) FCLIBMKT,(select xfT_0 from itmmaster t where t.itmref_0=y.itmref_0) FTMKT,(select xfTlib_0 from itmmaster t where t.itmref_0=y.itmref_0) FTLIBMKT,(select xfD_0 from itmmaster t where t.itmref_0=y.itmref_0) FDMKT,(select xfDlib_0 from itmmaster t where t.itmref_0=y.itmref_0) FDLIBMKT ,y.gropri_0 tarif,y.qty_0 qte,(y.qty_0*y.netpri_0) HTN,(y.qty_0*y.gropri_0) HTB,y.netpriati_0 ttc,substr(x.bpcord_0,2,1) categ,(select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0) proj,decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0),null,'DISTRIBUTION',decode(substr((select max(ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   )   ) canal,decode((select max(t.itmref_0) from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,  decode((select max(a.itmref_0) from bom a where a.itmref_0=y.itmref_0),null,'NON','OUI') ARTF,  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) frs,   (select max(t.bpsnam_0)  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) ) lib_frs2,(select max(f.xclasse_0) from bpcustomer f where f.bpcnum_0=x.bpcord_0) xclasse      from sdelivery x,sdeliveryd y where x.sdhnum_0=y.sdhnum_0 and x.sdhnum_0 like 'B%' and x.dlvdat_0 between '01/01/2020' and '31/12/2026' and x.invflg_0=1 and x.bpcord_0 not like 'PZ%'
/
insert into datamart_bl_ret_nf_bl select x.sdhnum_0 bl,y.sddlin_0 lig,decode(substr(x.bpcord_0,1,1),'X','C','Y','C','Z','C',substr(x.bpcord_0,1,1)) agence,x.dlvdat_0 date_bl,x.bpcord_0 tiers,y.itmref_0 Article,y.itmdes1_0 Lib_art_bl,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,(select xfc_0 from itmmaster t where t.itmref_0=y.itmref_0) FCMKT,(select xfclib_0 from itmmaster t where t.itmref_0=y.itmref_0) FCLIBMKT,(select xfT_0 from itmmaster t where t.itmref_0=y.itmref_0) FTMKT,(select xfTlib_0 from itmmaster t where t.itmref_0=y.itmref_0) FTLIBMKT,(select xfD_0 from itmmaster t where t.itmref_0=y.itmref_0) FDMKT,(select xfDlib_0 from itmmaster t where t.itmref_0=y.itmref_0) FDLIBMKT ,y.gropri_0*11 tarif,y.qty_0 qte,(y.qty_0*y.netpri_0*11) HTN,(y.qty_0*y.gropri_0*11) HTB,y.netpriati_0 ttc,substr(x.bpcord_0,2,1) categ,(select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0) proj,decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0),null,'DISTRIBUTION',decode(substr((select max(ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=x.sdhnum_0 and ii.bpcord_0=x.bpcord_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   )   ) canal,decode((select t.itmref_0 from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,  decode((select a.itmref_0 from bom a where a.itmref_0=y.itmref_0),null,'NON','OUI') ARTF,  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) frs,   (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) ) lib_frs2,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=x.bpcord_0) xclasse      from sdelivery x,sdeliveryd y where x.sdhnum_0=y.sdhnum_0 and x.sdhnum_0 like 'B%' and x.dlvdat_0 between '01/01/2020' and '31/12/2026' and x.invflg_0=1 and x.bpcord_0  like 'PZ%'
/
drop table datamart_bl_ret_nf_ret
/

create table datamart_bl_ret_nf_ret as   select xx.srhnum_0 numret,yy.srdlin_0 lig,decode(substr(xx.bpcord_0,1,1),'X','C','Y','C','Z','C',substr(xx.bpcord_0,1,1)) ag,xx.rtndat_0 date_bl,xx.bpcord_0 tiers,yy.itmref_0 article ,yy.itmdes1_0 lib,  (select tt.tsicod_0 from itmmaster tt where tt.itmref_0=yy.itmref_0)  FC,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FT,   (select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FD,(select xfc_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCMKT,  (select xfclib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCLIBMKT,  (select xfT_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTMKT,  (select xfTlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTLIBMKT,  (select xfD_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDMKT,  (select xfDlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDLIBMKT,  yy.netpri_0 tarif,yy.qty_0*-1 qte,(yy.qty_0*yy.netpri_0)*-1 HTN,(yy.qty_0*yy.netpri_0)*-1 HTB, yy.netpriati_0 ttc, substr(xx.bpcord_0,2,1) categ,(select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0) proj,  decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),null,'DISTRIBUTION',decode(substr((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   )   ) canal,    decode((select max(t.itmref_0) from itmbps t where t.itmref_0=yy.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,    decode((select max(a.itmref_0) from bom a where a.itmref_0=yy.itmref_0),null,'NON','OUI') ARTF,    (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) frs,    (select max(t.bpsnam_0)  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) ) lib_frs2,(select max(f.xclasse_0) from bpcustomer f where f.bpcnum_0=xx.bpcord_0) xclasse    from sreturn xx, sreturnd yy where xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2020' and '31/12/2026' and (xx.srhnum_0 like 'RV%' or xx.srhnum_0 like 'RP%')   and (yy.srhnum_0,yy.srdlin_0) not in (select pp.srhnum_0,srdlin_0 from sinvoiced pp where pp.invdat_0 between '01/01/2020' and '31/12/2026' and pp.srhnum_0<>' ' and pp.bpcinv_0=xx.bpcord_0) and xx.bpcord_0 not like 'PZ%'
/
insert into datamart_bl_ret_nf_ret    select xx.srhnum_0 numret,yy.srdlin_0 lig,decode(substr(xx.bpcord_0,1,1),'X','C','Y','C','Z','C',substr(xx.bpcord_0,1,1)) ag,xx.rtndat_0 date_bl,xx.bpcord_0 tiers,yy.itmref_0 article ,yy.itmdes1_0 lib,  (select tt.tsicod_0 from itmmaster tt where tt.itmref_0=yy.itmref_0)  FC,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FT,   (select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FD,(select xfc_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCMKT,  (select xfclib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCLIBMKT,  (select xfT_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTMKT,  (select xfTlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTLIBMKT,  (select xfD_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDMKT,  (select xfDlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDLIBMKT,  yy.netpri_0*11 tarif,yy.qty_0*-1 qte,(yy.qty_0*yy.netpri_0*11)*-1 HTN,(yy.qty_0*yy.netpri_0*11)*-1 HTB, yy.netpriati_0 ttc ,substr(xx.bpcord_0,2,1) categ,(select distinct ii.axeproj_0  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0) proj,  decode((select distinct ii.axeproj_0  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),null,'DISTRIBUTION',decode(substr((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   )   ) canal,    decode((select t.itmref_0 from itmbps t where t.itmref_0=yy.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,    decode((select a.itmref_0 from bom a where a.itmref_0=yy.itmref_0),null,'NON','OUI') ARTF,    (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) frs,    (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) ) lib_frs2,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=xx.bpcord_0) xclasse    from sreturn xx, sreturnd yy where xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2020' and '31/12/2026' and (xx.srhnum_0 like 'RV%' or xx.srhnum_0 like 'RP%')   and (yy.srhnum_0,yy.srdlin_0) not in (select pp.srhnum_0,srdlin_0 from sinvoiced pp where pp.invdat_0 between '01/01/2020' and '31/12/2026' and pp.srhnum_0<>' ' and pp.bpcinv_0=xx.bpcord_0) and xx.bpcord_0 like 'PZ%'
/
insert into datamart_bl_ret_nf_ret    select xx.srhnum_0 numret,yy.srdlin_0 lig,decode(substr(xx.bpcord_0,1,1),'X','C','Y','C','Z','C',substr(xx.bpcord_0,1,1)) ag,xx.rtndat_0 date_bl,xx.bpcord_0 tiers,yy.itmref_0 article ,yy.itmdes1_0 lib,  (select tt.tsicod_0 from itmmaster tt where tt.itmref_0=yy.itmref_0)  FC,(select tt.tsicod_1 from itmmaster tt where tt.itmref_0=yy.itmref_0) FT,   (select tt.tsicod_2 from itmmaster tt where tt.itmref_0=yy.itmref_0) FD,(select xfc_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCMKT,  (select xfclib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FCLIBMKT,  (select xfT_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTMKT,  (select xfTlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FTLIBMKT,  (select xfD_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDMKT,  (select xfDlib_0 from itmmaster t where t.itmref_0=yy.itmref_0) FDLIBMKT,  yy.netpri_0*11 tarif,yy.qty_0*-1 qte,(yy.qty_0*yy.netpri_0*11)*-1 HTN,(yy.qty_0*yy.netpri_0*11)*-1 HTB,yy.netpriati_0 ttc  ,substr(xx.bpcord_0,2,1) categ,(select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0) proj,  decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),null,'DISTRIBUTION',decode(substr((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=yy.sdhnum_0 and ii.bpcord_0=xx.bpcord_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   )   ) canal,    decode((select t.itmref_0 from itmbps t where t.itmref_0=yy.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,    decode((select a.itmref_0 from bom a where a.itmref_0=yy.itmref_0),null,'NON','OUI') ARTF,    (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) frs,    (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=yy.itmref_0) ) lib_frs2,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=xx.bpcord_0) xclasse    from sreturn xx, sreturnd yy where xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 between '01/01/2020' and '31/12/2026' and (xx.srhnum_0 like 'RV%' or xx.srhnum_0 like 'RP%')   and (yy.srhnum_0,yy.srdlin_0) not in (select pp.srhnum_0,srdlin_0 from sinvoiced pp where pp.invdat_0 between '01/01/2020' and '31/12/2026' and pp.srhnum_0<>' ' and pp.bpcinv_0=xx.bpcord_0) and xx.bpcord_0 like 'PZ%'
/
drop table datamart_BL_RET_NF
/
create table datamart_BL_RET_NF as select * from datamart_BL_RET_NF_bl union select * from datamart_BL_RET_NF_ret
/

update datamart_BL_RET_NF set canal='APPEL OFFRE' where categ='U'
/
update datamart_bl_ret_nf set canal = 'GRAND COMPTE' where tiers in (select bpcnum_0 from bpcustomer where xclasse_0='1')
/
update datamart_bl_ret_nf set canal = 'PARTICULIER' where tiers in (select bpcnum_0 from bpcustomer where xclasse_0='2')
/
update datamart_bl_ret_nf set canal = 'SOLAIRE' where proj = 'RRRR' 
/
commit
/
drop table datamart_bl_ret_fac
/

create table datamart_bl_ret_fac as select decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0) piece,decode(substr(x.gte_0,1,1),'F',(select dlvdat_0 from sdelivery where sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0)) , 'A',(select rtndat_0 from sreturn where srhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0))) date_piece,x.num_0 fac,decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence, x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,'            ' FCMKT,'                                                        ' FCLIBMKT,'       ' FTMKT,'                                           ' FTLIBMKT,'                ' FDMKT,'                                                  ' FDLIBMKT,y.gropri_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*x.ratmlt_0),'A',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1) HTN ,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*x.ratmlt_0),'A',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1) HTB ,substr(x.bpr_0,2,1) categ,'     ' proj,decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=y.sdhnum_0 and ii.bpcord_0=x.bpr_0),null,'DISTRIBUTION',decode(substr((select max( ii.axeproj_0 ) from xprojet ii where ii.sdhnum_0=y.sdhnum_0 and ii.bpcord_0=x.bpr_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   ) )  canal,decode((select t.itmref_0 from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') simay,'        ' ARTF, '        ' frs,'                                                ' lib_frs2 ,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=x.bpr_0) xclasse  from sinvoice x,sinvoiced y where x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' and x.gte_0 <> 'AFV' 
/

-------------------------------------
update datamart_bl_ret_fac y set 
fcmkt = (select xfc_0 from itmmaster t where t.itmref_0=y.article),
FCLIBMKT=(select xfclib_0 from itmmaster t where t.itmref_0=y.article) ,
FTMKT=(select xfT_0 from itmmaster t where t.itmref_0=y.article) ,
FTLIBMKT=(select xfTlib_0 from itmmaster t where t.itmref_0=y.article) ,
FDMKT=(select xfD_0 from itmmaster t where t.itmref_0=y.article) ,
FDLIBMKT=(select xfDlib_0 from itmmaster t where t.itmref_0=y.article) ,
proj = (select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=y.piece and ii.bpcord_0=y.tiers) ,
simay = decode((select t.itmref_0 from itmbps t where t.itmref_0=y.article and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') ,
ARTF = decode((select a.itmref_0 from bom a where a.itmref_0=y.article),null,'NON','OUI'),
frs = (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article),
lib_frs2 = (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article) )
/

------------------------------------
update datamart_BL_RET_FAC set canal='APPEL OFFRE' where categ='U'
/
update datamart_BL_RET_FAC set piece ='FORFAIT' where piece is null or piece=' '
/
update datamart_BL_RET_FAC set date_piece=date_fac where piece='FORFAIT'
/
update datamart_BL_RET_FAC z set z.proj=(select max(u.proj) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.proj is not null),canal=(select max(u.canal) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.canal is not null) where z.piece='FORFAIT' 
/
commit
/
update datamart_bl_ret_fac set 
canal = 'GRAND COMPTE' where tiers in (select bpcnum_0 from bpcustomer where xclasse_0='1')
/
update datamart_bl_ret_fac set 
canal = 'PARTICULIER' where tiers in (select bpcnum_0 from bpcustomer where xclasse_0='2')
/
update datamart_bl_ret_fac set 
canal = 'SOLAIRE' where proj = 'RRRR' 
/
commit
/
drop table datamart_remise_except
/
create table datamart_remise_except as select periode,tiers,fac,agence,categ,sum(remise_except) remise_except from ( select a.invdat_0 periode,a.bpcinv_0 tiers,a.num_0 fac,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0)*-1 remise_except from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2020' and  '31/12/2026' and  a.invdtaamt_1 <> 0  and substr(a.sivtyp_0,1,1)='F' group by a.invdat_0 ,a.bpcinv_0 ,a.num_0,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1) union select a.invdat_0 periode,a.bpcinv_0 tiers,a.num_0 fac,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) agence,substr(a.bpcinv_0,2,1) categ, sum(b.dtanot_0) remise_except from sinvoicev a, svcrfoot b where  a.num_0=b.vcrnum_0 and a.invdat_0 between '01/01/2018' and  '31/12/2026' and  a.invdtaamt_1 <> 0 and a.sivtyp_0 in ('AVO','AVP') group by a.invdat_0 ,a.bpcinv_0 ,a.num_0,decode(substr(a.bpcinv_0,1,1),'X','C','Y','C','Z','C',substr(a.bpcinv_0,1,1)) ,substr(a.bpcinv_0,2,1) ) group by periode,tiers,fac,agence,categ
/
drop table datamart_av_financier
/
create table datamart_av_financier as select kk.bpr_0 tiers,kk.accdat_0 periode, substr(kk.bpr_0,2,1) categ,decode(substr(kk.bpr_0,1,1),'X','C','Y','C','Z','C',substr(kk.bpr_0,1,1)) agence,kk.num_0,kk.amtnot_0 HT,kk.amtati_0 TTC,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=kk.bpr_0) xclasse   from sinvoice kk where kk.accdat_0 between '01/01/2020' and '31/12/2026' and kk.num_0 like 'AF%'
/
drop table datamart_R4_cpt_Charges
/
drop table datamart_facture_NCOMPT
/
create table datamart_facture_NCOMPT as select a.num_0,a.bpr_0,a.accdat_0,decode(substr(a.num_0,1,1),'A',a.amtnot_0*-1,a.amtnot_0) ht,decode(substr(a.num_0,1,1),'A',a.amtati_0*-1,a.amtati_0) ttc,decode(substr(a.num_0,1,1),'A',(a.amtati_0-a.amtnot_0)*-1,(a.amtati_0-a.amtnot_0)) tva from sinvoice a where a.accdat_0 > '01/01/2010' and a.amtnot_0 > 0 and a.sta_0<>3
/
create  table datamart_R4_cpt_Charges (racine_cpt1 varchar2(4),racine_cpt2 varchar2(5), lib_R_cpt1 varchar2(100),lib_r_cpt2 varchar2(100),lib_r_cpt3 varchar2(100))
/
insert into datamart_R4_cpt_Charges values ('6189','6189','Immo Prod pour elle-m�me','Construction elle-m�me ','Immo Prod pour elle-m�me');
insert into datamart_R4_cpt_Charges values ('7141','7141','Immo Prod pour elle-m�me','Construction elle-m�me ','Immo Prod pour elle-m�me');
insert into datamart_R4_cpt_Charges values ('7142','7142','Immo Prod pour elle-m�me','Construction elle-m�me ','Immo Prod pour elle-m�me');
insert into datamart_R4_cpt_Charges values ('7143','7143','Immo Prod pour elle-m�me','Construction elle-m�me ','Immo Prod pour elle-m�me');
insert into datamart_R4_cpt_Charges values ('7148','7148','Immo Prod pour elle-m�me','Construction elle-m�me ','Immo Prod pour elle-m�me');
insert into datamart_R4_cpt_Charges values ('7131','7131','Var Stock ','Var Stock ','Variation Stock Produits en cours ');
insert into datamart_R4_cpt_Charges values ('7132','7132','Var Stock ','Var Stock ','Var Stock Produits Finis');
insert into datamart_R4_cpt_Charges values ('7134','7134','Var Stock ','Var Stock ','Var Stock sevices en cours ');
insert into datamart_R4_cpt_Charges values ('6111','6111','Achats Revendus et Consomm�s','Achats MP et Produits','Achats  imports');
insert into datamart_R4_cpt_Charges values ('6112','6112','Achats Revendus et Consomm�s','Achats MP et Produits','Achats Locaux ');
insert into datamart_R4_cpt_Charges values ('6113','6113','Achats Revendus et Consomm�s','Achats MP et Produits','Achats Locaux ');
insert into datamart_R4_cpt_Charges values ('6114','6114','Achats Revendus et Consomm�s','Achats MP et Produits','Var Stock Marchandise');
insert into datamart_R4_cpt_Charges values ('6118','6118','Achats Revendus et Consomm�s','Achats MP et Produits','Achats  Revendus ');
insert into datamart_R4_cpt_Charges values ('6119','6119','Achats Revendus et Consomm�s','Achats MP et Produits','Rabais / Remise / Ristourne et Autres');
insert into datamart_R4_cpt_Charges values ('6120','6120','Achats Revendus et Consomm�s','Achats MP et Produits','Achats  de mati�res et fournitures');
insert into datamart_R4_cpt_Charges values ('6121','6121','Achats Revendus et Consomm�s','Achats MP et Produits','Achats  de mati�res et fournitures');
insert into datamart_R4_cpt_Charges values ('6122','6122','Achats Revendus et Consomm�s','Achats MP et Produits','P.entretien et F bureau et Cons Informatiques');
insert into datamart_R4_cpt_Charges values ('6123','6123','Achats Revendus et Consomm�s','Achats MP et Produits','Achats Emballages');
insert into datamart_R4_cpt_Charges values ('6124','6124','Achats Revendus et Consomm�s','Achats MP et Produits','Var Stock Mati�re et Fourniture');
insert into datamart_R4_cpt_Charges values ('6125','6125','Achats Revendus et Consomm�s','Achats MP et Produits','Eau et Elect et F Entretien et Carburant');
insert into datamart_R4_cpt_Charges values ('6126','6126','Achats Revendus et Consomm�s','Achats MP et Produits','Prestations Services ');
insert into datamart_R4_cpt_Charges values ('6128','6128','Achats Revendus et Consomm�s','Achats MP et Produits','Achats Fournitures N-1');
insert into datamart_R4_cpt_Charges values ('6129','6129','Achats Revendus et Consomm�s','Achats MP et Produits','Rabais / Remise / Ristourne et Autres');
insert into datamart_R4_cpt_Charges values ('7129','7129','Achats Revendus et Consomm�s','Achats MP et Produits','Rabais / Remise / Ristourne');
insert into datamart_R4_cpt_Charges values ('6131','61312','Frais de Gestion','Loyer','Loyer ');
insert into datamart_R4_cpt_Charges values ('6132','6132','Frais de Gestion','Cr�dit Bail','Redevance cr�dit Bail');
insert into datamart_R4_cpt_Charges values ('6133','6133','Frais de Gestion','Autres ','Entretien et r�paration');
insert into datamart_R4_cpt_Charges values ('6134','6134','Frais de Gestion','Autres ','Assurances');
insert into datamart_R4_cpt_Charges values ('6135','6135','Frais de Gestion','Int�rimaires','Personnel Int�rimaires');
insert into datamart_R4_cpt_Charges values ('6136','61361','Frais de Gestion','Honoraires et Contentieux','Honoraires et Contentieux');
insert into datamart_R4_cpt_Charges values ('6136','61365','Frais de Gestion','Honoraires et Contentieux','Honoraires et Contentieux');
insert into datamart_R4_cpt_Charges values ('6136','61367','Frais de Gestion','Honoraires et Contentieux','Honoraires et Contentieux');
insert into datamart_R4_cpt_Charges values ('6141','6141','Frais de Gestion','Autres ','Etudes ');
insert into datamart_R4_cpt_Charges values ('6143','6143','Frais de Gestion','D�placements ','D�placements Missions R�ceptions');
insert into datamart_R4_cpt_Charges values ('6145','6145','Frais de Gestion','T�l�phonie ','T�l�phonie / Internet ');
insert into datamart_R4_cpt_Charges values ('6161','6161','Frais de Gestion','Autres ','Imp�ts et Taxes');
insert into datamart_R4_cpt_Charges values ('6165','6165','Frais de Gestion','Autres ','autres imp�ts');
insert into datamart_R4_cpt_Charges values ('6167','6167','Frais de Gestion','Autres ','autres imp�ts');
insert into datamart_R4_cpt_Charges values ('6168','6168','Frais de Gestion','Autres ','Imp�ts et Taxes N-1');
insert into datamart_R4_cpt_Charges values ('6171','6171','Frais de Gestion','Charges du Personnel ','R�mun�ration du Personnel');
insert into datamart_R4_cpt_Charges values ('6174','6174','Frais de Gestion','Charges du Personnel ','Charges patronales');
insert into datamart_R4_cpt_Charges values ('6176','6176','Frais de Gestion','Charges du Personnel ','Formation et Medecines et Autres');
insert into datamart_R4_cpt_Charges values ('6177','6177','Frais de Gestion','Autres ','Autres R�mun�rations');
insert into datamart_R4_cpt_Charges values ('6178','6178','Frais de Gestion','Charges du Personnel ','Charges Personnel N-1');
insert into datamart_R4_cpt_Charges values ('6142','61421','Frais de Gestion','Charges du Personnel ','Transport Personnel');
insert into datamart_R4_cpt_Charges values ('6146','61461','Frais de Gestion','Autres ','Cotisations ');
insert into datamart_R4_cpt_Charges values ('6146','61463','Frais de Gestion','Charges du Personnel ','Aid Adha et Achoura');
insert into datamart_R4_cpt_Charges values ('6146','61465','Frais de Gestion','Charges du Personnel ','Aides Personnel ');
insert into datamart_R4_cpt_Charges values ('6146','61462','Frais de Structure','Autres ','Dons Externes ');
insert into datamart_R4_cpt_Charges values ('6136','61361','Frais de Structure','Commissions March�','Commissions March�');
insert into datamart_R4_cpt_Charges values ('6144','6144','Frais de Structure','Pub / Foires / Gadgets','Pub / Foires / Gadgets Client�les');
insert into datamart_R4_cpt_Charges values ('6147','6147','Frais de Structure','Commissions Bancaires','Commissions Bancaires');
insert into datamart_R4_cpt_Charges values ('6131','61316','Frais de Structure','Autres ','Location Transport ');
insert into datamart_R4_cpt_Charges values ('6131','61313','Frais de Structure','Autres ','Location Mat�riel et outillage ');
insert into datamart_R4_cpt_Charges values ('6148','6148','Frais de Structure','Autres ','Charges N-1');
insert into datamart_R4_cpt_Charges values ('6149','6149','Frais de Structure','Autres ','Rabais / Remise / Ristourne / autres charges externes');
insert into datamart_R4_cpt_Charges values ('6181','6181','Frais de Structure','Autres ','Jetons de pr�sence');
insert into datamart_R4_cpt_Charges values ('6182','6182','Frais de Structure','Perte / Cr�ances','Perte / Cr�ances ');
insert into datamart_R4_cpt_Charges values ('6185','6185','Frais de Structure','Autres ','Pertes sur op�ration');
insert into datamart_R4_cpt_Charges values ('6186','6186','Frais de Structure','Autres ','Transfert de Profit');
insert into datamart_R4_cpt_Charges values ('6188','6188','Frais de Structure','Autres ','Autres Charges Expl N-1');
insert into datamart_R4_cpt_Charges values ('7161','7161','Frais de Structure','Autres ','Subvention Expl');
insert into datamart_R4_cpt_Charges values ('7168','7168','Frais de Structure','Autres ','Subvention Expl N-1');
insert into datamart_R4_cpt_Charges values ('7181','7181','Frais de Structure','Autres ','Jetons de pr�sence');
insert into datamart_R4_cpt_Charges values ('7182','7182','Frais de Structure','Autres ','Revenus des immeubles ');
insert into datamart_R4_cpt_Charges values ('7185','7185','Frais de Structure','Autres ','Produits sur op�ration');
insert into datamart_R4_cpt_Charges values ('7186','7186','Frais de Structure','Autres ','Transfert de Perte ');
insert into datamart_R4_cpt_Charges values ('7188','7188','Frais de Structure','Autres ','Autres produits d expl');
insert into datamart_R4_cpt_Charges values ('7189','7189','Frais de Structure','Autres ','Produits Divers Exploitations');
insert into datamart_R4_cpt_Charges values ('7197','7197','Frais de Structure','Autres ','Transferts de Charges exploitations');
insert into datamart_R4_cpt_Charges values ('6137','6137','Frais de Structure','Autres ','Redevances Brevets');
insert into datamart_R4_cpt_Charges values ('6142','61425','Frais de Structure','Transport Marchandise','Transport Achats');
insert into datamart_R4_cpt_Charges values ('6142','61426','Frais de Structure','Transport Marchandise','Transports Ventes ');
insert into datamart_R4_cpt_Charges values ('6142','61427','Frais de Structure','Transport Marchandise','Transport Export ');
insert into datamart_R4_cpt_Charges values ('6142','61428','Frais de Structure','Transport Marchandise','Autres Transports');
insert into datamart_R4_cpt_Charges values ('6191','6191','Autres Exploitation','Dotations / Reprises Expl','Dotations Non Valeurs ');
insert into datamart_R4_cpt_Charges values ('6192','6192','Autres Exploitation','Dotations / Reprises Expl','Dotation Amort Immobisation Incorp');
insert into datamart_R4_cpt_Charges values ('6193','6193','Autres Exploitation','Dotations / Reprises Expl','Dotation Amort Immobisation Corp');
insert into datamart_R4_cpt_Charges values ('6194','6194','Autres Exploitation','Dotations / Reprises Expl','Dotations D�preciations  Immo');
insert into datamart_R4_cpt_Charges values ('6195','6195','Autres Exploitation','Dotations / Reprises Expl','Dotation Cong�s pay�s ');
insert into datamart_R4_cpt_Charges values ('6196','6196','Autres Exploitation','Dotations / Reprises Expl','Dotation Cr�ances / Stock');
insert into datamart_R4_cpt_Charges values ('6198','6198','Autres Exploitation','Dotations / Reprises Expl','Dotation N-1');
insert into datamart_R4_cpt_Charges values ('7191','7191','Autres Exploitation','Dotations / Reprises Expl','Reprise d exploitation / Immo NV');
insert into datamart_R4_cpt_Charges values ('7192','7192','Autres Exploitation','Dotations / Reprises Expl','Reprise d exploitation / Immo Inc');
insert into datamart_R4_cpt_Charges values ('7193','7193','Autres Exploitation','Dotations / Reprises Expl','Reprise d exploitation / Immo Corp');
insert into datamart_R4_cpt_Charges values ('7194','7194','Autres Exploitation','Dotations / Reprises Expl','Reprise d exploitation / Immo');
insert into datamart_R4_cpt_Charges values ('7195','7195','Autres Exploitation','Dotations / Reprises Expl','Reprise Cong�s Pay�s');
insert into datamart_R4_cpt_Charges values ('7196','7196','Autres Exploitation','Dotations / Reprises Expl','Reprise / Provision');
insert into datamart_R4_cpt_Charges values ('7198','7198','Autres Exploitation','Dotations / Reprises Expl','Reprise Amort N-1');
insert into datamart_R4_cpt_Charges values ('6311','6311','R�sultat Financier','Charges / Produits Fin','Charges d inter�ts');
insert into datamart_R4_cpt_Charges values ('6318','6318','R�sultat Financier','Charges / Produits Fin','Charges d inter�ts N-1');
insert into datamart_R4_cpt_Charges values ('6331','6331','R�sultat Financier','Charges / Produits Fin','Pertes de change');
insert into datamart_R4_cpt_Charges values ('6338','6338','R�sultat Financier','Charges / Produits Fin','Pertes de change N-1');
insert into datamart_R4_cpt_Charges values ('6382','6382','R�sultat Financier','Charges / Produits Fin','Pertes cr�ances participation');
insert into datamart_R4_cpt_Charges values ('6385','6385','R�sultat Financier','Charges / Produits Fin','Charges / Cessions');
insert into datamart_R4_cpt_Charges values ('6386','6386','R�sultat Financier','Charges / Produits Fin','Escomptes accord�s');
insert into datamart_R4_cpt_Charges values ('6388','6388','R�sultat Financier','Charges / Produits Fin','Autres Charges Financi�res N-1');
insert into datamart_R4_cpt_Charges values ('6391','6391','R�sultat Financier','Charges / Produits Fin','Autres dotations Financi�res');
insert into datamart_R4_cpt_Charges values ('6392','6392','R�sultat Financier','Charges / Produits Fin','Dotations Depr�ciation des Immo F');
insert into datamart_R4_cpt_Charges values ('6393','6393','R�sultat Financier','Charges / Produits Fin','Dotations Pour Risques ');
insert into datamart_R4_cpt_Charges values ('6394','6394','R�sultat Financier','Charges / Produits Fin','Dotation D�pr�ciation des titres');
insert into datamart_R4_cpt_Charges values ('6396','6396','R�sultat Financier','Charges / Produits Fin','Dotation D�pr�ciation des comptes');
insert into datamart_R4_cpt_Charges values ('6398','6398','R�sultat Financier','Charges / Produits Fin','Dotation financi�re N-1');
insert into datamart_R4_cpt_Charges values ('7321','7321','R�sultat Financier','Charges / Produits Fin','Revenus des Titres ');
insert into datamart_R4_cpt_Charges values ('7325','7325','R�sultat Financier','Charges / Produits Fin','Revenus des Titres ');
insert into datamart_R4_cpt_Charges values ('7328','7328','R�sultat Financier','Charges / Produits Fin','Produits des titres ');
insert into datamart_R4_cpt_Charges values ('7331','7331','R�sultat Financier','Charges / Produits Fin','Gains de change');
insert into datamart_R4_cpt_Charges values ('7338','7338','R�sultat Financier','Charges / Produits Fin','Gains de change N-1');
insert into datamart_R4_cpt_Charges values ('7381','7381','R�sultat Financier','Charges / Produits Fin','Int�r�ts et Produits');
insert into datamart_R4_cpt_Charges values ('7383','7383','R�sultat Financier','Charges / Produits Fin','Revenus des cr�ances');
insert into datamart_R4_cpt_Charges values ('7384','7384','R�sultat Financier','Charges / Produits Fin','Inter�ts et autres produits financiers');
insert into datamart_R4_cpt_Charges values ('7386','7386','R�sultat Financier','Charges / Produits Fin','Escomptes Obtenus');
insert into datamart_R4_cpt_Charges values ('7388','7388','R�sultat Financier','Charges / Produits Fin','Int�r�ts et Produits N-1');
insert into datamart_R4_cpt_Charges values ('7391','7391','R�sultat Financier','Charges / Produits Fin','Reprises Primes ');
insert into datamart_R4_cpt_Charges values ('7393','7393','R�sultat Financier','Charges / Produits Fin','REPRISE SUR PROV P.RISQUE');
insert into datamart_R4_cpt_Charges values ('7394','7394','R�sultat Financier','Charges / Produits Fin','REPRISE SUR PROV P.DEPR TITRES');
insert into datamart_R4_cpt_Charges values ('7396','7396','R�sultat Financier','Charges / Produits Fin','Reprise Comptes de Tr�sorerie');
insert into datamart_R4_cpt_Charges values ('7397','7397','R�sultat Financier','Charges / Produits Fin','Trabsferts Charges Financi�res');
insert into datamart_R4_cpt_Charges values ('7398','7398','R�sultat Financier','Charges / Produits Fin','Rerpises N-1');
insert into datamart_R4_cpt_Charges values ('6512','6512','R�sultat non courant','Charges / Produits NC','VNA Immobilisations C�d�es');
insert into datamart_R4_cpt_Charges values ('6513','6513','R�sultat non courant','Charges / Produits NC','VNA Immobilisations C�d�es');
insert into datamart_R4_cpt_Charges values ('6514','6514','R�sultat non courant','Charges / Produits NC','VNA Immobilisations C�d�es');
insert into datamart_R4_cpt_Charges values ('6518','6518','R�sultat non courant','Charges / Produits NC','VNA Immobilisations C�d�es N-1');
insert into datamart_R4_cpt_Charges values ('6561','6561','R�sultat non courant','Charges / Produits NC','Subventions accord�es');
insert into datamart_R4_cpt_Charges values ('6568','6568','R�sultat non courant','Charges / Produits NC','Subventions accord�es N-1');
insert into datamart_R4_cpt_Charges values ('6581','6581','R�sultat non courant','Charges / Produits NC','P�nalit� / March�s');
insert into datamart_R4_cpt_Charges values ('6582','6582','R�sultat non courant','Charges / Produits NC','Rappels d imp�ts');
insert into datamart_R4_cpt_Charges values ('6583','6583','R�sultat non courant','Charges / Produits NC','Amendes et P�nalit�s');
insert into datamart_R4_cpt_Charges values ('6585','6585','R�sultat non courant','Charges / Produits NC','Cr�ances Irr�couvrables');
insert into datamart_R4_cpt_Charges values ('6586','6586','R�sultat non courant','Charges / Produits NC','Dons');
insert into datamart_R4_cpt_Charges values ('6588','6588','R�sultat non courant','Charges / Produits NC','Autres charges non courantes N-1');
insert into datamart_R4_cpt_Charges values ('6591','6591','R�sultat non courant','Charges / Produits NC','Dotations non courantes');
insert into datamart_R4_cpt_Charges values ('6594','6594','R�sultat non courant','Charges / Produits NC','Dotations non courantes');
insert into datamart_R4_cpt_Charges values ('6595','6595','R�sultat non courant','Charges / Produits NC','Dotations non courantes');
insert into datamart_R4_cpt_Charges values ('6596','6596','R�sultat non courant','Charges / Produits NC','Dotations non courantes');
insert into datamart_R4_cpt_Charges values ('6598','6598','R�sultat non courant','Charges / Produits NC','Dotations non courantes N-1');
insert into datamart_R4_cpt_Charges values ('7501','7501','R�sultat non courant','Charges / Produits NC','Produit Cession Mat�riel Trp');
insert into datamart_R4_cpt_Charges values ('7512','7512','R�sultat non courant','Charges / Produits NC','Produit cession Imm incorp');
insert into datamart_R4_cpt_Charges values ('7513','7513','R�sultat non courant','Charges / Produits NC','Produit cession Imm Corp');
insert into datamart_R4_cpt_Charges values ('7514','7514','R�sultat non courant','Charges / Produits NC','Produit cession Imm Fin');
insert into datamart_R4_cpt_Charges values ('7518','7518','R�sultat non courant','Charges / Produits NC','Produit cession Imm N-1');
insert into datamart_R4_cpt_Charges values ('7561','7561','R�sultat non courant','Charges / Produits NC','Subventions d �quilbre');
insert into datamart_R4_cpt_Charges values ('7568','7568','R�sultat non courant','Charges / Produits NC','Subventions d �quilbre N-1');
insert into datamart_R4_cpt_Charges values ('7577','7577','R�sultat non courant','Charges / Produits NC','Reprise Sub Inv');
insert into datamart_R4_cpt_Charges values ('7578','7578','R�sultat non courant','Charges / Produits NC','Reprise Sub Inv N-1');
insert into datamart_R4_cpt_Charges values ('7581','7581','R�sultat non courant','Charges / Produits NC','P�nalit�s');
insert into datamart_R4_cpt_Charges values ('7582','7582','R�sultat non courant','Charges / Produits NC','D�gr�vements d imp�ts');
insert into datamart_R4_cpt_Charges values ('7585','7585','R�sultat non courant','Charges / Produits NC','Rentr�es sur Cr�ances Sold�es');
insert into datamart_R4_cpt_Charges values ('7586','7586','R�sultat non courant','Charges / Produits NC','Dons ');
insert into datamart_R4_cpt_Charges values ('7588','7588','R�sultat non courant','Charges / Produits NC','autres produits Non courant N-1');
insert into datamart_R4_cpt_Charges values ('7591','7591','R�sultat non courant','Charges / Produits NC','Reprise Exceptionnelle  Immo');
insert into datamart_R4_cpt_Charges values ('7594','7594','R�sultat non courant','Charges / Produits NC','Reprise non courante Prov Regl');
insert into datamart_R4_cpt_Charges values ('7595','7595','R�sultat non courant','Charges / Produits NC','Reprise non courante Risques et Charges');
insert into datamart_R4_cpt_Charges values ('7596','7596','R�sultat non courant','Charges / Produits NC','Reprise non courante Depr�ciation');
insert into datamart_R4_cpt_Charges values ('7597','7597','R�sultat non courant','Charges / Produits NC','Transferts de Charges non courantes ');
insert into datamart_R4_cpt_Charges values ('7598','7598','R�sultat non courant','Charges / Produits NC','Reprises Non courante N-1');
insert into datamart_R4_cpt_Charges values ('6701','6701','Imp�t','Imp�t sur le R�sultat','Impot / R�sultat');
insert into datamart_R4_cpt_Charges values ('6705','6705','Imp�t','Imp�t sur le R�sultat','Impot / R�sultat');
insert into datamart_R4_cpt_Charges values ('6708','6708','Imp�t','Imp�t sur le R�sultat','Impot / R�sultat');
insert into datamart_R4_cpt_Charges values ('7111','7111','CA','Chiffre d affaires','Ventes de Marchandise');
insert into datamart_R4_cpt_Charges values ('7110','7110','CA','Chiffre d affaires','Ventes de Marchandise');
insert into datamart_R4_cpt_Charges values ('7112','7112','CA','Chiffre d affaires','Ventes de Marchandise');
insert into datamart_R4_cpt_Charges values ('7113','7113','CA','Chiffre d affaires','Export ');
insert into datamart_R4_cpt_Charges values ('7119','7119','CA','Chiffre d affaires','Rabais Remise Ristourne');
insert into datamart_R4_cpt_Charges values ('7121','7121','CA','Chiffre d affaires','Ventes de biens Produits ');
insert into datamart_R4_cpt_Charges values ('7122','7122','CA','Chiffre d affaires','Ventes de biens Produits � l Etranger');
insert into datamart_R4_cpt_Charges values ('7224','7224','CA','Chiffre d affaires','Ventes de Services  Produits ');
insert into datamart_R4_cpt_Charges values ('7125','7125','CA','Chiffre d affaires','Ventes de Services Produits � L Etranger');
insert into datamart_R4_cpt_Charges values ('7126','7126','CA','Chiffre d affaires','Redevances pour Brevets ');
insert into datamart_R4_cpt_Charges values ('7127','7127','CA','Chiffre d affaires','Ventes de Produits Accessoires ');
insert into datamart_R4_cpt_Charges values ('7128','7128','CA','Chiffre d affaires','Ventes des biens et services Produits');
insert into datamart_R4_cpt_Charges values ('7129','7129','CA','Chiffre d affaires','Rabais, Remise et ristournes ');
insert into datamart_R4_cpt_Charges values ('1111','1111','Passif ','Capitaux propres ','Capital Social ');
insert into datamart_R4_cpt_Charges values ('1119','1119','Passif ','Capitaux propres ','Capital Souscrit non appel�');
insert into datamart_R4_cpt_Charges values ('1121','1121','Passif ','Capitaux propres ','Prime d �mission');
insert into datamart_R4_cpt_Charges values ('1122','1122','Passif ','Capitaux propres ','Prime d �mission de fusion ');
insert into datamart_R4_cpt_Charges values ('1123','1123','Passif ','Capitaux propres ','Prime d apport ');
insert into datamart_R4_cpt_Charges values ('1130','1130','Passif ','Capitaux propres ','�cart de r��valuation');
insert into datamart_R4_cpt_Charges values ('1140','1140','Passif ','Capitaux propres ','r�serves l�gales');
insert into datamart_R4_cpt_Charges values ('1151','1151','Passif ','Capitaux propres ','R�serves statutaires ou contractuelles ');
insert into datamart_R4_cpt_Charges values ('1152','1152','Passif ','Capitaux propres ','R�serves facultatives ');
insert into datamart_R4_cpt_Charges values ('1155','1155','Passif ','Capitaux propres ','Autres r�serves ');
insert into datamart_R4_cpt_Charges values ('1161','1161','Passif ','Capitaux propres ','report � nouveau');
insert into datamart_R4_cpt_Charges values ('1169','1169','Passif ','Capitaux propres ','report � nouveau');
insert into datamart_R4_cpt_Charges values ('1181','1181','Passif ','Capitaux propres ','R�sultat en instance d affectation');
insert into datamart_R4_cpt_Charges values ('1189','1189','Passif ','Capitaux propres ','R�sultat en instance d affectation');
insert into datamart_R4_cpt_Charges values ('1190','1190','Passif ','Capitaux propres ','R�sultat Net');
insert into datamart_R4_cpt_Charges values ('1191','1191','Passif ','Capitaux propres ','R�sultat Net');
insert into datamart_R4_cpt_Charges values ('1199','1199','Passif ','Capitaux propres ','R�sultat Net');
insert into datamart_R4_cpt_Charges values ('1481','1481','Passif ','Dettes de Financement','Autres Dettes de Financement');
insert into datamart_R4_cpt_Charges values ('1516','1516','Passif ','Dettes de Financement','Provisions pour risques');
insert into datamart_R4_cpt_Charges values ('1518','1518','Passif ','Dettes de Financement','Provisions pour risques');
insert into datamart_R4_cpt_Charges values ('1555','1555','Passif ','Dettes de Financement','Provisions pour charges � r�partir sur plusieurs Exercices ');
insert into datamart_R4_cpt_Charges values ('160','160','Passif ','Dettes de Financement','Comptes de liaisons des �tablissements et Succ');
insert into datamart_R4_cpt_Charges values ('171','171','Passif ','Dettes de Financement','�cart de convesion Passif');
insert into datamart_R4_cpt_Charges values ('2118','2118','Actif ','Actif Immobilis�','Frais pr�liminaire');
insert into datamart_R4_cpt_Charges values ('2121','2121','Actif ','Actif Immobilis�','Frais d acquisition des immobilisations');
insert into datamart_R4_cpt_Charges values ('2125','2125','Actif ','Actif Immobilis�','Frais d �missions des emprunts ');
insert into datamart_R4_cpt_Charges values ('2128','2128','Actif ','Actif Immobilis�','Autres Charges � r�partir ');
insert into datamart_R4_cpt_Charges values ('2210','2210','Actif ','Actif Immobilis�','immobilisations Recherches Developpement');
insert into datamart_R4_cpt_Charges values ('2280','2280','Actif ','Actif Immobilis�','Autres immobilisations incorporelles');
insert into datamart_R4_cpt_Charges values ('2281','2281','Actif ','Actif Immobilis�','Autres immobilisations incorporelles');
insert into datamart_R4_cpt_Charges values ('2310','2310','Actif ','Actif Immobilis�','Terrains ');
insert into datamart_R4_cpt_Charges values ('2311','2311','Actif ','Actif Immobilis�','Terrains ');
insert into datamart_R4_cpt_Charges values ('2312','2312','Actif ','Actif Immobilis�','Terrains ');
insert into datamart_R4_cpt_Charges values ('2313','2313','Actif ','Actif Immobilis�','Terrains ');
insert into datamart_R4_cpt_Charges values ('2316','2316','Actif ','Actif Immobilis�','Agencements et am�nagements de terrains ');
insert into datamart_R4_cpt_Charges values ('2321','2321','Actif ','Actif Immobilis�','Constructions');
insert into datamart_R4_cpt_Charges values ('2327','2327','Actif ','Actif Immobilis�','Constructions');
insert into datamart_R4_cpt_Charges values ('2328','2328','Actif ','Actif Immobilis�','Autres Constructions ');
insert into datamart_R4_cpt_Charges values ('2331','2331','Actif ','Actif Immobilis�','Installations techniques et mat�riel et outillage');
insert into datamart_R4_cpt_Charges values ('2332','2332','Actif ','Actif Immobilis�','Installations techniques et mat�riel et outillage');
insert into datamart_R4_cpt_Charges values ('2338','2338','Actif ','Actif Immobilis�','Autres installations techniques ');
insert into datamart_R4_cpt_Charges values ('2340','2340','Actif ','Actif Immobilis�','Mat�riel de transport');
insert into datamart_R4_cpt_Charges values ('2341','2341','Actif ','Actif Immobilis�','Mat�riel de transport');
insert into datamart_R4_cpt_Charges values ('2351','2351','Actif ','Actif Immobilis�','Mobiliers mat�riels de bureau');
insert into datamart_R4_cpt_Charges values ('2352','2352','Actif ','Actif Immobilis�','Mobiliers mat�riels de bureau');
insert into datamart_R4_cpt_Charges values ('2355','2355','Actif ','Actif Immobilis�','Mat�riel informatique ');
insert into datamart_R4_cpt_Charges values ('2356','2356','Actif ','Actif Immobilis�','Agencements installations et am�nagements ');
insert into datamart_R4_cpt_Charges values ('2357','2357','Actif ','Actif Immobilis�','Mobiliers mat�riels de bureau');
insert into datamart_R4_cpt_Charges values ('2358','2358','Actif ','Actif Immobilis�','Mobiliers mat�riels de bureau');
insert into datamart_R4_cpt_Charges values ('2380','2380','Actif ','Actif Immobilis�','Autres immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2392','2392','Actif ','Actif Immobilis�','Immobilisations Corporelles en cours');
insert into datamart_R4_cpt_Charges values ('2393','2393','Actif ','Actif Immobilis�','Immobilisations Corporelles en cours');
insert into datamart_R4_cpt_Charges values ('2397','2397','Actif ','Actif Immobilis�','Immobilisations Corporelles en cours');
insert into datamart_R4_cpt_Charges values ('2398','2398','Actif ','Actif Immobilis�','Immobilisations Corporelles en cours');
insert into datamart_R4_cpt_Charges values ('2411','2411','Actif ','Actif Immobilis�','Pr�ts immobilis�s');
insert into datamart_R4_cpt_Charges values ('2483','2483','Actif ','Actif Immobilis�','Autres cr�ances financi�res');
insert into datamart_R4_cpt_Charges values ('2486','2486','Actif ','Actif Immobilis�','Autres cr�ances financi�res');
insert into datamart_R4_cpt_Charges values ('2510','2510','Actif ','Actif Immobilis�','titres de participations');
insert into datamart_R4_cpt_Charges values ('2710','2710','Actif ','Actif Immobilis�','Ecart de conversion Actif');
insert into datamart_R4_cpt_Charges values ('2812','2812','Actif ','Actif Immobilis�','Ammortissement des nons valeurs ');
insert into datamart_R4_cpt_Charges values ('2828','2828','Actif ','Actif Immobilis�','Ammortissement des immobilisations incorporelles');
insert into datamart_R4_cpt_Charges values ('2832','2832','Actif ','Actif Immobilis�','Ammortissement des immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2833','2833','Actif ','Actif Immobilis�','Ammortissement des immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2834','2834','Actif ','Actif Immobilis�','Ammortissement des immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2835','2835','Actif ','Actif Immobilis�','Ammortissement des immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2838','2838','Actif ','Actif Immobilis�','Ammortissement des immobilisations corporelles');
insert into datamart_R4_cpt_Charges values ('2941','2941','Actif ','Actif Immobilis�','Provisions pour d�preciation des immobilisations');
insert into datamart_R4_cpt_Charges values ('2951','2951','Actif ','Actif Immobilis�','Provisions pour d�preciation des immobilisations');
insert into datamart_R4_cpt_Charges values ('3111','3111','Actif ','Stock ','Stocks Marchandises');
insert into datamart_R4_cpt_Charges values ('3116','3116','Actif ','Stock ','Stocks Marchandises');
insert into datamart_R4_cpt_Charges values ('3121','3121','Actif ','Stock ','Mati�res et fournitures Consommables ');
insert into datamart_R4_cpt_Charges values ('3122','3122','Actif ','Stock ','Mati�res et fournitures Consommables ');
insert into datamart_R4_cpt_Charges values ('3123','3123','Actif ','Stock ','Mati�res et fournitures Consommables ');
insert into datamart_R4_cpt_Charges values ('3126','3126','Actif ','Stock ','Mati�res et fournitures Consommables ');
insert into datamart_R4_cpt_Charges values ('3131','3131','Actif ','Stock ','Produits en Cours ');
insert into datamart_R4_cpt_Charges values ('3145','3145','Actif ','Stock ','Produits Interm�diaires ');
insert into datamart_R4_cpt_Charges values ('3151','3151','Actif ','Stock ','Produits finis ');
insert into datamart_R4_cpt_Charges values ('3911','3911','Actif ','Stock ','Provisions Pour d�pr�ciation des stocks');
insert into datamart_R4_cpt_Charges values ('3411','3411','Actif ','Dettes fournisseurs Avances Acomptes','Fournisseurs D�biteurs Avances et acomptes');
insert into datamart_R4_cpt_Charges values ('3417','3417','Actif ','Dettes fournisseurs Avances Acomptes','Fournisseurs D�biteurs Avances et acomptes');
insert into datamart_R4_cpt_Charges values ('3421','3421','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('3424','3424','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s Douteux');
insert into datamart_R4_cpt_Charges values ('3425','3425','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s effet � recevoir ');
insert into datamart_R4_cpt_Charges values ('3426','3426','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('3427','3427','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s facture � �tablir');
insert into datamart_R4_cpt_Charges values ('3428','3428','Actif ','Cr�ances Clients ','Clients et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('3429','3429','Actif ','Cr�ances Clients ','D�l�gation de cr�ances ');
insert into datamart_R4_cpt_Charges values ('3942','3942','Actif ','Cr�ances Clients ','Provisions pour d�pr�ciation des cr�ances de Actif Circulant');
insert into datamart_R4_cpt_Charges values ('3431','3431','Actif ','cr�ances Hors Expl','Personnel d�biteur ');
insert into datamart_R4_cpt_Charges values ('3438','3438','Actif ','cr�ances Hors Expl','Personnel d�biteur ');
insert into datamart_R4_cpt_Charges values ('3453','3453','Actif ','cr�ances Hors Expl','Etat d�biteur');
insert into datamart_R4_cpt_Charges values ('3455','3455','Actif ','cr�ances Hors Expl','Etat d�biteur');
insert into datamart_R4_cpt_Charges values ('3456','3456','Actif ','cr�ances Hors Expl','Etat d�biteur');
insert into datamart_R4_cpt_Charges values ('3458','3458','Actif ','cr�ances Hors Expl','Etat d�biteur');
insert into datamart_R4_cpt_Charges values ('3481','3481','Actif ','cr�ances Hors Expl','Autres d�biteurs');
insert into datamart_R4_cpt_Charges values ('3488','3488','Actif ','cr�ances Hors Expl','Autres d�biteurs');
insert into datamart_R4_cpt_Charges values ('3491','3491','Actif ','cr�ances Hors Expl','Comptes de r�gularisation actif ');
insert into datamart_R4_cpt_Charges values ('3493','3493','Actif ','cr�ances Hors Expl','Comptes de r�gularisation actif ');
insert into datamart_R4_cpt_Charges values ('3497','3497','Actif ','cr�ances Hors Expl','Comptes de r�gularisation actif ');
insert into datamart_R4_cpt_Charges values ('3501','3501','Actif ','cr�ances Hors Expl','Titres et valeurs de placements');
insert into datamart_R4_cpt_Charges values ('3702','3702','Actif ','cr�ances Hors Expl','Ecart de Conversion Actif');
insert into datamart_R4_cpt_Charges values ('3950','3950','Actif ','cr�ances Hors Expl','Provision pour d�pr�ciation des titres et valeurs de placement');
insert into datamart_R4_cpt_Charges values ('4411','4411','Passif ','Dettes fournisseurs ','Fournisseurs et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('4415','4415','Passif ','Dettes fournisseurs ','Fournisseurs et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('4417','4417','Passif ','Dettes fournisseurs ','Fournisseurs et Comptes rattach�s');
insert into datamart_R4_cpt_Charges values ('4421','4421','Passif ','Cr�ances Clients Avance et Acompte ','Clients cr�diteurs avances et acomptes');
insert into datamart_R4_cpt_Charges values ('4427','4427','Passif ','Cr�ances Clients Avance et Acompte ','Clients cr�diteurs avances et acomptes');
insert into datamart_R4_cpt_Charges values ('4428','4428','Passif ','Cr�ances Clients Avance et Acompte ','Clients cr�diteurs avances et acomptes');
insert into datamart_R4_cpt_Charges values ('4432','4432','Passif ','Dettes Hors Exploitation','Personnel cr�diteur');
insert into datamart_R4_cpt_Charges values ('4437','4437','Passif ','Dettes Hors Exploitation','Personnel cr�diteur');
insert into datamart_R4_cpt_Charges values ('4441','4441','Passif ','Dettes Hors Exploitation','Organismes Sociaux');
insert into datamart_R4_cpt_Charges values ('4442','4442','Passif ','Dettes Hors Exploitation','Organismes Sociaux');
insert into datamart_R4_cpt_Charges values ('4443','4443','Passif ','Dettes Hors Exploitation','Organismes Sociaux');
insert into datamart_R4_cpt_Charges values ('4445','4445','Passif ','Dettes Hors Exploitation','Organismes Sociaux');
insert into datamart_R4_cpt_Charges values ('4452','4452','Passif ','Dettes Hors Exploitation','Etat cr�diteur');
insert into datamart_R4_cpt_Charges values ('4453','4453','Passif ','Dettes Hors Exploitation','Etat cr�diteur');
insert into datamart_R4_cpt_Charges values ('4455','4455','Passif ','Dettes Hors Exploitation','Etat cr�diteur');
insert into datamart_R4_cpt_Charges values ('4457','4457','Passif ','Dettes Hors Exploitation','Etat cr�diteur');
insert into datamart_R4_cpt_Charges values ('4458','4458','Passif ','Dettes Hors Exploitation','Etat cr�diteur');
insert into datamart_R4_cpt_Charges values ('4463','4463','Passif ','Dettes Hors Exploitation','Comptes d associ�s');
insert into datamart_R4_cpt_Charges values ('4465','4465','Passif ','Dettes Hors Exploitation','Comptes d associ�s');
insert into datamart_R4_cpt_Charges values ('4488','4488','Passif ','Dettes Hors Exploitation','Autres Cr�anciers');
insert into datamart_R4_cpt_Charges values ('4493','4493','Passif ','Dettes Hors Exploitation','Comptes de r�gularisation Passif');
insert into datamart_R4_cpt_Charges values ('4497','4497','Passif ','Dettes Hors Exploitation','Comptes de r�gularisation Passif');
insert into datamart_R4_cpt_Charges values ('4506','4506','Passif ','Dettes Hors Exploitation','Autres provisions pour risques et charges');
insert into datamart_R4_cpt_Charges values ('4508','4508','Passif ','Dettes Hors Exploitation','Autres provisions pour risques et charges');
insert into datamart_R4_cpt_Charges values ('4702','4702','Passif ','Dettes Hors Exploitation','Ecart de conversion Passif');
insert into datamart_R4_cpt_Charges values ('5111','5111','Passif ','Tr�sorerie Active ','Ch�ques et valeurs � encaisser');
insert into datamart_R4_cpt_Charges values ('5115','5115','Passif ','Tr�sorerie Active ','Ch�ques et valeurs � encaisser');
insert into datamart_R4_cpt_Charges values ('5141','5141','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5145','5145','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5142','5142','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5148','5148','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5146','5146','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5147','5147','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5149','5149','Passif ','Tr�sorerie Active ','Banque Solde d�biteur ');
insert into datamart_R4_cpt_Charges values ('5161','5161','Passif ','Tr�sorerie Active ','Caisses ');
insert into datamart_R4_cpt_Charges values ('5162','5162','Passif ','Tr�sorerie Active ','Caisses ');
insert into datamart_R4_cpt_Charges values ('5163','5163','Passif ','Tr�sorerie Active ','Caisses ');
insert into datamart_R4_cpt_Charges values ('5164','5164','Passif ','Tr�sorerie Active ','Caisses ');
insert into datamart_R4_cpt_Charges values ('5167','5167','Passif ','Tr�sorerie Active ','Caisses ');
insert into datamart_R4_cpt_Charges values ('5541','5541','Passif ','Tr�sorerie Passive ','Banques Soldes Cr�diteurs ');
insert into datamart_R4_cpt_Charges values ('5530','5530','Passif ','Tr�sorerie Passive ','Banques Soldes Cr�diteurs ');
insert into datamart_R4_cpt_Charges values ('5548','5548','Passif ','Tr�sorerie Passive ','Autres �tablissements Financiers');
insert into datamart_R4_cpt_Charges values ('160','160','Passif ','Dettes de Financement','Comptes de liaisons des �tablissements et Succ');
insert into datamart_R4_cpt_Charges values ('171','171','Passif','Dettes de Financement','�cart de convesion Passif');
insert into datamart_R4_CPT_charges values ('7392','7392','R�sultat Financier','Produits Financiers','Reprise sur provision pour d�preciation'); 
insert into datamart_R4_cpt_charges values ('6711','6711','Imp�t','Imp�t sur le R�sultat','Impot / R�sultat'); 
insert into datamart_R4_cpt_charges values  ('2285','2285','Actif Immobilis�','Immobilisations','Autres immobilisations incorporelles');
insert into datamart_R4_cpt_charges values  ('4456','4456','TVA  due (suivant declaration)','TVA  due','TVA  due (suivant declaration)');

insert into datamart_R4_cpt_charges values  ('7116','7116','VENTES DES M/SES AU MAROC AT 10%','VENTES DES M/SES AU MAROC AT 10%','VENTES DES M/SES AU MAROC AT 10%');
insert into datamart_R4_cpt_charges values  ('7124','7124','VENTES DE PRESTATION DE SERVICE','VENTES DE PRESTATION DE SERVICE','VENTES DE PRESTATION DE SERVICE');
insert into datamart_R4_cpt_charges values  ('7580','7580','AUTRES PRODUITS NON COURANTS','AUTRES PRODUITS NON COURANTS','AUTRES PRODUITS NON COURANTS');
/
commit
/ 
drop table datamart_code_ag
/
create table datamart_code_ag (code_ag varchar2(4),lib varchar2(60))
/
insert into datamart_code_ag values ('00','Si�ge');
insert into datamart_code_ag values ('01','Si�ge ou Sapino');
insert into datamart_code_ag values ('02','Agence Casa');
insert into datamart_code_ag values ('03','Ait Melloul');
insert into datamart_code_ag values ('04','Marrakech');
insert into datamart_code_ag values ('05','Berkane ');
insert into datamart_code_ag values ('06','Benimellal');
insert into datamart_code_ag values ('08','Larache');
insert into datamart_code_ag values ('09','Kenitra');
insert into datamart_code_ag values ('10','Meknes');
insert into datamart_code_ag values ('11','El jadida');
insert into datamart_code_ag values ('12','Si�ge ou Sapino');
insert into datamart_code_ag values ('13','Errachidia');
insert into datamart_code_ag values ('14','Oujda');
insert into datamart_code_ag values ('96','A mediouna');
insert into datamart_code_ag values ('97','A appel d offre');
insert into datamart_code_ag values ('98','Atelier');
insert into datamart_code_ag values ('99','simay')
/
drop table datamart_CentreC
/
create table datamart_CentreC (CodeCC varchar2(10),lib_CC varchar2(100),code_ag varchar2(4))
/
insert into datamart_CentreC values ('AGC','CASA','02');
insert into datamart_CentreC values ('AGA','AIT MELLOUL','03');
insert into datamart_CentreC values ('AGM','MARRAKECH','04');
insert into datamart_CentreC values ('AGB','BERKANE','05');
insert into datamart_CentreC values ('AGN','BENI MELLAL','06');
insert into datamart_CentreC values ('AGL','LARACHE','08');
insert into datamart_CentreC values ('AGK','KENITRA','09');
insert into datamart_CentreC values ('AGS','MEKNES','10');
insert into datamart_CentreC values ('AGJ','EL JADIDA','11');
insert into datamart_CentreC values ('AGR','ERRACHIDIA','13');
insert into datamart_CentreC values ('AGO','OUJDA','14');
insert into datamart_CentreC values ('ATM','A mediouna','96');
insert into datamart_CentreC values ('ATZ','Appel d offre','97');
insert into datamart_CentreC values ('ATT','Atelier','98');
insert into datamart_CentreC values ('AGU','simay','99');
insert into datamart_CentreC values ('AGP','Sapino','01');
insert into datamart_CentreC values ('SIG','Si�ge','00');
insert into datamart_CentreC values ('DIV','Divers','15')
/
commit
/
drop table datamart_tiers
/
create table datamart_tiers as select bprnum_0 ,bprnam_0,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=bprnum_0) xclasse  from bpartner
/
drop table datamart_detail_charges2020
/
create table datamart_detail_charges2020 as  select b.accnum_0,a.typ_0,a.num_0,a.jou_0,a.accdat_0,to_char(a.accdat_0, 'YYMM') AAMM, a.fcy_0,b.acc_0,b.sns_0,b.amtled_0,b.sns_0*b.amtled_0  mnt,b.acc_0 cpt ,b.bpr_0 tiers, substr(b.acc_0,1,4) racine_cpt1,substr(b.acc_0,1,4) racine_cpt2,substr(b.acc_0,7,2) code_ag, decode(a.typ_0,'SMG',(select decode(substr(max(cce_0),8,2),'02','AGC','03','AGA','04','AGM','05','AGB','06','AGN','08','AGL','09','AGK','10','AGS','11','AGJ','13','AGR','14','AGO','96','ATM','97','ATZ','98','ATT','99','AGU','01','AGP','00','SIG','15','DIV')  from gaccentrya u where u.num_0=a.num_0 and u.typ_0=a.typ_0 and u.lin_0=b.lin_0 and u.acc_0=b.acc_0 and u.accnum_0=b.accnum_0), (select codecc from datamart_centrec where code_ag=substr(b.acc_0,7,2)) ) codecc,b.chk_0 ,b.offacc_0  ,a.duddat_0 dech,b.des_0 lib_ecr,a.rvs_0 extourne  from  gaccentry a,gaccentryd b where a.typ_0=b.typ_0 and b.ledtyp_0=1 and a.num_0=b.num_0 and a.typ_0<>'ODM' and a.accdat_0 between '01/01/2021' and '31/12/2026'   and ( substr(b.acc_0,1,4) in (select racine_cpt1 from datamart_R4_cpt_Charges) or substr(b.acc_0,1,3) in (select racine_cpt1 from datamart_R4_cpt_Charges) ) and a.fcy_0='SIG' and b.ledtyp_0=1
/

exit
/
