SELECT /*+ LEADING(a b y) USE_NL(b) USE_HASH(y) */ 
       a.pihtyp_0 AS type,
       a.num_0 AS num_fact,
       a.bpr_0 AS fourn_code,
       a.bprnam_0 AS fourn_name,
       a.accdat_0 AS date_facture,
       b.itmref_0 AS article,
       y.itmdes1_0 AS lib_article,
       b.qtyuom_0 AS qte_fact,
       b.uom_0 AS unite,
       b.NETPRI_0 AS prix_net,
       a.CUR_0,
       a.ratmlt_0 AS cours,
       b.pthnum_0 AS num_rec,
       b.ptdlin_0 AS ligne_rec,
       b.pohnum_0 AS num_cmd,
       b.poplin_0 AS ligne_cmd 
FROM pinvoice a
INNER JOIN pinvoiced b 
    ON a.num_0 = b.num_0
INNER JOIN itmmaster y 
    ON y.itmref_0 = b.itmref_0