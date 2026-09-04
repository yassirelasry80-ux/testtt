WITH r4_charges AS (
    SELECT racine_cpt1 
    FROM datamart_R4_cpt_Charges
),
centrec AS (
    SELECT code_ag, MAX(codecc) AS codecc
    FROM datamart_centrec
    GROUP BY code_ag
)
SELECT /*+ PARALLEL(a, 4) PARALLEL(b, 4) */
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
    DECODE(a.typ_0, 'SMG', 'CAS', cc.codecc) AS codecc,
    b.chk_0,
    b.offacc_0,
    TO_DATE('31/12/1955', 'DD/MM/YYYY') AS date_oper,
    a.duddat_0 AS dech,
    b.des_0 AS lib_ecr,
    a.rvs_0 AS extourne
FROM gaccentry a
JOIN gaccentryd b 
  ON a.typ_0 = b.typ_0 
 AND a.num_0 = b.num_0
LEFT JOIN centrec cc 
  ON cc.code_ag = SUBSTR(b.acc_0, 7, 2)
WHERE a.typ_0 <> 'ODM'
  AND a.accdat_0 BETWEEN TO_Date('01/01/2018', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
  AND a.fcy_0 = 'CAS'
  AND b.ledtyp_0 = 1
  AND EXISTS (
      SELECT 1 FROM r4_charges r 
      WHERE r.racine_cpt1 = SUBSTR(b.acc_0, 1, 4)
         OR r.racine_cpt1 = SUBSTR(b.acc_0, 1, 3)
  )