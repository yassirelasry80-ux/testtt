SELECT 
    aa.num_0,
    bb.bpr_0,
    aa.bprvcr_0,
    aa.accdat_0,
    bb.acc_0,
    bb.amtled_0,
    bb.mtc_0  
FROM 
    gaccentry aa,
    gaccentryd bb 
WHERE 
    aa.typ_0 = bb.typ_0 
    AND aa.num_0 = bb.num_0  
    AND aa.typ_0 = 'IMP' 
    AND aa.accdat_0 BETWEEN '01/01/' || '2016' AND '31/12/' || '2021' 
    AND bb.acc_0 = '34210000'  
    AND (
        SELECT f.rennotpay_0 
        FROM paymenth f 
        WHERE f.num_0 = aa.bprvcr_0
    ) = 20