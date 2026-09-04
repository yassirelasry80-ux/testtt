SELECT 
    iptdat_0, vcrnum_0, vcrtyp_0, vcrlin_0, vcrnumori_0, 
    vcrlinori_0, stofcy_0, itmref_0, qtypcu_0, priord_0, bprnum_0 
FROM stojou 
WHERE iptdat_0 >= TO_DATE('01/01/2022', 'DD/MM/YYYY') 
  AND iptdat_0 <= TO_DATE('31/12/2026', 'DD/MM/YYYY')
  AND itmref_0 NOT LIKE 'C%'