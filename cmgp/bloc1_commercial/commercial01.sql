SELECT /*+ 
           LEADING(a b c t r)
           USE_HASH(b c t r)
           FULL(a)
           FULL(b)
           FULL(c)
           PARALLEL(a 4)
           PARALLEL(b 4)
           PARALLEL(c 4)
           PARALLEL(t 4)
           PARALLEL(r 4)
        */
       a.sohnum_0 AS cde,

       DECODE(LENGTH(a.bpcord_0), 6, SUBSTR(a.bpcord_0, 1, 1), SUBSTR(a.bpcord_0, 7, 1)) AS agence,

       a.orddat_0 AS date_BC,
       a.bpcord_0 AS tiers,

       b.itmref_0  AS Article,
       b.itmdes1_0 AS lib_art_cde,
       b.tsicod_0  AS FC,
       b.tsicod_1  AS FT,
       b.tsicod_2  AS FD,

       ' '         AS FCMKT,
       ' '         AS FCLIBMKT,
       ' '         AS FTMKT,
       ' '         AS FTLIBMKT,
       ' '         AS FDMKT,
       ' '         AS xfDlib_0, 
       ' '         AS FDLIBMKT,

       b.gropri_0 *
       DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1) AS tarif,

       c.qty_0 AS qte,

       (
           c.qty_0 * b.netpri_0 *
           DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1)
       ) AS HTN,

       (
           c.qty_0 * b.gropri_0 *
           DECODE(r.cur_0, 'MAD', 1, 'EUR', 10.82, 'USD', 9.26, 1)
       ) AS HTB,

       SUBSTR(r.ysauv_clt_0, 2, 1) AS categ,

       frs.frs,

       b.soplin_0,
       b.sopseq_0,
       b.sqhnum_0,
       b.sqdlin_0,
       c.dlvqty_0,
       t.xbusline_0,
       
       CASE 
           WHEN b.SOQSTA_0 = 3 THEN 'Oui' 
           ELSE 'Non' 
       END AS solde

FROM sorder a

JOIN sorderp b
     ON a.sohnum_0 = b.sohnum_0

JOIN sorderq c
     ON c.sohnum_0 = b.sohnum_0
    AND c.soplin_0 = b.soplin_0

JOIN itmmaster t
     ON t.itmref_0 = b.itmref_0

JOIN bpcustomer r
     ON r.bpcnum_0 = a.bpcord_0

LEFT JOIN (
        SELECT /*+ MATERIALIZE */
               itmref_0,
               MAX(bpsnum_0) AS frs
        FROM itmbps
        GROUP BY itmref_0
) frs
       ON frs.itmref_0 = b.itmref_0

WHERE a.sohnum_0 LIKE 'C%'
  AND a.orddat_0 BETWEEN TO_DATE('01/01/2020', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')