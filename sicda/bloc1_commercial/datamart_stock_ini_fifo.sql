create table   datamart_sta_art_t as SELECT 
    f1.tsicod_2 AS fam,
    vv1.itmref_0 AS code,
    f1.des1axx_0 AS libelle,

    SUM(CASE 
            WHEN v1.gte_0 IN ('FAC','FCP') THEN vv1.qty_0
            WHEN v1.gte_0 IN ('AVC','AVP','AFV') THEN -vv1.qty_0
            ELSE 0 
        END) AS QTE,

    SUM(CASE 
            WHEN v1.gte_0 IN ('FAC','FCP') THEN vv1.amtnotlin_0
            WHEN v1.gte_0 IN ('AVC','AVP','AFV') THEN -vv1.amtnotlin_0
            ELSE 0 
        END) AS CA_NET_HT

FROM sinvoice v1
JOIN sinvoiced vv1 ON v1.num_0 = vv1.num_0
LEFT JOIN itmmaster f1 ON f1.itmref_0 = vv1.itmref_0

WHERE 
    v1.accdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY') 
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
    AND v1.bpr_0 LIKE 'Y%'

GROUP BY 
    vv1.itmref_0,
    f1.tsicod_2,
    f1.des1axx_0
;
/

create table  datamart_sta_art_glb_t as select code,sum(qte) qte,sum(ca_net_ht) ca_net_ht from datamart_sta_art_t group by code;
/
CREATE TABLE datamart_mvt_cmgp0_t AS
WITH inv AS (
    SELECT ii.pthnum_0,
           ii.ptdlin_0,
           MAX(ii.cpr_0) AS cpr,
           MAX(i.ratmlt_0) AS ratmlt_0
    FROM pinvoice i
    JOIN pinvoiced ii ON i.num_0 = ii.num_0
    WHERE i.ydanum_0 <> ' '
    GROUP BY ii.pthnum_0, ii.ptdlin_0
),
cpr2_calc AS (
    SELECT pa.pthnum_0,
           pa.itmref_0,
           SUM(p2.cpr_0) AS cpr2
    FROM preceiptd pa
    JOIN pinvoiced p1 
        ON pa.pthnum_0 = p1.numori_0 
       AND pa.ptdlin_0 = p1.linori_0 
       AND pa.itmref_0 = p1.itmref_0
    JOIN pinvoice xx 
        ON p1.num_0 = xx.num_0
    JOIN pinvoiced p2 
        ON p1.num_0 = p2.numori_0 
       AND p1.pidlin_0 = p2.pidlin_0
    GROUP BY pa.pthnum_0, pa.itmref_0
),
devise AS (
    SELECT x.pthnum_0,
           MAX(t.revcours_0) KEEP (DENSE_RANK LAST ORDER BY t.chgstrdat_0) AS revcours_0
    FROM preceipt x
    JOIN tabchange t 
        ON t.curden_0 = x.cur_0
       AND t.chgtyp_0 = 1
    GROUP BY x.pthnum_0
)
SELECT  
    p.pthnum_0,
    p.rcpdat_0,
    p.itmref_0,
    p.itmdes1_0,
    p.qtypuu_0,
    p.netpri_0,
    kk.xprirev_0,
    kk.mltcur_0,
    inv.cpr,
    cpr2_calc.cpr2,
    NVL(inv.ratmlt_0, devise.revcours_0) AS ratcur
FROM preceiptd p
LEFT JOIN xgpohlin k 
    ON p.pthnum_0 = k.pthnum_0 
   AND p.ptdlin_0 = k.ptdlin_0
LEFT JOIN xgdetpri kk 
    ON k.itmref_0 = kk.itmref_0 
   AND k.xdanum_0 = kk.xdanum_0
LEFT JOIN inv 
    ON p.pthnum_0 = inv.pthnum_0 
   AND p.ptdlin_0 = inv.ptdlin_0
LEFT JOIN cpr2_calc 
    ON p.pthnum_0 = cpr2_calc.pthnum_0 
   AND p.itmref_0 = cpr2_calc.itmref_0
LEFT JOIN devise 
    ON p.pthnum_0 = devise.pthnum_0
WHERE p.rcpdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY') 
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND SUBSTR(p.bpsnum_0,1,1) BETWEEN '0' AND '1';
/


create table datamart_mvt_cmgp_t as select * from (select pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD') mois,qte qte,
avg(round(prixrev,6)) prixrev from  (select rr.pthnum_0,rr.rcpdat_0,rr.itmref_0,rr.qtypuu_0 qte,rr.netpri_0,decode(rr.mltcur_0,null,rr.ratcur,rr.mltcur_0) cur, 
abs(decode(rr.xprirev_0,null,(rr.netpri_0*rr.ratcur)+nvl(cpr2,0),nvl(rr.xprirev_0,0)+nvl(cpr2,0))) prixrev,
cpr2 from datamart_mvt_cmgp0_t rr ) group by pthnum_0,itmref_0,to_char(rcpdat_0,'YYMMDD'),qte 
union 
(select x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD') Mois,sum(x.qtypuu_0 ) qte,abs(x.netpri_0) PrixRev 
from preceiptd x 
where x.rcpdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')  AND TO_DATE('31/12/2026','DD/MM/YYYY')
and   substr(x.bpsnum_0,1,1) between '2' and '9' 
group by x.pthnum_0,x.itmref_0,to_char(x.rcpdat_0,'YYMMDD'),x.netpri_0 ) 
union 
select x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD') Mois,sum(x.qtypcu_0) qte,abs(x.priord_0) PrixRev  
from stojou x 
where    ((substr(x.vcrnum_0,1,3) in ('BFM','ATL','ENT','MTK') and x.iptdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')  AND TO_DATE('31/12/2026','DD/MM/YYYY')   and x.trstyp_0 in (1,5))  
or (x.vcrnum_0 not like 'INV%' and x.vcrnum_0 like 'IN%' and x.iptdat_0 BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')  AND TO_DATE('31/12/2026','DD/MM/YYYY') )) 
group by x.vcrnum_0,x.itmref_0,to_char(x.iptdat_0,'YYMMDD'),x.priord_0 );
/

create table datamart_fifo_cmgp_t as select ff.mois,ff.itmref_0,ff.prixrev,sum(ff.qte) qte from datamart_mvt_cmgp_t ff group by ff.mois,ff.itmref_0,ff.prixrev;
/
create table datamart_synthesefifo_t as select itmref_0,mois,prixrev,sum(qte) qte,max(0) montant,max(0) qtetraiter,max(0) prix_rec 
from datamart_fifo_cmgp_t
group by mois,itmref_0,prixrev;
/


create table datamart_stock_ini_fifo_t as select   distinct  code,  qte stock,0 prixrev,'01/01/2019' dat_fifo  from   datamart_sta_art_glb_t;
/
declare cursor cur2 is select rowid,t.itmref_0,t.mois,t.prixrev,qte,qtetraiter from datamart_synthesefifo_t t order by 2,3 desc ;
cursor cur1 is select code, stock from  datamart_stock_ini_fifo_t order by 1;
wcode_cur2 varchar2(60);
wmois_cur2 varchar2(6);
wprix_cur2 number;
wqte_cur2 number;
wwprix_sauv number;
wcode_cur1 varchar2(60);
wqte_cur1 number;
wid varchar2(100);
wqte number;
wreliquat number;
wsauv_reliquat number;
wmontant number;
passe integer;
neg integer;
wqtetraiter number(22);
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
      
      update datamart_synthesefifo_t a set a.montant=wmontant, a.qtetraiter=wqte where a.itmref_0=wcode_cur2 and a.mois=wmois_cur2 
      and a.qte=wqte_cur2 and a.rowid=wid;
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

update datamart_stock_ini_fifo_t z set z.prixrev= nvl((select sum(prixrev*qtetraiter  )/decode(sum(qtetraiter ),0,9999999999999999,sum(qtetraiter )) 
from datamart_synthesefifo_t zz 
where trim(zz.itmref_0)=trim(z.code)),0);
/
commit;
/
update datamart_stock_ini_fifo_t set prixrev = prixrev * -1 where prixrev < 0;
/
select * from datamart_stock_ini_fifo_t ;

/
DROP TABLE datamart_sta_art_t PURGE;
/
DROP TABLE datamart_sta_art_glb_t PURGE;
/
DROP TABLE datamart_mvt_cmgp0_t PURGE;
/
DROP TABLE datamart_mvt_cmgp_t PURGE;
/
DROP TABLE datamart_fifo_cmgp_t PURGE;
/
DROP TABLE datamart_synthesefifo_t PURGE;
/
DROP TABLE datamart_stock_ini_fifo_t ;
/