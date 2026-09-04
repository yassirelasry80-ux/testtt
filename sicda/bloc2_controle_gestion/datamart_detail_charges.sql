SELECT /*+ MONITOR Dynamic_sampling(4) */
    a.typ_0,
    a.num_0,
    a.jou_0,
    a.accdat_0,
    TO_CHAR(a.accdat_0, 'YYMM') AS AAMM,
    a.fcy_0,
    b.acc_0,
    b.sns_0,
    b.amtled_0,
    b.sns_0 * b.amtled_0 AS mnt,
    b.acc_0 AS cpt,
    b.bpr_0 AS tiers,
    SUBSTR(b.acc_0, 1, 4) AS racine_cpt1,
    SUBSTR(b.acc_0, 1, 4) AS racine_cpt2,
    SUBSTR(b.acc_0, 7, 2) AS code_ag,
    DECODE(a.typ_0, 'SMG', 
        DECODE(SUBSTR(u.max_cce, 8, 2),
            '02','AGC','03','AGA','04','AGM','05','AGB','06','AGN',
            '08','AGL','09','AGK','10','AGS','11','AGJ','13','AGR',
            '14','AGO','96','ATM','97','ATZ','98','ATT','99','AGU',
            '01','AGP','00','SIG','15','DIV'
        ),
        dm.codecc
    ) AS codecc,
    b.chk_0,
    b.offacc_0,
    DECODE(a.typ_0, 'ENC', enc.max_doper, dec.max_opedat) AS date_oper,
    a.duddat_0 AS dech,
    b.des_0 AS lib_ecr,
    a.rvs_0 AS extourne
FROM gaccentry a
INNER JOIN gaccentryd b 
    ON a.typ_0 = b.typ_0 
   AND a.num_0 = b.num_0
LEFT JOIN (
    SELECT num_0, typ_0, lin_0, acc_0, accnum_0, MAX(cce_0) AS max_cce
    FROM gaccentrya
    WHERE typ_0 = 'SMG'
    GROUP BY num_0, typ_0, lin_0, acc_0, accnum_0
) u ON a.typ_0 = 'SMG' 
   AND u.num_0 = a.num_0 
   AND u.typ_0 = a.typ_0 
   AND u.lin_0 = b.lin_0 
   AND u.acc_0 = b.acc_0 
   AND u.accnum_0 = b.accnum_0
LEFT JOIN (
    SELECT code_ag, MAX(codecc) AS codecc 
    FROM datamart_centrec 
    GROUP BY code_ag
) dm ON a.typ_0 <> 'SMG' AND dm.code_ag = SUBSTR(b.acc_0, 7, 2)
LEFT JOIN (
    SELECT numreg, MAX(doper) AS max_doper 
    FROM v_caenc_2019_materialise 
    GROUP BY numreg
) enc ON a.typ_0 = 'ENC' AND enc.numreg = a.bprvcr_0
LEFT JOIN (
    SELECT num_0, MAX(opedat_0) AS max_opedat 
    FROM v_cadec_2019_materialise 
    GROUP BY num_0
) dec ON a.typ_0 <> 'ENC' AND dec.num_0 = a.bprvcr_0
WHERE a.typ_0 <> 'ODM'
  AND b.ledtyp_0 = 1
  AND a.accdat_0 BETWEEN TO_DATE('01/01/2018', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
  AND a.fcy_0 = 'SIG'
  AND (
      EXISTS (SELECT 1 FROM datamart_R4_cpt_Charges r WHERE r.racine_cpt1 = SUBSTR(b.acc_0, 1, 4))
      OR 
      EXISTS (SELECT 1 FROM datamart_R4_cpt_Charges r WHERE r.racine_cpt1 = SUBSTR(b.acc_0, 1, 3))
  );