create table datamart_facture_frs as select aa.accdat_0 Dfac,aa.num_0 Nfac,aa.bpr_0 Frs,(select oo.bpsnam_0 from bpsupplier oo where oo.bpsnum_0=aa.bpr_0) nom,
kk.pthnum_0 NumRec,kk.pnhnum_0 NumRet,(select u.rcpdat_0 from preceipt u where u.pthnum_0=kk.pthnum_0) date_Rec,
(select t.rtndat_0 from preturn t where t.pnhnum_0=kk.pnhnum_0) date_ret,kk.itmref_0 CodeArt,kk.itmdes1_0 Designation,
(select l.cry_0 from bpartner l where l.bprnum_0=aa.bpr_0) Pays,kk.qtypuu_0 Qt�,kk.netpri_0 PUHT,kk.amttaxlin1_0+kk.amttaxlin2_0 tva,kk.amtatilin_0 TTC,
aa.cur_0,aa.ratmlt_0 cours 
from pinvoice aa,pinvoiced kk 
where aa.num_0=kk.num_0 and aa.accdat_0 between '01/01/2021' and '31/12/2026' and aa.fcy_0<>'FR' and (kk.qtypuu_0 <> 0) 
/ --- n'existe pas en prod meme la selection est bien correct 