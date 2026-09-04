SELECT 
    a.num_0,
    a.bpr_0,
    a.accdat_0,
    CASE WHEN a.num_0 LIKE 'A%' THEN a.amtnot_0 * -1 ELSE a.amtnot_0 END as ht,
    CASE WHEN a.num_0 LIKE 'A%' THEN a.amtati_0 * -1 ELSE a.amtati_0 END as ttc,
    CASE WHEN a.num_0 LIKE 'A%' THEN (a.amtati_0 - a.amtnot_0) * -1 ELSE (a.amtati_0 - a.amtnot_0) END as tva
FROM sinvoice a 
WHERE a.accdat_0 > TO_DATE('01/01/2010', 'DD/MM/YYYY')
  AND a.amtnot_0 > 0 
  AND a.sta_0 <> 3