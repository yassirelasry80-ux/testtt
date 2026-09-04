SELECT 
    a.pshnum_0, 
    a.pshfcy_0, 
    a.cleflg_0, 
    a.requsr_0, 
    a.ordflg_0, 
    a.prqdat_0, 
    a.xclient_0, 
    get_da_type(a.XSTRNUM_0) AS XSTRNUM_0, 
    a.XOBSERVATION_0, 
    a.YSTATUS_0, 
    a.YNIV_0, 
    a.credat_0, 
    a.creusr_0, 
    b.itmref_0, 
    b.itmdes1_0, 
    b.gropri_0, 
    b.discrgval1_0, 
    b.netpri_0, 
    b.psdlin_0, 
    b.bpsnum_0, 
    b.qtypuu_0, 
    b.ordqtypuu_0, 
    b.cur_0, 
    b.vat_0, 
    b.vat_1, 
    b.lincleflg_0, 
    b.linordflg_0, 
    b.linappflg_0, 
    l_agg.cce_4 AS centre, 
    l_agg.cce_5 AS bline, 
    l_agg.cce_6 AS site, 
    l_agg.cce_7 AS entite, 
    l_agg.cce_8 AS cce8, 
    l_agg.cce_9 AS cce9, 
    ' ' AS PROJET, 
    ' ' AS VEHICULE, 
    ' ' AS MATRICULE, 
    a.yvalidateur_0 AS validateur 
FROM prequis a
JOIN prequisd b 
    ON a.pshnum_0 = b.pshnum_0
LEFT OUTER JOIN (
    SELECT 
        vcrnum_0, 
        vcrlin_0, 
        MAX(CCE_4) AS cce_4, 
        MAX(CCE_5) AS cce_5, 
        MAX(CCE_6) AS cce_6, 
        MAX(CCE_7) AS cce_7, 
        MAX(CCE_8) AS cce_8, 
        MAX(CCE_9) AS cce_9
    FROM cptanalin
    GROUP BY vcrnum_0, vcrlin_0
) l_agg 
    ON l_agg.vcrnum_0 = a.pshnum_0 
   AND l_agg.vcrlin_0 = b.psdlin_0
WHERE a.prqdat_0 BETWEEN '01/01/2025' AND '31/12/2026'