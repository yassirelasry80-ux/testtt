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
    xtc_0 AS contener,
    EXTRCPDAT_0 AS date_prevu,
    CASE 
        WHEN LINCLEFLG_0 = 2 THEN 'Oui' 
        ELSE 'Non' 
    END AS solder,
    b.POHFCY_0 AS site_recept,
    CUR_0 
FROM 
    porder a,
    porderq b,
    itmmaster y 
WHERE 
    a.POHNUM_0 = b.POHNUM_0 
    AND SUBSTR(a.bpsnum_0, 1, 1) IN ('0') 
    AND y.itmref_0 = b.itmref_0 