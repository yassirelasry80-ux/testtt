-- ============================================================
-- PARAMÈTRES DYNAMIQUES (Bind Variables Python)
--   :date_debut  → ex: '01/01/2024'
--   :date_fin    → ex: '31/12/2024'
-- ============================================================
WITH

-- CTE 1 : Dernière facture valide par ligne de réception
-- Élimine la double sous-requête scalaire répétée (cpr + ratmlt_0)
inv_line AS (
    SELECT
        ii.pthnum_0,
        ii.ptdlin_0,
        i.ratmlt_0,
        ii.cpr_0        AS cpr
    FROM   pinvoiced ii
    JOIN   pinvoice  i  ON i.num_0 = ii.num_0
    WHERE  i.xdanum_0 <> ' '
),

-- CTE 2 : Taux de change MAD courant par devise
-- Évite le full scan répété de TABCHANGE avec la double sous-requête MAX
taux_change AS (
    SELECT
        t.cur_0,
        t.chgrat_0
    FROM   tabchange t
    WHERE  t.curden_0  = 'MAD'
      AND  t.chgtyp_0  = 1
      AND  t.chgstrdat_0 = (
               SELECT MAX(t2.chgstrdat_0)
               FROM   tabchange t2
               WHERE  t2.cur_0    = t.cur_0
                 AND  t2.curden_0 = 'MAD'
                 AND  t2.chgtyp_0 = 1
           )
),

-- CTE 3 : Cumul CPR2 par réception / article
-- Remplace la sous-requête scalaire avec 4 tables imbriquées
cpr2_agg AS (
    SELECT
        pa.pthnum_0,
        pa.itmref_0,
        SUM(p2.cpr_0) AS cpr2
    FROM       preceiptd  pa
    JOIN       pinvoiced  p1  ON  pa.pthnum_0 = p1.numori_0
                               AND pa.ptdlin_0  = p1.linori_0
                               AND pa.itmref_0  = p1.itmref_0
    JOIN       pinvoice   xx  ON  p1.num_0      = xx.num_0
    JOIN       pinvoiced  p2  ON  p1.num_0      = p2.numori_0
                               AND p1.pidlin_0   = p2.pidlin_0
    GROUP BY   pa.pthnum_0, pa.itmref_0
)

-- ============================================================
-- REQUÊTE PRINCIPALE
-- ============================================================
SELECT
    p.pthnum_0,
    p.rcpdat_0,
    p.itmref_0,
    p.ptdlin_0                                              AS lin,
    p.itmdes1_0,
    p.qtypuu_0,

    -- Prix net commande fournisseur
    oo.netpri_0,

    -- Données prix révisé / devise
    kk.xprirev_0,
    kk.mltcur_0,

    -- CPR facture (null si aucune facture valide)
    il.cpr                                                  AS cpr,

    -- Cumul CPR2
    ca.cpr2,

    -- Taux de change :
    --   si ratmlt_0 est null → taux TABCHANGE courant
    --   sinon → ratmlt_0 de la facture
    DECODE(
        il.ratmlt_0,
        NULL, tc.chgrat_0,
        il.ratmlt_0
    )                                                       AS ratcur

FROM       preceiptd  p

-- Jointure commande fournisseur (ancienne syntaxe (+) → LEFT JOIN)
LEFT JOIN  porderp    oo ON  oo.pohnum_0 = p.pohnum_0
                          AND oo.poplin_0  = p.poplin_0
                          AND oo.popseq_0  = p.poqseq_0

-- Jointure ligne commande interne (ancienne syntaxe (+) → LEFT JOIN)
LEFT JOIN  xgpohlin   k  ON  k.pthnum_0  = p.pthnum_0
                          AND k.ptdlin_0   = p.ptdlin_0

-- Jointure prix révisé (ancienne syntaxe (+) → LEFT JOIN)
LEFT JOIN  xgdetpri   kk ON  kk.itmref_0 = k.itmref_0
                          AND kk.xdanum_0  = k.xdanum_0

-- CTE facture (remplace 2 sous-requêtes scalaires identiques)
LEFT JOIN  inv_line   il ON  il.pthnum_0 = p.pthnum_0
                          AND il.ptdlin_0  = p.ptdlin_0

-- CTE taux de change courant (jointure sur la devise réseau)
LEFT JOIN  taux_change tc ON  tc.cur_0    = oo.netcur_0

-- CTE cumul CPR2
LEFT JOIN  cpr2_agg   ca ON  ca.pthnum_0 = p.pthnum_0
                          AND ca.itmref_0  = p.itmref_0

WHERE  p.rcpdat_0 BETWEEN :date_debut AND :date_fin
  AND  SUBSTR(p.bpsnum_0, 1, 1) BETWEEN '0' AND '1'
;