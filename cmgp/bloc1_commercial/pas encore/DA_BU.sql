WITH 
-- Agrégats analytiques par document (élimine 6 sous-requêtes scalaires répétées)
cpa AS (
    SELECT 
        vcrnum_0,
        MAX(cce_1) AS proj_analyt,
        MAX(cce_2) AS vehicule_analyt,
        MAX(cce_3) AS sal_analyt
    FROM cptanalin
    GROUP BY vcrnum_0
),

-- Articles min/max par demande d'achat (élimine 4 sous-requêtes scalaires répétées)
art AS (
    SELECT
        pshnum_0,
        MIN(itmref_0) AS min_art,
        MAX(itmref_0) AS max_art
    FROM prequisd
    GROUP BY pshnum_0
),

-- Libellés des articles min et max (jointure sur prequisd une seule fois)
art_lib AS (
    SELECT
        a.pshnum_0,
        MAX(CASE WHEN r.itmref_0 = a.min_art THEN r.itmdes1_0 END) AS lib_art1,
        MAX(CASE WHEN r.itmref_0 = a.max_art THEN r.itmdes1_0 END) AS lib_art2
    FROM art a
    JOIN prequisd r ON r.pshnum_0 = a.pshnum_0
                   AND r.itmref_0 IN (a.min_art, a.max_art)
    GROUP BY a.pshnum_0
),

-- Business Lines min/max article (élimine 4 sous-requêtes scalaires imbriquées)
bline AS (
    SELECT
        a.pshnum_0,
        MAX(CASE WHEN im.itmref_0 = a.min_art THEN im.xbusline_0 END) AS busline_min,
        MAX(CASE WHEN im.itmref_0 = a.max_art THEN im.xbusline_0 END) AS busline_max
    FROM art a
    JOIN itmmaster im ON im.itmref_0 IN (a.min_art, a.max_art)
    GROUP BY a.pshnum_0
)

SELECT
    p.xstrnum_0,

    -- Décodage type DA (CASE ANSI à la place de DECODE propriétaire Oracle)
    CASE p.xstrnum_0
        WHEN 'DAI' THEN 'Ach Rev Import'
        WHEN 'DAN' THEN 'Ach Netafim'
        WHEN 'DAT' THEN 'Ach N/Rev Atelier'
        WHEN 'DGP' THEN 'Ach N/Rev Groupe'
        WHEN 'DNC' THEN 'Ach N/Rev Constr Soi/Même'
        WHEN 'DNR' THEN 'Ach N/Rev'
        WHEN 'DRA' THEN 'Ach Rev Atelier'
        WHEN 'DRC' THEN 'Ach Rev Constr P/C Client'
        WHEN 'IMM' THEN 'Ach N/Rev Immobilisé'
        WHEN 'SIC' THEN 'Ach Marchandise sicda'
        WHEN 'STD' THEN 'Ach Rev Local'
    END                             AS type_DA,

    p.pshnum_0,
    p.pshfcy_0,
    f.fcynam_0                      AS lib_site,
    p.requsr_0,
    u.nomusr_0                      AS nom,
    p.prqdat_0,
    p.xaffect_0,
    p.xclient_0,
    p.yun_0,
    yu.libunit_0                    AS lib_UN,

    CASE p.xtypproj_0
        WHEN 1 THEN 'AppelOffre'
        WHEN 2 THEN 'MarchéPrivé'
        WHEN 3 THEN 'Stock'
        WHEN 4 THEN 'AutreClients'
        WHEN 5 THEN 'CONSTRUCTION'
    END                             AS typ,

    -- Données analytiques issues du CTE cpa
    cpa.proj_analyt,
    cpa.vehicule_analyt,
    cv.des_0                        AS nom_vehicule,
    cpa.sal_analyt,

    -- BU/Service salarié
    sb.BU || ' ' || sb.Service      AS BU_SU,
    cs.des_0                        AS nom_sal,

    -- Business Lines
    atx1.texte_0                    AS BLine1,
    atx2.texte_0                    AS BLine2,

    -- Articles min/max
    ar.min_art,
    al.lib_art1,
    ar.max_art,
    al.lib_art2

FROM prequis p

-- Site
LEFT OUTER JOIN facility f
    ON f.fcy_0 = p.pshfcy_0

-- Utilisateur demandeur
LEFT OUTER JOIN autilis u
    ON u.usr_0 = p.requsr_0

-- Unité
LEFT OUTER JOIN yunit yu
    ON yu.yun_0 = p.yun_0

-- Axes analytiques (CTE : 1 accès au lieu de 6)
LEFT OUTER JOIN cpa
    ON cpa.vcrnum_0 = p.pshnum_0

-- Véhicule analytique (axe AX3)
LEFT OUTER JOIN cacce cv
    ON cv.die_0 = 'AX3'
   AND cv.cce_0 = cpa.vehicule_analyt

-- Salarié analytique (axe AX4)
LEFT OUTER JOIN cacce cs
    ON cs.die_0 = 'AX4'
   AND cs.cce_0 = cpa.sal_analyt

-- Salarié BU/Service
LEFT OUTER JOIN salarie_bu sb
    ON sb.axe_sal = cpa.sal_analyt

-- Articles min/max (CTE : 1 accès au lieu de 4)
LEFT OUTER JOIN art ar
    ON ar.pshnum_0 = p.pshnum_0

-- Libellés articles (CTE)
LEFT OUTER JOIN art_lib al
    ON al.pshnum_0 = p.pshnum_0

-- Business Lines (CTE)
LEFT OUTER JOIN bline bl
    ON bl.pshnum_0 = p.pshnum_0

-- BLine1 : texte pour l'article MIN
LEFT OUTER JOIN atextra atx1
    ON atx1.codfic_0 LIKE 'ATA%'
   AND atx1.ident1_0 = 6012
   AND atx1.langue_0 = 'FRA'
   AND atx1.zone_0   = 'LNGDES'
   AND atx1.ident2_0 = bl.busline_min

-- BLine2 : texte pour l'article MAX
LEFT OUTER JOIN atextra atx2
    ON atx2.codfic_0 LIKE 'ATA%'
   AND atx2.ident1_0 = 6012
   AND atx2.langue_0 = 'FRA'
   AND atx2.zone_0   = 'LNGDES'
   AND atx2.ident2_0 = bl.busline_max

WHERE p.prqdat_0 BETWEEN :date_debut AND :date_fin

ORDER BY
    type_DA,
    p.xstrnum_0,
    p.requsr_0