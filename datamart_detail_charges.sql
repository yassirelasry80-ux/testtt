SELECT
    a.typ_0,
    a.num_0,
    a.jou_0,
    a.accdat_0,
    TO_CHAR(a.accdat_0, 'YYMM') AAMM,
    a.fcy_0,
    b.acc_0,
    b.sns_0,
    b.amtled_0,
    b.sns_0 * b.amtled_0 mnt,
    b.acc_0 cpt,
    b.bpr_0 tiers,
    SUBSTR(b.acc_0, 1, 4) racine_cpt1,
    SUBSTR(b.acc_0, 1, 4) racine_cpt2,
    SUBSTR(b.acc_0, 7, 2) code_ag,

    DECODE(
        a.typ_0,
        'SMG',
            (
                SELECT DECODE(
                    SUBSTR(MAX(cce_0), 8, 2),
                    '02','AGC','03','AGA','04','AGM','05','AGB','06','AGN',
                    '08','AGL','09','AGK','10','AGS','11','AGJ','13','AGR',
                    '14','AGO','96','ATM','97','ATZ','98','ATT','99','AGU',
                    '01','AGP','00','SIG','15','DIV'
                )
                FROM gaccentrya u
                WHERE u.num_0 = a.num_0
                  AND u.typ_0 = a.typ_0
                  AND u.lin_0 = b.lin_0
                  AND u.acc_0 = b.acc_0
                  AND u.accnum_0 = b.accnum_0
            ),
            (
                SELECT codecc
                FROM datamart_centrec
                WHERE code_ag = SUBSTR(b.acc_0, 7, 2)
            )
    ) codecc,

    b.chk_0,
    b.offacc_0,

    DECODE(
        a.typ_0,
        'ENC',
            (
                SELECT MAX(doper)
                FROM v_caenc_2019 k
                WHERE k.numreg = a.bprvcr_0
            ),
            (
                SELECT MAX(opedat_0)
                FROM v_cadec_2019 k
                WHERE k.num_0 = a.bprvcr_0
            )
    ) date_oper,

    a.duddat_0 dech,
    b.des_0 lib_ecr,
    a.rvs_0 extourne

FROM gaccentry a,
     gaccentryd b

WHERE a.typ_0 = b.typ_0
  AND a.num_0 = b.num_0
  AND a.typ_0 <> 'ODM'
  AND b.ledtyp_0 = 1
  AND a.accdat_0 BETWEEN TO_DATE('01/01/2018','DD/MM/YYYY')  AND TO_DATE('31/12/2026','DD/MM/YYYY')
  AND (
        SUBSTR(b.acc_0, 1, 4) IN (
            SELECT racine_cpt1
            FROM datamart_R4_cpt_Charges
        )
        OR SUBSTR(b.acc_0, 1, 3) IN (
            SELECT racine_cpt1
            FROM datamart_R4_cpt_Charges
        )
      )
  AND a.fcy_0 = 'SIG'