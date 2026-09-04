create table datamart_bl_ret_fac as select decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0) piece,
decode(substr(x.gte_0,1,1),'F',(select dlvdat_0 from sdelivery where sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0)) , 'A',
(select rtndat_0 from sreturn where srhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0))) date_piece,x.num_0 fac,
decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence, x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,
y.tsicod_1 FT,y.tsicod_2 FD,'            ' FCMKT,'                                                        ' FCLIBMKT,'       ' FTMKT,'                          
                 ' FTLIBMKT,'                ' FDMKT,'                                                  ' FDLIBMKT,y.gropri_0 tarif,
decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*x.ratmlt_0),'A',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1) HTN ,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*x.ratmlt_0),'A',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1) HTB ,substr(x.bpr_0,2,1) categ,'     ' proj,
decode((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=y.sdhnum_0 and ii.bpcord_0=x.bpr_0),null,'DISTRIBUTION',
decode(substr((select max( ii.axeproj_0 ) from xprojet ii where ii.sdhnum_0=y.sdhnum_0 and ii.bpcord_0=x.bpr_0),2,1),'U','APPEL OFFRE','MARCHE PRIVE'   ) )  canal,
decode((select t.itmref_0 from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') sicda,'        ' ARTF, '        ' frs,'                                  ' lib_frs2 ,(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=x.bpr_0) xclasse  
from sinvoice x,sinvoiced y 
where x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' and x.gte_0 <> 'AFV' 
/
---- Dans gte_0 y'a que F% et A% 


-------------------------------------
update datamart_bl_ret_fac y set 
fcmkt = (select xfc_0 from itmmaster t where t.itmref_0=y.article),
FCLIBMKT=(select xfclib_0 from itmmaster t where t.itmref_0=y.article) ,
FTMKT=(select xfT_0 from itmmaster t where t.itmref_0=y.article) ,
FTLIBMKT=(select xfTlib_0 from itmmaster t where t.itmref_0=y.article) ,
FDMKT=(select xfD_0 from itmmaster t where t.itmref_0=y.article) ,
FDLIBMKT=(select xfDlib_0 from itmmaster t where t.itmref_0=y.article) ,
proj = (select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=y.piece and ii.bpcord_0=y.tiers) ,
sicda = decode((select t.itmref_0 from itmbps t where t.itmref_0=y.article and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') ,
ARTF = decode((select a.itmref_0 from bom a where a.itmref_0=y.article),null,'NON','OUI'),
frs = (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article),
lib_frs2 = (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.article) )
/
--- initialiser ces colonnes vides et puis remplisser create + update


------------------------------------
update datamart_BL_RET_FAC set canal='APPEL OFFRE' where categ='U'
/
update datamart_BL_RET_FAC set piece ='FORFAIT' where piece is null or piece=' '
/
update datamart_BL_RET_FAC set date_piece=date_fac where piece='FORFAIT'
/
update datamart_BL_RET_FAC z set z.proj=(select max(u.proj) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.proj is not null),
canal=(select max(u.canal) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.canal is not null) where z.piece='FORFAIT' 
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