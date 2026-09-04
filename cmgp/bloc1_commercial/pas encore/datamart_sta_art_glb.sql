SELECT
    code,
    SUM(qte)       AS qte,
    SUM(ca_net_ht) AS ca_net_ht
FROM datamart_sta_art
GROUP BY code