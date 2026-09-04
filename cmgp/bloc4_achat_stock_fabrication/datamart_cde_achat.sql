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
    xtratime_0        AS trtime,
    xdelini_0         AS dateprliv,
    b.poplin_0,

    DECODE(
        a.cur_0,
        'MAD',
            DECODE(
                a.bpsnum_0,
                '208',
                'SICDA',
                (SELECT MAX(pshnum_0)
                 FROM prequiso k
                 WHERE k.pohnum_0 = a.pohnum_0)
            ),
        get_da(a.pohnum_0, ' ', '1', b.itmref_0)
    ) AS DA,

    (
        SELECT MAX(xstrnum_0)
        FROM prequis l
        WHERE l.pshnum_0 = DECODE(
            a.cur_0,
            'MAD',
                DECODE(
                    a.bpsnum_0,
                    '208',
                    'SICDA',
                    (SELECT MAX(pshnum_0)
                     FROM prequiso k
                     WHERE k.pohnum_0 = a.pohnum_0)
                ),
            get_da(a.pohnum_0, ' ', '1', b.itmref_0)
        )
    ) AS typ_DA,

    (SELECT MAX(l.CCE_0)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS agence,

    (SELECT MAX(l.CCE_0)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS projet,

    (SELECT MAX(l.CCE_2)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS vehicule,

    (SELECT MAX(l.CCE_3)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS salarie,

    (SELECT MAX(l.CCE_4)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS centre,

    (SELECT MAX(l.CCE_5)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS bline,

    (SELECT MAX(l.CCE_6)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS sites,

    (SELECT MAX(l.CCE_7)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS entite,

    (SELECT MAX(l.CCE_8)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS cce8,

    (SELECT MAX(l.CCE_9)
     FROM cptanalin l
     WHERE l.vcrnum_0 = a.pohnum_0
       AND l.vcrlin_0 = b.poplin_0) AS cce9,

    get_bc_type(xtype_0) AS type_bc,

    (SELECT MAX(PREQUISO.PSDLIN_0)
     FROM PREQUISO
     WHERE PREQUISO.pohnum_0 = a.pohnum_0
       AND PREQUISO.poplin_0 = c.poplin_0) AS lin_da,

    CASE 
        WHEN LINCLEFLG_0 = 2 THEN 'Oui'
        ELSE 'Non'
    END AS solder,

    CASE 
        WHEN xtype_0 = 'CDI' THEN 'IMPORT'
        ELSE 'LOCALE'
    END AS TYPE_CMD

FROM 
    porder a,
    porderp b,
    porderq c

WHERE 
    a.pohnum_0 = b.pohnum_0
    AND a.pohnum_0 = c.pohnum_0
    AND b.poplin_0 = c.poplin_0
    AND b.popseq_0 = c.poqseq_0
    AND a.orddat_0 >= TO_DATE('01/01/2021','DD/MM/YYYY')
    AND betfcy_0 <> 2
