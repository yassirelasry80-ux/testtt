create table commercial02_BL_t  as SELECT x.sdhnum_0 AS bl,decode(length(x.bpcord_0),6,substr(x.bpcord_0,1,1),substr(x.bpcord_0,7,1)) AS agence, x.dlvdat_0 AS date_bl, 
x.bpcord_0 AS tiers, y.itmref_0 AS Article, y.itmdes1_0 AS Lib_art_bl, y.tsicod_0 AS FC, y.tsicod_1 AS FT, y.tsicod_2 AS FD, xfc_0 FCMKT,xfclib_0 AS FCLIBMKT, xft_0 AS FTMKT,
xftlib_0 AS FTLIBMKT, xfd_0 AS FDMKT,xfdlib_0 AS FDLIBMKT, y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS tarif, y.qty_0 AS qte,
(y.qty_0 * y.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTN, (y.qty_0 * y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTB,
substr(ysauv_clt_0,2,1) AS categ, (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs, y.sddlin_0 AS ligne, 
(y.qty_0 * y.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS TTCN, y.sohnum_0, y.soplin_0, TO_CHAR(y.soqseq_0) AS soqseq_0, 0 AS lignebl,
t.xbusline_0 AS xbusline_0 
FROM sdelivery x, sdeliveryd y,itmmaster t,bpcustomer r 
WHERE r.bpcnum_0=x.bpcord_0 and t.itmref_0 = y.itmref_0 and x.sdhnum_0 = y.sdhnum_0 AND x.sdhnum_0 LIKE 'B%' 
AND x.dlvdat_0 BETWEEN '01/01/2020' AND '31/12/2026';
-- usage de taux d echange fige
-- no export


create table commercial02_ret_t as select xx.srhnum_0 numret,decode(length(xx.bpcord_0),6,substr(xx.bpcord_0,1,1),substr(xx.bpcord_0,7,1)) ag,xx.rtndat_0,xx.bpcord_0,yy.itmref_0,
yy.itmdes1_0,t.tsicod_0 FC,t.tsicod_1 FT,t.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,
yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) netpri_0,yy.qty_0*-1 qty_0,(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTN,
(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTB,substr(ysauv_clt_0,2,1) categ,
(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=yy.itmref_0) frs , yy.srdlin_0 ligne,(yy.qty_0*yy.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 TTCN
 ,yy.sdhnum_0,yy.sddlin_0,'0' soplig,0 ligret,xbusline_0 
 from sreturn xx, sreturnd yy,itmmaster t,bpcustomer r 
 where r.bpcnum_0=xx.bpcord_0 and t.itmref_0=yy.itmref_0 and xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 
 between '01/01/2019' and '31/12/2026' and substr(xx.srhnum_0,1,2) in ('RV','RP') ;
-- usage de taux d echange fige
-- HTB calcule avec netpri_0 et pas gropri_0
-- no export


create table commercial02_fac_t as select x.num_0 fac,decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)) agence,x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,
y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,t.tsicod_2 FD,xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,
y.gropri_0*ratmlt_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*ratmlt_0),'A',(y.qty_0*y.netpri_0)*ratmlt_0*-1) HTN ,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*ratmlt_0),'A',(y.qty_0*y.gropri_0*ratmlt_0)*-1) HTB,
(select substr(ysauv_clt_0,2,1) from bpcustomer where bpcnum_0=x.bpr_0) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sidlin_0 ligne,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpriati_0*ratmlt_0),'A',(y.qty_0*y.netpriati_0*ratmlt_0)*-1) TTCN ,y.sdhnum_0,y.sddlin_0,y.srhnum_0,y.srdlin_0,xbusline_0 
from sinvoice x,sinvoiced y,itmmaster t 
where t.itmref_0=y.itmref_0 and x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' 
and ((substr(x.num_0,1,1) in ('F','P') and y.sdhnum_0=' ') or (substr(x.num_0,1,1) in ('A') and y.srhnum_0=' ')) and substr(x.num_0,1,2) not like 'AF%' ;
-- Montant CA : ici utilisation de sinvoiced y, y.qty_0*y.netpri_0*ratmlt_0      vs   sinvoiced.amtnotlin_0 dans datamart_sta_art
-- max(uu.bpsnum_0) envoi resultat arbitraire de fournisseur d article 
--- no export
-- tsicod_0 vient de sinvoiced vs vient de itmmaster

create table commercial02_t as select * from commercial02_BL_t  union select * from commercial02_ret_t union select * from commercial02_fac_t;
alter table commercial02_t add xdev varchar2(100);

update commercial02_t set xdev= (select xdevis_0 from sorder where sohnum_0=(select sohnum_0 from sdeliveryd where bl=sdhnum_0 and sddlin_0=ligne))
where bl like 'B%';

update commercial02_t set xdev = (select distinct xdevis_0 from sorder where sohnum_0 in (select distinct sohnum_0 from sdeliveryd where sdhnum_0 in (select distinct sdhnum_0 from sreturnd where srhnum_0=bl and srdlin_0=ligne))) 
 where bl like 'RV%' ;

commit;

UPDATE commercial02_t SET FD = 'RA01' WHERE ARTICLE LIKE 'RA02%';
