SELECT 
    t.bpcnum_0,
    t.BPCNAM_0,
    t.BCGCOD_0,
    t.rep_0,
    t.YANCCOD_0,
    t.YANCPT_0,
    t.YSITE_0 
FROM 
    bpcustomer t 
WHERE 
    LENGTH(t.bpcnum_0) > 5