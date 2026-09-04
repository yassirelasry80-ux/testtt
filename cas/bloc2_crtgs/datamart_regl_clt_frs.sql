WITH filtered_payments AS (
    SELECT /*+ MATERIALIZE */
        num_0, bpr_0, bpanam_0, ban_0, des_0, cur_0, 
        amtcur_0, amtban_0, sta_0, accdat_0, duddat_0, 
        oridat_0, valdat_0, bildat_0, pab1_0, credat_0,    
        crynam_0, ref_0, bprsac_0, accnumtre_2, accnumtre_8
    FROM paymenth
    WHERE accdat_0 BETWEEN TO_DATE('01/06/2026', 'DD/MM/YYYY') AND TO_DATE('01/07/2026', 'DD/MM/YYYY')
      AND num_0 NOT LIKE 'G%' 
      AND num_0 NOT LIKE 'FPRL%' 
      AND bprsac_0 <> 'FDOU'
),
acc_mapping AS (
    SELECT accnum_0, MIN(num_0) AS num_0
    FROM gaccentryd
    WHERE ledtyp_0 = 1
    GROUP BY accnum_0
),
entry_bounds AS (
    SELECT 
        m.accnum_0,
        m.num_0,
        MIN(d.acc_0) AS cpt_min,
        MAX(d.acc_0) AS cpt_max
    FROM acc_mapping m
    JOIN gaccentryd d ON d.num_0 = m.num_0 AND d.ledtyp_0 = 1
    GROUP BY m.accnum_0, m.num_0
)
SELECT 
    p.num_0, p.bpr_0, p.bpanam_0, p.ban_0, p.des_0, p.cur_0, 
    p.amtcur_0, p.amtban_0, p.sta_0, p.accdat_0, p.duddat_0 AS date_ech, 
    p.oridat_0, p.duddat_0, p.valdat_0, p.bildat_0, p.pab1_0, p.credat_0,    
    p.crynam_0, p.ref_0, p.bprsac_0,
    DECODE(p.bprsac_0, 'C1', 'CLIENT', 'FOURNISSEURS') AS tiers,
    p.accnumtre_2,
    d2.num_0 AS PF,
    d2.cpt_min AS cpt_min_pf,
    d2.cpt_max AS cpt_max_pf,
    p.accnumtre_8,
    d8.num_0 AS bnq,
    d8.cpt_min AS cpt_min_bnq,
    d8.cpt_max AS cpt_max_bnq 
FROM filtered_payments p
LEFT JOIN entry_bounds d2 ON d2.accnum_0 = p.accnumtre_2
LEFT JOIN entry_bounds d8 ON d8.accnum_0 = p.accnumtre_8