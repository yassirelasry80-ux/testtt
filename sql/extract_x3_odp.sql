SELECT 
    NUM_0,
    ACC_0,
    SNS_0,
    AMTCUR_0,
    CUR_0,
    ACCDAT_0
FROM {entite_name}.gaccentryd
WHERE ACCDAT_0 >= :start_date
  AND ACCDAT_0 <= :end_date
  AND TYP_0 = 'ODP'
  AND LEDTYP_0 = 2
