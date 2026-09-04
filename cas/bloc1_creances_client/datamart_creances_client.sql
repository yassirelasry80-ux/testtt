WITH etape1 AS (
    SELECT 
        a.num_0,
        a.sta_0,
        a.accdat_0 AS dat,
        b.mtc_0,
        a.jou_0,
        b.acc_0,
        SUBSTR(b.acc_0, 1, 4) AS racine,
        b.bpr_0 AS tiers,
        (SELECT bpcnam_0 FROM bpcustomer c WHERE c.bpcnum_0 = b.bpr_0) AS nomclt,
        SUBSTR(b.bpr_0, 2, 1) AS categ,
        b.sns_0 * b.amtled_0 AS MNT,
        CASE 
            WHEN jou_0 = 'VE' THEN (a.accdat_0 + (SELECT XDRECOUVR_0 FROM bpcustomer WHERE bpcnum_0 = b.bpr_0)) 
            ELSE a.duddat_0 
        END AS date_ech,
        b.des_0,
        0 AS solde, 
        b.SNS_0,
        b.accnum_0,
        CASE WHEN a.num_0 LIKE '%IMP%' THEN 1 ELSE 0 end AS impaye  
    FROM gaccentry a, gaccentryd b 
    WHERE a.typ_0 = b.typ_0 
      AND a.num_0 = b.num_0 
      AND a.accdat_0 BETWEEN TO_DATE('01/01/2008', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY') 
      AND SUBSTR(b.acc_0, 1, 4) IN ('3425', '3426', '3424', '3421', '3427', '3428', '3429') 
      AND (b.mtc_0 = ' ' OR b.mtc_0 BETWEEN 'a' AND 'z') 
      AND b.bpr_0 <> 'ZZZZ'  
      AND (a.typ_0 <> 'RANX1' OR (a.typ_0 = 'RANX1' AND EXTRACT(YEAR FROM a.accdat_0) = 2021))  
      and b.ledtyp_0 = 1 

    UNION 

    SELECT  
        nnum,
        3 AS typ,
        dat,
        mtc,
        ' ' AS jou,
        acc,
        SUBSTR(acc, 1, 4) AS racine,
        code,
        nom,
        SUBSTR(code, 2, 1) AS categ,
        mnt_ttc - mnt AS MNT,
        datec,
        des,
        0 AS solde, 
        sns,
        0 AS accnum, 
        0 AS impaye  
    FROM (
        SELECT 
            x.bpr_0 AS code,
            x.bpanam_0 AS nom,
            x.num_0 AS nnum,
            x.duddat_0 AS datec,
            x.amtcur_0 AS mnt_ttc,
            DECODE(cc.chk_0, ' ', 0, NULL, 0, (SELECT SUM(paycur_0 * e.sns_0) FROM gaccdudate e WHERE e.num_0 = c.num_0 AND e.bpr_0 = c.bpr_0 AND e.lig_0 = c.lin_0)) AS mnt,
            c.mtc_0 AS mtc,
            c.acc_0 AS acc,
            x.accdat_0 AS dat,
            c.des_0 AS des,
            cc.sns_0 AS sns 
        FROM paymenth x, gaccentryd c, gaccentryd cc 
        WHERE c.accnum_0(+) = x.accnumtre_2  
          AND x.sta_0 BETWEEN 2 AND 10  
          AND cc.accnum_0(+) = x.accnumtre_8 
          AND (x.sta_0 > 2 AND x.sta_0 <> 10) 
          AND (x.bprsac_0 = 'CL1' AND x.pam_0 IN ('CHQ', 'TAC'))
    ) 
    WHERE mnt_ttc - mnt <> 0
)
SELECT 
    num_0,
    sta_0,
    dat,
    mtc_0,
    jou_0,
    acc_0,
    racine,
    tiers,
    nomclt,
    categ,
    MNT,
    date_ech,
    des_0,
    CASE 
        WHEN accnum_0 <> 0 THEN MNT - NVL((SELECT SUM(payloc_0) FROM gaccdudate WHERE gaccdudate.accnum_0 = etape1.accnum_0), 0) * SNS_0
        ELSE solde 
    END AS solde,
    SNS_0,
    accnum_0,
    impaye
FROM etape1