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
        CASE 
            WHEN NVL(b.qtystu_0, 0) = 0 THEN NULL 
            ELSE b.LINAMT_0 / b.qtystu_0 
        END AS prix_net,
        xtc_0 AS contener, 
        b.EXTRCPDAT_0 AS date_prevu,
        CASE 
            WHEN b.LINCLEFLG_0 = 2 THEN 'Oui' 
            ELSE 'Non' 
        END AS solder,
        b.POHFCY_0 AS site_recept,
        a.CUR_0
    FROM porder a
    JOIN porderq b 
        ON a.POHNUM_0 = b.POHNUM_0
    JOIN itmmaster y 
        ON y.itmref_0 = b.itmref_0
    WHERE a.bpsnum_0 LIKE '0%'