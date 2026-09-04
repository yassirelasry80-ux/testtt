WITH projet_agg AS (
    SELECT sdhnum_0, bpcord_0, MAX(axeproj_0) AS max_axeproj
    FROM xprojet
    GROUP BY sdhnum_0, bpcord_0
),
itmbps_agg AS (
    SELECT 
        itmref_0,
        MAX(bpsnum_0) AS max_frs,
        MAX(CASE WHEN bpsnum_0 = '208' THEN 'OUI' END) AS has_208
    FROM itmbps
    GROUP BY itmref_0
),
bom_agg AS (
    SELECT itmref_0, 'OUI' AS is_artf
    FROM bom
    GROUP BY itmref_0
),
raw_data AS (
    SELECT 
        CASE 
            WHEN NVL(TRIM(DECODE(SUBSTR(x.gte_0,1,1), 'F', y.sdhnum_0, 'A', y.srhnum_0)), ' ') = ' ' THEN 'FORFAIT'
            ELSE DECODE(SUBSTR(x.gte_0,1,1), 'F', y.sdhnum_0, 'A', y.srhnum_0)
        END AS piece_raw,
        
        x.num_0 AS fac,
        DECODE(SUBSTR(x.bpr_0,1,1), 'X','C', 'Y','C', 'Z','C', SUBSTR(x.bpr_0,1,1)) AS agence,
        x.accdat_0 AS date_fac,
        x.bpr_0 AS tiers,
        y.itmref_0 AS article,
        y.itmdes1_0 AS lib_art_fac,
        y.tsicod_0 AS FC,
        y.tsicod_1 AS FT,
        y.tsicod_2 AS FD,
        
        t.xfc_0 AS fcmkt,
        t.xfclib_0 AS fclibmkt,
        t.xfT_0 AS ftmkt,
        t.xfTlib_0 AS ftlibmkt,
        t.xfD_0 AS fdmkt,
        t.xfDlib_0 AS fdlibmkt,
        
        y.gropri_0 AS tarif,
        DECODE(SUBSTR(x.gte_0,1,1), 'F', y.qty_0, 'A', y.qty_0 * -1) AS qte,
        DECODE(SUBSTR(x.gte_0,1,1), 'F', (y.qty_0 * y.netpri_0 * x.ratmlt_0), 'A', (y.qty_0 * y.netpri_0 * x.ratmlt_0) * -1) AS HTN,
        DECODE(SUBSTR(x.gte_0,1,1), 'F', (y.qty_0 * y.gropri_0 * x.ratmlt_0), 'A', (y.qty_0 * y.gropri_0 * x.ratmlt_0) * -1) AS HTB,
        SUBSTR(x.bpr_0,2,1) AS categ,
        
        p_agg.max_axeproj AS proj_base,
        
        CASE 
            WHEN SUBSTR(x.bpr_0,2,1) = 'U' THEN 'APPEL OFFRE'
            ELSE 
                DECODE(
                    p_agg.max_axeproj,
                    NULL, 'DISTRIBUTION',
                    DECODE(SUBSTR(p_agg.max_axeproj, 2, 1), 'U', 'APPEL OFFRE', 'MARCHE PRIVE')
                )
        END AS canal_base,
        
        NVL(ib_agg.has_208, 'NON') AS sicda,
        NVL(b_agg.is_artf, 'NON') AS artf,
        ib_agg.max_frs AS frs,
        bps.bpsnam_0 AS lib_frs2,
        f.xclasse_0 AS xclasse,
        
        DECODE(SUBSTR(x.gte_0,1,1), 'F', dl.dlvdat_0, 'A', rt.rtndat_0) AS date_piece_raw
        
    FROM sinvoice x
    JOIN sinvoiced y ON x.num_0 = y.num_0
    LEFT JOIN itmmaster t ON t.itmref_0 = y.itmref_0
    LEFT JOIN projet_agg p_agg ON p_agg.sdhnum_0 = DECODE(SUBSTR(x.gte_0,1,1), 'F', y.sdhnum_0, 'A', y.srhnum_0) AND p_agg.bpcord_0 = x.bpr_0
    LEFT JOIN itmbps_agg ib_agg ON ib_agg.itmref_0 = y.itmref_0
    LEFT JOIN bpsupplier bps ON bps.bpsnum_0 = ib_agg.max_frs
    LEFT JOIN bom_agg b_agg ON b_agg.itmref_0 = y.itmref_0
    LEFT JOIN bpcustomer f ON f.bpcnum_0 = x.bpr_0
    LEFT JOIN sdelivery dl ON dl.sdhnum_0 = y.sdhnum_0
    LEFT JOIN sreturn rt ON rt.srhnum_0 = y.srhnum_0
    WHERE x.accdat_0 BETWEEN '01/01/2020' AND '31/12/2026'
      AND x.gte_0 <> 'AFV'
),
propagated_data AS (
    SELECT 
        r.*,
        CASE 
            WHEN r.piece_raw = 'FORFAIT' THEN MAX(CASE WHEN r.piece_raw <> 'FORFAIT' THEN r.proj_base END) OVER (PARTITION BY r.fac)
            ELSE r.proj_base
        END AS proj_final,
        
        CASE 
            WHEN r.piece_raw = 'FORFAIT' THEN MAX(CASE WHEN r.piece_raw <> 'FORFAIT' THEN r.canal_base END) OVER (PARTITION BY r.fac)
            ELSE r.canal_base
        END AS canal_propagated
    FROM raw_data r
)
SELECT 
    TRIM(p.piece_raw) AS piece,
    CASE 
        WHEN p.piece_raw = 'FORFAIT' THEN p.date_fac
        ELSE p.date_piece_raw
    END AS date_piece,
    TRIM(p.fac) AS fac,
    TRIM(p.agence) AS agence,
    p.date_fac,
    TRIM(p.tiers) AS tiers,
    TRIM(p.article) AS article,
    TRIM(p.lib_art_fac) AS lib_art_fac,
    TRIM(p.FC) AS FC,
    TRIM(p.FT) AS FT,
    TRIM(p.FD) AS FD,
    
    TRIM(NVL(p.fcmkt, ' ')) AS fcmkt,
    TRIM(NVL(p.fclibmkt, ' ')) AS fclibmkt,
    TRIM(NVL(p.ftmkt, ' ')) AS ftmkt,
    TRIM(NVL(p.ftlibmkt, ' ')) AS ftlibmkt,
    TRIM(NVL(p.fdmkt, ' ')) AS fdmkt,
    TRIM(NVL(p.fdlibmkt, ' ')) AS fdlibmkt,
    
    p.tarif,
    p.qte,
    p.HTN,
    p.HTB,
    TRIM(p.categ) AS categ,
    TRIM(NVL(p.proj_final, ' ')) AS proj,

    CASE 
        WHEN TRIM(p.proj_final) = 'RRRR' THEN 'SOLAIRE'
        WHEN p.xclasse = '1' THEN 'GRAND COMPTE'
        WHEN p.xclasse = '2' THEN 'PARTICULIER'
        ELSE TRIM(p.canal_propagated)
    END AS canal,
    
    TRIM(p.sicda) AS sicda,
    TRIM(NVL(p.artf, ' ')) AS artf,
    TRIM(NVL(p.frs, ' ')) AS frs,
    TRIM(NVL(p.lib_frs2, ' ')) AS lib_frs2,
    TRIM(p.xclasse) AS xclasse
FROM propagated_data p