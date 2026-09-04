SELECT 
    ll.bpr_0,
    (SELECT DMP(ll.bpr_0, '31/12/2023') FROM dual) AS dmp
FROM (
    SELECT bpr_0 
    FROM balance 
    WHERE acc_0 = '34210000' 
      AND fiy_0 BETWEEN 10 AND 14 
      AND bpr_0 LIKE 'D%'
    GROUP BY bpr_0
) ll