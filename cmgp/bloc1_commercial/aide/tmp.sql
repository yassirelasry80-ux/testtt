SELECT x.sdhnum_0 AS bl,decode(length(x.bpcord_0),6,substr(x.bpcord_0,1,1),substr(x.bpcord_0,7,1)) AS agence, x.dlvdat_0 AS date_bl, 
x.bpcord_0 AS tiers, y.itmref_0 AS Article, y.itmdes1_0 AS Lib_art_bl, y.tsicod_0 AS FC, y.tsicod_1 AS FT, 
case 
    when y.itmref_0 like 'RA02%' then 'RA01'
    else y.tsicod_2
end as FD,
xfc_0 FCMKT,xfclib_0 AS FCLIBMKT, xft_0 AS FTMKT,
xftlib_0 AS FTLIBMKT, xfd_0 AS FDMKT,xfdlib_0 AS FDLIBMKT, y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) AS tarif, y.qty_0 AS qte,
(y.qty_0 * y.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTN, (y.qty_0 * y.gropri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS HTB,
substr(ysauv_clt_0,2,1) AS categ, (SELECT MAX(uu.bpsnum_0) FROM itmbps uu WHERE uu.itmref_0 = y.itmref_0) AS frs, y.sddlin_0 AS ligne, 
(y.qty_0 * y.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1)) AS TTCN, y.sohnum_0, y.soplin_0, TO_CHAR(y.soqseq_0) AS soqseq_0, 0 AS lignebl,
t.xbusline_0 AS xbusline_0 ,
case 
    when x.sdhnum_0 like 'B%' then (
        select xdevis_0 
        from sorder 
        where sohnum_0 = (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 = x.sdhnum_0 
              and sddlin_0 = y.sddlin_0
        )
    )

    when x.sdhnum_0 like 'RV%' then (
        select distinct xdevis_0 
        from sorder 
        where sohnum_0 in (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 in (
                select sdhnum_0 
                from sreturnd 
                where srhnum_0 = x.sdhnum_0 
                  and srdlin_0 = y.sddlin_0
            )
        )
    )

    else null
end as xdev
FROM sdelivery x, sdeliveryd y,itmmaster t,bpcustomer r 
WHERE r.bpcnum_0=x.bpcord_0 and t.itmref_0 = y.itmref_0 and x.sdhnum_0 = y.sdhnum_0 AND x.sdhnum_0 LIKE 'B%' 
AND x.dlvdat_0 BETWEEN '01/01/2020' AND '31/12/2026'

union

select xx.srhnum_0 numret,decode(length(xx.bpcord_0),6,substr(xx.bpcord_0,1,1),substr(xx.bpcord_0,7,1)) ag,xx.rtndat_0,xx.bpcord_0,yy.itmref_0,
yy.itmdes1_0,t.tsicod_0 FC,t.tsicod_1 FT,
case 
    when yy.itmref_0 like 'RA02%' then 'RA01'
    else t.tsicod_2
end as FD,
xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,
yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1) netpri_0,yy.qty_0*-1 qty_0,(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTN,
(yy.qty_0*yy.netpri_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 HTB,substr(ysauv_clt_0,2,1) categ,
(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=yy.itmref_0) frs , yy.srdlin_0 ligne,(yy.qty_0*yy.netpriati_0*decode(r.cur_0,'MAD',1,'EUR',10.82,'USD',9.26,1))*-1 TTCN
 ,yy.sdhnum_0,yy.sddlin_0,'0' soplig,0 ligret,xbusline_0 ,
 case 
    when xx.srhnum_0 like 'B%' then (
        select xdevis_0 
        from sorder 
        where sohnum_0 = (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 = xx.srhnum_0 
              and sddlin_0 = yy.srdlin_0
        )
    )

    when xx.srhnum_0 like 'RV%' then (
        select distinct xdevis_0 
        from sorder 
        where sohnum_0 in (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 in (
                select sdhnum_0 
                from sreturnd 
                where srhnum_0 = xx.srhnum_0 
                  and srdlin_0 = yy.srdlin_0
            )
        )
    )

    else null
end as xdev
 from sreturn xx, sreturnd yy,itmmaster t,bpcustomer r 
 where r.bpcnum_0=xx.bpcord_0 and t.itmref_0=yy.itmref_0 and xx.srhnum_0=yy.srhnum_0 and xx.rtndat_0 
 between '01/01/2019' and '31/12/2026' and substr(xx.srhnum_0,1,2) in ('RV','RP') 

union

select x.num_0 fac,decode(length(x.bpr_0),6,substr(x.bpr_0,1,1),substr(x.bpr_0,7,1)) agence,x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,
y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,
case 
    when y.itmref_0 like 'RA02%' then 'RA01'
    else t.tsicod_2
end as FD,
xfc_0 FCMKT,xfclib_0 FCLIBMKT,xfT_0 FTMKT,xfTlib_0 FTLIBMKT,xfD_0 FDMKT,xfDlib_0 FDLIBMKT,
y.gropri_0*ratmlt_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*ratmlt_0),'A',(y.qty_0*y.netpri_0)*ratmlt_0*-1) HTN ,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*ratmlt_0),'A',(y.qty_0*y.gropri_0*ratmlt_0)*-1) HTB,
(select substr(ysauv_clt_0,2,1) from bpcustomer where bpcnum_0=x.bpr_0) categ,(select max(uu.bpsnum_0) from itmbps uu where uu.itmref_0=y.itmref_0) frs,y.sidlin_0 ligne,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpriati_0*ratmlt_0),'A',(y.qty_0*y.netpriati_0*ratmlt_0)*-1) TTCN ,y.sdhnum_0,y.sddlin_0,y.srhnum_0,y.srdlin_0,xbusline_0 , 
case 
    when x.num_0 like 'B%' then (
        select xdevis_0 
        from sorder 
        where sohnum_0 = (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 = x.num_0 
              and sddlin_0 = y.sidlin_0
        )
    )

    when x.num_0 like 'RV%' then (
        select distinct xdevis_0 
        from sorder 
        where sohnum_0 in (
            select sohnum_0 
            from sdeliveryd 
            where sdhnum_0 in (
                select sdhnum_0 
                from sreturnd 
                where srhnum_0 = x.num_0 
                  and srdlin_0 = y.sidlin_0
            )
        )
    )

    else null
end as xdev
from sinvoice x,sinvoiced y,itmmaster t 
where t.itmref_0=y.itmref_0 and x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' 
and ((substr(x.num_0,1,1) in ('F','P') and y.sdhnum_0=' ') or (substr(x.num_0,1,1) in ('A') and y.srhnum_0=' ')) and substr(x.num_0,1,2) not like 'AF%' 




update commercial02_t set xdev= (select xdevis_0 from sorder where sohnum_0=(select sohnum_0 from sdeliveryd where bl=sdhnum_0 and sddlin_0=ligne))
where bl like 'B%'
/
update commercial02_t set xdev = (select distinct xdevis_0 from sorder where sohnum_0 in (select distinct sohnum_0 from sdeliveryd where sdhnum_0 in (select distinct sdhnum_0 from sreturnd where srhnum_0=bl and srdlin_0=ligne))) 
 where bl like 'RV%' 
/
commit
/
UPDATE commercial02_t SET FD = 'RA01' WHERE ARTICLE LIKE 'RA02%'
-- Recodification dupliquée FD 'RA01'   ici et dans article_datamart
/
COMMIT
/



DROP TABLE ARTICLE_DATAMART_TEST PURGE;
DROP TABLE BI_XPROJET_TEST PURGE;
DROP TABLE CATEG_DATAMART_TEST PURGE;
DROP TABLE CLIENT_DATAMART_TEST PURGE;
DROP TABLE COMMERCIAL00_TEST PURGE;
DROP TABLE COMMERCIAL01_TEST PURGE;
DROP TABLE COMMERCIAL02_TEST PURGE;
DROP TABLE COMMERCIAL03_TEST PURGE;
DROP TABLE COMMERCIAL04_TEST PURGE;
DROP TABLE COMMERCIAL06_TEST PURGE;
DROP TABLE DATAMART_AFFAIRE_P_TEST PURGE;
DROP TABLE DATAMART_AFFAIRE_R_TEST PURGE;
DROP TABLE DATAMART_AFFAIRE_TEST PURGE;
DROP TABLE DATAMART_AFFAIRE_TE_TEST PURGE;
DROP TABLE DATAMART_AFFAIRE2_TEST PURGE;
DROP TABLE DATAMART_ASSEMBLAGE_TEST PURGE;
DROP TABLE DATAMART_AV_FINANCIER_TEST PURGE;
DROP TABLE DATAMART_BL_RET_FAC_TEST PURGE;
DROP TABLE DATAMART_BL_RET_NF_TEST PURGE;
DROP TABLE DATAMART_CDE_ACHAT_TEST PURGE;
DROP TABLE DATAMART_CREANCES_CLIENT_FAC_T PURGE;
DROP TABLE DATAMART_CREANCES_CLIENT_TEST PURGE;
DROP TABLE DATAMART_DA_TEST PURGE;
DROP TABLE DATAMART_DETAIL_CHARGES2020_TE PURGE;
DROP TABLE DATAMART_DETAIL_DEVIS_TEST PURGE;
DROP TABLE DATAMART_DOS_IMPORT_ACHAT_TEST PURGE;
DROP TABLE DATAMART_ENTRE_SORTIE_TEST PURGE;
DROP TABLE DATAMART_FACTURE_NCOMPT_TEST PURGE;
DROP TABLE DATAMART_GARANTIES_TEST PURGE;
DROP TABLE DATAMART_PRIX_CONSO_TEST PURGE;
DROP TABLE DATAMART_PRODUCTION_TEST PURGE;
DROP TABLE DATAMART_RECEPTIONS_TEST PURGE;
DROP TABLE DATAMART_REGION_TEST PURGE;
DROP TABLE DATAMART_REMISE_EXCEPT_TEST PURGE;
DROP TABLE DATAMART_RESERVATION_TEST PURGE;
DROP TABLE DATAMART_SALESREP_TEST PURGE;
DROP TABLE DATAMART_STOCK_THEORIQUE_TEST PURGE;
DROP TABLE DATAMART_STOJOU_TEST PURGE;
DROP TABLE DATAMART_TIERS_TEST PURGE;
DROP TABLE DATAMART_VILLE_TEST PURGE;
DROP TABLE DATAMART_XHISVAL_TEST PURGE;
DROP TABLE FC_DATAMART_TEST PURGE;
DROP TABLE FD_DATAMART_TEST PURGE;
DROP TABLE FRS_DATAMART_TEST PURGE;
DROP TABLE FT_DATAMART_TEST PURGE;
DROP TABLE GROUPE_DATAMART_TEST PURGE;

DROP TABLE DATAMART_DETAIL_CHARGES_TEST PURGE;
DROP TABLE DATAMART_REGL_CLT_FRS_TEST PURGE;
DROP TABLE DATAMART_STOCK_INI_FIFO_BIS_TE PURGE;
DROP TABLE DATAMART_STOCK_INI_FIFO_TEST PURGE;