SELECT 
    a.POHNUM_0 AS num_cmd,
    a.bpsnum_0 AS fourn_code,
    a.bprnam_0 AS fourn_name,
    a.orddat_0 AS date_commande,
    a.crynam_0 AS pays,
    b.itmref_0 AS article,
    y.itmdes1_0 AS lib_article,
    b.qtystu_0 AS qte_commande,
    b.stu_0 AS unite,
    b.RCPQTYSTU_0 AS qte_rec,
    b.LINAMT_0 / b.qtystu_0 AS prix_net,
    CASE 
        WHEN TO_DATE(SUBSTR(TRIM(a.xetaped1_0), 1, 10), 'DD/MM/RR') <> TO_DATE('31/12/1999', 'DD/MM/YYYY') THEN a.xetaped1_0 
        WHEN TO_DATE(SUBSTR(TRIM(a.xetaped0_0), 1, 10), 'DD/MM/RR') <> TO_DATE('31/12/1999', 'DD/MM/YYYY') THEN a.xetaped0_0 
        ELSE EXTRCPDAT_0 
    END AS date_prevu,
    CASE 
        WHEN LINCLEFLG_0 = 2 THEN 'Oui' 
        ELSE 'Non' 
    END AS solder,
    b.POHFCY_0 AS site_recept,
    CUR_0,
    b.poplin_0 AS ligne_cmd,
    CASE 
        WHEN a.bpsnum_0 LIKE '0%' THEN 2 
        ELSE 1 
    END AS type 
FROM 
    porder a,
    porderq b,
    itmmaster y 
WHERE 
    a.POHNUM_0 = b.POHNUM_0 
    AND y.itmref_0 = b.itmref_0 
    AND BETFCY_0 <> 2