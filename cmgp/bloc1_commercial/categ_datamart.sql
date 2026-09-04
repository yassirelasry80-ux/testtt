SELECT DECODE(bcgcod_0,
              'MULTI', 'MULTI',
              'ASS',   'A',
              'AGENC', 'AGENC',
              'COOP',  'C',
              'DOMA',  'D',
              'MARC',  'M',
              'PART',  'P',
              'REVE',  'R',
              'GROU',  'G',
              'TRANS', 'TRANS',
              'AO',    'U',
              'MKT',   'MKT',
              'RECON', 'S',
              'EXP',   'Z')      AS categ,
       INITCAP(bcgdes_0)         AS lib_categ_client
FROM   bpccateg
WHERE  bcgcod_0 IN ('COOP','DOMA','MARC','PART','REVE','GROU','AO','RECON','EXP')