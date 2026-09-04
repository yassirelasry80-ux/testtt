INSERT INTO   datamart_creances_client_date  select tiers,lib_tiers,(select categ_datamart.lib_categ_client from categ_datamart where categ_datamart.categ=client_datamart.categ_clt) as cat,(select datamart_salesrep.lib_rep from datamart_salesrep where datamart_salesrep.agence=client_datamart.rep) as rep,client_datamart.xdmp_0,(select sum(mnt) from datamart_creances_client where datamart_creances_client.tiers=client_datamart.tiers and racine='3421') compt,(select sum(ttc) from datamart_facture_ncompt WHERE bpr_0=client_datamart.tiers ) as fcnoncpt,(select sum(TTCN) from datamart_bl_ret_nf WHERE tiers=client_datamart.tiers ) as blnonf,(select sum(solde*sns_0) from datamart_creances_client where datamart_creances_client.tiers=client_datamart.tiers and datamart_creances_client.impaye=1) impaye,(select sum(mnt) from datamart_creances_client where datamart_creances_client.tiers=client_datamart.tiers and   jou_0 =' ') reglpf,client_datamart.ostauz_0 plafond, sysdate from client_datamart
/

exit
/


