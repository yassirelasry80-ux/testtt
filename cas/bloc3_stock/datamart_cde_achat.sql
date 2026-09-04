SELECT 
    a.pohnum_0, 
    a.bpsnum_0, 
    a.pohfcy_0, 
    a.bprnam_0, 
    a.orddat_0, 
    a.rcpflg_0, 
    a.invflg_0, 
    a.ystatus_0, 
    a.xetape_0, 
    a.xetaped2_0, 
    b.itmref_0, 
    b.itmdes1_0, 
    b.netpri_0, 
    b.vat_0, 
    c.qtypuu_0, 
    c.rcpqtypuu_0, 
    c.rcpcleflg_0, 
    a.cur_0, 
    ' ' AS trtime, 
    ' ' AS dateprliv, 
    b.poplin_0, 
    v_da.da_val AS DA, 
    v_da.typ_da AS typ_DA, 
    get_bc_type(a.xstrnum_0) AS type_bc, 
    ' ' AS agence, 
    ' ' AS projet, 
    ' ' AS vehicule, 
    ' ' AS salarie, 
    ca.cce_4 AS centre, 
    ca.cce_5 AS bline, 
    ca.cce_6 AS sites, 
    ca.cce_7 AS entite, 
    ca.cce_8 AS cce8, 
    ca.cce_9 AS cce9, 
    pq.psdlin_0 AS lin_da, 
    CASE WHEN c.lincleflg_0 = 2 THEN 'Oui' ELSE 'Non' END AS solder, -- Qualifié par c. pour éviter l'ambiguïté
    CASE WHEN a.xtype_0 = 'CDI' THEN 'IMPORT' ELSE 'LOCALE' END AS TYPE_CMD 
FROM porder a
JOIN porderp b 
    ON a.pohnum_0 = b.pohnum_0
JOIN porderq c 
    ON a.pohnum_0 = c.pohnum_0 
    AND b.poplin_0 = c.poplin_0 
    AND b.popseq_0 = c.poqseq_0
LEFT JOIN (
    SELECT 
        vcrnum_0, 
        vcrlin_0, 
        MAX(cce_4) AS cce_4, 
        MAX(cce_5) AS cce_5, 
        MAX(cce_6) AS cce_6, 
        MAX(cce_7) AS cce_7, 
        MAX(cce_8) AS cce_8, 
        MAX(cce_9) AS cce_9
    FROM cptanalin
    GROUP BY vcrnum_0, vcrlin_0
) ca 
    ON ca.vcrnum_0 = a.pohnum_0 
    AND ca.vcrlin_0 = b.poplin_0
LEFT JOIN (
    SELECT pohnum_0, poplin_0, MAX(psdlin_0) AS psdlin_0
    FROM prequiso
    GROUP BY pohnum_0, poplin_0
) pq 
    ON pq.pohnum_0 = a.pohnum_0 
    AND pq.poplin_0 = c.poplin_0
LEFT JOIN (
    SELECT DISTINCT 
        pohnum_val AS pohnum_0, 
        da_val, 
        get_da_type(l.xstrnum_0) AS typ_da
    FROM (
        SELECT DISTINCT a_sub.pohnum_0 AS pohnum_val, get_DA(a_sub.pohnum_0) AS da_val
        FROM porder a_sub
        WHERE a_sub.orddat_0 >= TO_DATE('01/11/2025', 'DD/MM/YYYY') 
          AND a_sub.betfcy_0 <> 2
    ) sub_da
    LEFT JOIN prequis l ON l.pshnum_0 = sub_da.da_val
) v_da 
    ON v_da.pohnum_0 = a.pohnum_0
WHERE a.orddat_0 >= TO_DATE('01/11/2025', 'DD/MM/YYYY') 
  AND a.betfcy_0 <> 2