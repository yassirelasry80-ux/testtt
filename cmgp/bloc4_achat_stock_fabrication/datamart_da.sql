SELECT 
a.pshnum_0,a.pshfcy_0,a.cleflg_0,a.requsr_0,a.ordflg_0,a.prqdat_0,a.xclient_0,a.XANNUL_0,
a.XREVENDU_0,a.XREFUS_0,a.XSOUMIS_0,a.XSTATUS_0,a.XAFFECT_0,a.XHEURE_0,a.XTYPPROJ_0,
a.XLIEU_0,a.XMARCHE_0,a.XDAIMPORT_0,a.YPOHINT_0,a.XETAPE_0,a.XETAPED1_0,a.XETAPED2_0,
a.XSIGNER_0,a.XSOUMIS_1_0,a.XSTATUS_1_0,a.XDAT_SOUMI_0,a.XDAT_VALID_0,a.XUSR_SOUMI_0,
a.XUSR_VALID_0,a.XUSR_SOUMA_0,a.XTCCRGCDE_0,a.XSITEUSINE_0,a.XNOMCONTCT_0,a.XNUMTELE_0,
a.XNUMMATR_0,a.SOUMIUSINE_0,a.XUSINEDIR_0,
get_da_type(a.XSTRNUM_0) XSTRNUM_0,
a.XCDECLT_0,a.XTRAITEMENT_0,a.XHEUREVALID_0,a.XDATESIGN_0,a.XCHRGDA_0,a.YUN_0,a.ZSBU_0,
a.XOBSERVATION_0,a.YSTATUS_0,a.YNIV_0,a.credat_0,a.creusr_0,

b.itmref_0,b.itmdes1_0,b.gropri_0,b.discrgval1_0,b.netpri_0,b.psdlin_0,
b.bpsnum_0,b.qtypuu_0,b.ordqtypuu_0,b.cur_0,b.vat_0,b.vat_1,
b.xtraiter_0,b.lincleflg_0,b.linordflg_0,b.xdaterec_0,b.linappflg_0,
b.xobs_0,b.xvalide_0,

c.agence,c.projet,c.vehicule,c.salarie,c.centre,
c.bline,c.site,c.entite,c.cce8,c.cce9

FROM prequis a
JOIN prequisd b 
  ON a.pshnum_0 = b.pshnum_0

LEFT JOIN (
    SELECT 
        vcrnum_0,
        vcrlin_0,
        MAX(cce_0) agence,
        MAX(cce_1) projet,
        MAX(cce_2) vehicule,
        MAX(cce_3) salarie,
        MAX(cce_4) centre,
        MAX(cce_5) bline,
        MAX(cce_6) site,
        MAX(cce_7) entite,
        MAX(cce_8) cce8,
        MAX(cce_9) cce9
    FROM cptanalin
    GROUP BY vcrnum_0, vcrlin_0
) c
  ON c.vcrnum_0 = a.pshnum_0
 AND c.vcrlin_0 = b.psdlin_0

WHERE a.prqdat_0 BETWEEN 
      TO_DATE('01/01/2025','DD/MM/YYYY')
  AND TO_DATE('31/12/2026','DD/MM/YYYY')