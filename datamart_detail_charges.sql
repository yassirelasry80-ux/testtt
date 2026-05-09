WITH base_data AS (
    SELECT /*+ MATERIALIZE */
        a.typ_0, a.num_0, a.jou_0, a.accdat_0,
        TO_CHAR(a.accdat_0, 'YYMM') AS AAMM,
        a.fcy_0, b.acc_0, b.sns_0, b.amtled_0,
        b.sns_0 * b.amtled_0 AS mnt,
        b.acc_0 AS cpt, b.bpr_0 AS tiers,
        SUBSTR(b.acc_0, 1, 4) AS racine_cpt1,
        SUBSTR(b.acc_0, 1, 4) AS racine_cpt2,
        SUBSTR(b.acc_0, 7, 2) AS code_ag,
        b.lin_0, b.accnum_0, a.bprvcr_0,
        b.chk_0, b.offacc_0, a.duddat_0 AS dech,
        b.des_0 AS lib_ecr, a.rvs_0 AS extourne
    FROM gaccentry a
    JOIN gaccentryd b ON a.typ_0 = b.typ_0 AND a.num_0 = b.num_0
    WHERE a.typ_0 <> 'ODM' 
      AND b.ledtyp_0 = 1 
      AND a.accdat_0 BETWEEN TO_DATE('01/01/2018','DD/MM/YYYY') AND TO_DATE('31/12/2026','DD/MM/YYYY')
      AND a.fcy_0 = 'SIG'
      AND (
            SUBSTR(b.acc_0, 1, 4) IN (SELECT racine_cpt1 FROM datamart_R4_cpt_Charges)
            OR SUBSTR(b.acc_0, 1, 3) IN (SELECT racine_cpt1 FROM datamart_R4_cpt_Charges)
          )
)
SELECT 
    bd.typ_0, bd.num_0, bd.jou_0, bd.accdat_0, bd.AAMM, bd.fcy_0, 
    bd.acc_0, bd.sns_0, bd.amtled_0, bd.mnt, bd.cpt, bd.tiers, 
    bd.racine_cpt1, bd.racine_cpt2, bd.code_ag,
    
    DECODE(bd.typ_0, 'SMG', 
        DECODE(SUBSTR(u.max_cce_0, 8, 2), 
            '02','AGC','03','AGA','04','AGM','05','AGB','06','AGN',
            '08','AGL','09','AGK','10','AGS','11','AGJ','13','AGR',
            '14','AGO','96','ATM','97','ATZ','98','ATT','99','AGU',
            '01','AGP','00','SIG','15','DIV'),
        dc.codecc
    ) AS codecc,
    
    bd.chk_0, 
    bd.offacc_0,
    
    DECODE(bd.typ_0, 'ENC', 
        k_enc.max_doper, 
        k_dec.max_opedat_0
    ) AS date_oper,
    
    bd.dech, 
    bd.lib_ecr, 
    bd.extourne
FROM base_data bd
LEFT JOIN (
    SELECT num_0, typ_0, lin_0, acc_0, accnum_0, MAX(cce_0) AS max_cce_0
    FROM gaccentrya
    GROUP BY num_0, typ_0, lin_0, acc_0, accnum_0
) u ON bd.typ_0 = 'SMG' AND u.num_0 = bd.num_0 AND u.typ_0 = bd.typ_0 AND u.lin_0 = bd.lin_0 AND u.acc_0 = bd.acc_0 AND u.accnum_0 = bd.accnum_0
LEFT JOIN datamart_centrec dc ON bd.typ_0 <> 'SMG' AND dc.code_ag = bd.code_ag
LEFT JOIN (
    SELECT numreg, MAX(doper) AS max_doper
    FROM v_caenc_2019
    GROUP BY numreg
) k_enc ON bd.typ_0 = 'ENC' AND k_enc.numreg = bd.bprvcr_0
LEFT JOIN (
    SELECT num_0, MAX(opedat_0) AS max_opedat_0
    FROM v_cadec_2019
    GROUP BY num_0
) k_dec ON bd.typ_0 <> 'ENC' AND k_dec.num_0 = bd.bprvcr_0