SELECT 
    aa.accdat_0 AS Dfac,
    aa.num_0 AS Nfac,
    aa.bpr_0 AS Frs,
    oo.bpsnam_0 AS nom,
    kk.pthnum_0 AS NumRec,
    kk.pnhnum_0 AS NumRet,
    u.rcpdat_0 AS date_Rec,
    t.rtndat_0 AS date_ret,
    kk.itmref_0 AS CodeArt,
    kk.itmdes1_0 AS Designation,
    l.cry_0 AS Pays,
    kk.qtypuu_0 AS Qté,
    kk.netpri_0 AS PUHT,
    (NVL(kk.amttaxlin1_0, 0) + NVL(kk.amttaxlin2_0, 0)) AS tva,
    kk.amtatilin_0 AS TTC,
    aa.cur_0,
    aa.ratmlt_0 AS cours
FROM pinvoice aa
JOIN pinvoiced kk 
    ON aa.num_0 = kk.num_0
LEFT JOIN bpsupplier oo 
    ON oo.bpsnum_0 = aa.bpr_0
LEFT JOIN preceipt u 
    ON u.pthnum_0 = kk.pthnum_0
LEFT JOIN preturn t 
    ON t.pnhnum_0 = kk.pnhnum_0
LEFT JOIN bpartner l 
    ON l.bprnum_0 = aa.bpr_0
WHERE aa.accdat_0 BETWEEN TO_DATE('01/01/2023', 'DD/MM/YYYY') AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
  AND aa.fcy_0 <> 'FR'
  AND kk.qtypuu_0 <> 0