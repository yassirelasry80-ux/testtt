WITH g AS (
    SELECT accnum_0, num_0, acc_0, ledtyp_0
    FROM gaccentryd
),
g_led1 AS (
    SELECT accnum_0, num_0
    FROM g
    WHERE ledtyp_0 = 1
),
g_stats AS (
    SELECT 
        num_0,
        MIN(acc_0) AS min_acc,
        MAX(acc_0) AS max_acc
    FROM g
    WHERE ledtyp_0 = 1
    GROUP BY num_0
)
SELECT 
    p.num_0,
    p.bpr_0,
    p.bpanam_0,
    p.ban_0,
    p.des_0,
    p.cur_0,
    p.amtcur_0,
    p.amtban_0,
    p.sta_0,
    p.accdat_0,
    p.duddat_0 AS date_ech,
    p.oridat_0,
    p.duddat_0,
    p.valdat_0,
    p.bildat_0,
    p.pab1_0,
    p.credat_0,
    p.crynam_0,
    p.ref_0,
    p.bprsac_0,

    DECODE(p.bprsac_0, 'C1', 'CLIENT', 'FOURNISSEURS') AS tiers,

    p.accnumtre_2,
    pf.num_0 AS pf,

    pfst.min_acc AS cpt_min_pf,
    pfst.max_acc AS cpt_max_pf,

    p.accnumtre_8,
    bnq.num_0 AS bnq,

    bnqst.min_acc AS cpt_min_bnq,
    bnqst.max_acc AS cpt_max_bnq

FROM paymenth p

LEFT JOIN g_led1 pf
    ON pf.accnum_0 = p.accnumtre_2

LEFT JOIN g_stats pfst
    ON pfst.num_0 = pf.num_0

LEFT JOIN g_led1 bnq
    ON bnq.accnum_0 = p.accnumtre_8

LEFT JOIN g_stats bnqst
    ON bnqst.num_0 = bnq.num_0

WHERE p.accdat_0 BETWEEN TO_DATE('01/01/2019','DD/MM/YYYY')
                     AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND p.num_0 NOT LIKE 'G%'
  AND p.num_0 NOT LIKE 'FPRL%'
  AND p.bprsac_0 <> 'FDOU'