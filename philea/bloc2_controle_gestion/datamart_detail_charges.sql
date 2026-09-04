SELECT
    a.typ_0,
    a.num_0,
    a.jou_0,
    a.accdat_0,
    TO_CHAR(a.accdat_0, 'YYMM') AS aamm,
    a.fcy_0,
    b.acc_0,
    b.sns_0,
    b.amtled_0,
    b.sns_0 * b.amtled_0 AS mnt,
    b.acc_0 AS cpt,
    b.bpr_0 AS tiers,
    SUBSTR(b.acc_0,1,4) AS racine_cpt1,
    SUBSTR(b.acc_0,1,4) AS racine_cpt2,
    SUBSTR(b.acc_0,7,2) AS code_ag,

    CASE
        WHEN a.typ_0 = 'SMG' THEN
            (
                SELECT DECODE(
                           SUBSTR(MAX(u.cce_0),8,2),
                           '02','AGC',
                           '03','AGA',
                           '04','AGM',
                           '05','AGB',
                           '06','AGN',
                           '08','AGL',
                           '09','AGK',
                           '10','AGS',
                           '11','AGJ',
                           '13','AGR',
                           '14','AGO',
                           '96','ATM',
                           '97','ATZ',
                           '98','ATT',
                           '99','AGU',
                           '01','AGP',
                           '00','SIG',
                           '15','DIV'
                       )
                FROM gaccentrya u
                WHERE u.num_0     = a.num_0
                  AND u.typ_0     = a.typ_0
                  AND u.lin_0     = b.lin_0
                  AND u.acc_0     = b.acc_0
                  AND u.accnum_0  = b.accnum_0
                  AND u.ledtyp_0  = 2
            )
        ELSE
            (
                SELECT d.codecc
                FROM datamart_centrec d
                WHERE d.code_ag = SUBSTR(b.acc_0,7,2)
            )
    END AS codecc,

    b.chk_0,
    b.offacc_0,
    TO_DATE('31/12/1955','DD/MM/YYYY') AS date_oper,
    a.duddat_0 AS dech,
    b.des_0 AS lib_ecr,
    a.rvs_0 AS extourne

FROM gaccentry  a
JOIN gaccentryd b
    ON a.typ_0 = b.typ_0
   AND a.num_0 = b.num_0

WHERE a.typ_0 <> 'ODM'
  AND a.accdat_0 BETWEEN DATE '2018-01-01' AND DATE '2026-12-31'
  AND a.fcy_0 = 'SIG'
  AND b.ledtyp_0 = 1
  AND (
        EXISTS (
            SELECT 1
            FROM datamart_R4_cpt_Charges c
            WHERE c.racine_cpt1 = SUBSTR(b.acc_0,1,4)
        )
        OR EXISTS (
            SELECT 1
            FROM datamart_R4_cpt_Charges c
            WHERE c.racine_cpt1 = SUBSTR(b.acc_0,1,3)
        )
      )