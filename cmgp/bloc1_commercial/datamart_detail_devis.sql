select 
    a.numdev,
    (
        select agence 
        from betude.commercial 
        where nom || ' ' || codec = a.commercial  
          and etat = 'A'
    ) agence,
    a.commercial, 

    decode(
        a.etat,
        '1', 'A En Cours',
        '2', 'C Perdu',
        '4', 'D Pas Intéressé',
        '5', 'B Décroché',
        '3', 'F Variantes Périmées',
        '6', 'E En Cours Périmé',
        '8', 'G Décroché Périmé',
        a.etat
    ) etat,

    a.totalttcnet,
    to_char(date_maj_etat,'dd/mm/yyyy') date_maj_etat,
    clientadonix,
    a.nom,
    a.libelle,
    a.date_creation,
    substr(a.numdev,1,7) || substr(a.numdev,9,23) racine,
    a.etat_prospect,
    a.date_prospect,
    a.classification,
    a.niveau_chaud 

from betude.e_devis a,
     betude.commercial cc 

where cc.nom || ' ' || cc.codec = a.commercial
  and cc.etat = 'A'
  and a.numdev is not null
  and substr(a.agence,2,1) = 'B'
  and a.etat in ('1','2','4','6')
  and substr(a.numdev,40,1) <> 'S'
  and substr(a.numdev,1,8) <> 'Devis-NT'
  AND a.date_creation BETWEEN TO_DATE('01/01/2020','DD/MM/YYYY')
                   AND TO_DATE('31/12/2026','DD/MM/YYYY')
  and a.totalttcnet <> 0
  and a.commercial not like 'RECONV%'
  and a.numdev not like '%TST%'

union

select 
    p.numdev,
    (
        select agence 
        from betude.commercial 
        where nom || ' ' || codec = p.commercial  
          and etat = 'A'
    ) agence,
    p.commercial,

    decode(
        p.etat,
        '1', 'A En Cours',
        '2', 'C Perdu',
        '4', 'D Pas Intéressé',
        '5', 'B Décroché',
        '3', 'F Variantes Périmées',
        '6', 'E En Cours Périmé',
        '8', 'G Décroché Périmé',
        p.etat
    ) etat,

    TOTALTTCNET,
    to_char(p.date_maj_etat,'dd/mm/yyyy') date_maj,
    p.clientadonix,
    p.nom,
    p.libelle,
    p.date_creation,
    substr(p.numdev,1,7) || substr(p.numdev,9,23) racine,
    p.etat_prospect,
    p.date_prospect,
    p.classification,
    p.niveau_chaud 

from betude.e_devis p 

where substr(p.numdev,1,8) <> 'Devis-NT'
  and p.etat = 5
  and p.date_creation BETWEEN TO_DATE('01/01/2024','DD/MM/YYYY')
                   AND TO_DATE('31/12/2024','DD/MM/YYYY')
  and TOTALTTCNET <> 0
  and p.commercial not like 'RECONV%'
  and p.numdev not like '%TST%'
  and (
        (
            substr(p.numdev, 39, 2) = '..'
        )
        or
        (
            (
                p.numdev = substr(p.numdev, 1, 38) || '/S' || substr(p.numdev, 41, length(p.numdev) - 40)
                and (
                    substr(p.numdev, 1, 32) || '..'
                ) not in (
                    select substr(z.numdev, 1, 32) || '..'
                    from betude.e_devis z
                    where z.numdev <> p.numdev
                      and substr(z.numdev,1,8) <> 'Devis-NT'
                      and z.etat = 5
                )
            )
        )
  )