SELECT 
    a.stofcy_0,
    a.ypiece_0,
    a.ydatdem_0,

    (SELECT nomusr_0 
     FROM autilis 
     WHERE usr_0 = a.ydem_0) AS demandeur,

    b.ybpcnum_0 AS client,

    (SELECT bpcnam_0 
     FROM bpcustomer ra 
     WHERE bpcnum_0 = b.ybpcnum_0) AS nomclient,

    itmref_0,

    (SELECT des1axx_0 
     FROM itmmaster r 
     WHERE r.itmref_0 = b.itmref_0) AS des,

    yqtedem_0 AS qtedemande,
    yqtysor_0 AS qteconsomme,

    a.ydatval_0 AS datevalidite,
    a.ydatdeb_0 AS datedebvalid,
    a.ydatfin_0 AS datefinvalid,
    a.yperval_0 AS periodevalidite

FROM 
    ydemstkh a,
    ydemstkd b

WHERE 
    a.ypiece_0 = b.ypiece_0
    AND a.ysign_0 = 2
    AND yqtedem_0 - yqtysor_0 <> 0