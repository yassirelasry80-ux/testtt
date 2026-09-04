create table datamart_BL_RET_FA as select decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0) piece,
decode(x.gte_0,'FAC',(select dlvdat_0 from sdelivery where sdhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)) , 'FCP', 
(select dlvdat_0 from sdelivery where sdhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)),'AVC',
(select rtndat_0 from sreturn where srhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)),'AVP',
(select rtndat_0 from sreturn where srhnum_0=decode(x.gte_0,'FAC',y.sdhnum_0,'FCP',y.sdhnum_0,'AVC',y.srhnum_0,'AVP',y.srhnum_0)) ) date_piece,x.num_0 fac,
decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence, x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,
y.tsicod_1 FT,y.tsicod_2 FD,'              ' FCMKT,'                                        ' FCLIBMKT,'      ' FTMKT,'                             ' FTLIBMKT,
'                ' FDMKT,'                              ' FDLIBMKT,y.gropri_0 tarif,
decode(x.gte_0,'FAC',y.qty_0,'FCP',y.qty_0,'AVC',y.qty_0*-1,'AVP',y.qty_0*-1,'AFV',y.qty_0*-1) qte,
decode(x.gte_0,'FAC',(y.qty_0*y.netpri_0*x.ratmlt_0),'FCP',(y.qty_0*y.netpri_0*x.ratmlt_0),'AVC',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1,'AVP',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1,
'AFV',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1) HTN ,decode(x.gte_0,'FAC',(y.qty_0*y.gropri_0*x.ratmlt_0),'FCP',(y.qty_0*y.gropri_0*x.ratmlt_0),'AVC',
(y.qty_0*y.gropri_0*x.ratmlt_0)*-1,'AVP',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1,'AFV',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1) HTB ,
substr(x.bpr_0,2,1) categ,'       ' proj,' '  canal,'                     ' sicda,'          ' ARTF, '      ' frs,'                                                  ' lib_frs2,
(select ' ' from bpcustomer f where f.bpcnum_0=x.bpr_0) xclasse  
from sinvoice x,sinvoiced y 
where x.num_0=y.num_0  and x.accdat_0 BETWEEN TO_DATE('01/01/2017','DD/MM/YYYY')  AND TO_DATE('31/12/2026','DD/MM/YYYY') and x.gte_0 <> 'AFV' 
/
update datamart_bl_ret_fa y set 
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
update datamart_BL_RET_FA set piece ='FORFAIT' where piece is null or piece=' '
/
update datamart_BL_RET_FA set date_piece=date_fac where piece='FORFAIT'
/
update datamart_BL_RET_FA z set z.proj=' '
/
commit
/
select * from datamart_BL_RET_FA ;
/
drop table datamart_BL_RET_FA;
/