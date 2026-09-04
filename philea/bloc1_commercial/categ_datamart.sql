SELECT
    CASE bcgcod_0
        WHEN 'COOP'  THEN 'C'
        WHEN 'DOMA'  THEN 'D'
        WHEN 'MARC'  THEN 'M'
        WHEN 'PART'  THEN 'P'
        WHEN 'REVE'  THEN 'R'
        WHEN 'GROU'  THEN 'G'
        WHEN 'AO'    THEN 'U'
        WHEN 'RECON' THEN 'S'
        WHEN 'EXP'   THEN 'Z'
    END AS categ,
    INITCAP(bcgdes_0) AS lib_categ_client
FROM bpccateg
WHERE bcgcod_0 IN (
    'COOP','DOMA','MARC','PART','REVE','GROU','AO','RECON','EXP'
)