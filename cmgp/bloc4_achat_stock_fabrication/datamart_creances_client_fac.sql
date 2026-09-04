SELECT
    c1.jou_0,

    DECODE(SUBSTR(c1.typ_0,1,1),
           'F','FACTURE',
           'A','FACTURE',
           'V','FACTURE',
           'I','IMPAYE',
           'REGLEMENT NON LETTRE') typ,

    c.bpr_0 code,

    b.bpcnam_0 nom,

    c1.num_0 num,
    c1.accdat_0 dat,
    c.acc_0 compte,

    c.amtled_0 * c.sns_0 mnt_ttc,

    NVL(p.mntpaye,0) mntpaye,

    (c.amtled_0 * c.sns_0) - NVL(p.mntpaye,0) mntrestapaye,

    c.mtc_0 lettrage

FROM gaccentry c1

INNER JOIN gaccentryd c
       ON c1.typ_0 = c.typ_0
      AND c1.num_0 = c.num_0

LEFT JOIN bpcustomer b
       ON b.bpcnum_0 = c.bpr_0

LEFT JOIN (
        SELECT
            num_0,
            bpr_0,
            lig_0,
            SUM(payloc_0 * sns_0) mntpaye
        FROM gaccdudate
        GROUP BY
            num_0,
            bpr_0,
            lig_0
) p
       ON p.num_0 = c.num_0
      AND p.bpr_0 = c.bpr_0
      AND p.lig_0 = c.lin_0

WHERE c.acc_0 = '34210000'
  AND c1.typ_0 <> 'RAN'
  AND c1.accdat_0 >= TO_DATE('01/01/2008','DD/MM/YYYY')
  AND c1.jou_0 = 'VT'