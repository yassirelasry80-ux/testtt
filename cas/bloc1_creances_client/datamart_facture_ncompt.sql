SELECT 
    a.num_0,
    a.bpr_0,
    a.accdat_0,
    DECODE(a.gte_0, 'AVC', a.amtnot_0 * -1, a.amtnot_0) AS ht,
    DECODE(a.gte_0, 'AVC', a.amtati_0 * -1, a.amtati_0) AS ttc,
    DECODE(a.gte_0, 'AVC', (a.amtati_0 - a.amtnot_0) * -1, (a.amtati_0 - a.amtnot_0)) AS tva 
FROM 
    sinvoice a 
WHERE 
    a.accdat_0 > '01/01/2010' 
    AND a.amtnot_0 > 0 
    AND a.sta_0 <> 3