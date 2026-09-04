
create table datamart_bl_ret_fac as 
select 
CASE
  WHEN substr(x.gte_0,1,1) = 'F'
       AND NULLIF(TRIM(y.sdhnum_0), '') IS NOT NULL
  THEN y.sdhnum_0

  WHEN substr(x.gte_0,1,1) = 'A'
       AND NULLIF(TRIM(y.srhnum_0), '') IS NOT NULL
  THEN y.srhnum_0

  ELSE 'FORFAIT'
END AS piece,
CASE
  WHEN substr(x.gte_0,1,1) = 'F'
       AND NULLIF(TRIM(y.sdhnum_0), '') IS NOT NULL
  THEN (
    select dlvdat_0 from sdelivery where sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0)
  )

  WHEN substr(x.gte_0,1,1) = 'A'
       AND NULLIF(TRIM(y.srhnum_0), '') IS NOT NULL
  THEN (
    select rtndat_0 from sreturn where srhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0)
  )

  ELSE x.accdat_0
END AS date_piece,
x.num_0 fac,decode(substr(x.bpr_0,1,1),'X','C','Y','C','Z','C',substr(x.bpr_0,1,1)) agence, x.accdat_0 date_fac,x.bpr_0 tiers,y.itmref_0 article,y.itmdes1_0 lib_art_fac,y.tsicod_0 FC,y.tsicod_1 FT,y.tsicod_2 FD,
NVL((SELECT t.xfc_0 FROM itmmaster t WHERE t.itmref_0 = y.itmref_0),'            ') AS FCMKT,
NVL((select xfclib_0 from itmmaster t where t.itmref_0=y.itmref_0),'                                                        ') AS FCLIBMKT,
NVL((select xfT_0 from itmmaster t where t.itmref_0=y.itmref_0),'       ') AS FTMKT,
NVL((select xfTlib_0 from itmmaster t where t.itmref_0=y.itmref_0),'                                           ') AS FTLIBMKT,
NVL((select xfD_0 from itmmaster t where t.itmref_0=y.itmref_0),'                ') AS FDMKT,
NVL((select xfD_0 from itmmaster t where t.itmref_0=y.itmref_0),'                                                  ') AS FDLIBMKT,
y.gropri_0 tarif,decode(substr(x.gte_0,1,1),'F',y.qty_0,'A',y.qty_0*-1) qte,
decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.netpri_0*x.ratmlt_0),'A',(y.qty_0*y.netpri_0*x.ratmlt_0)*-1) HTN ,decode(substr(x.gte_0,1,1),'F',(y.qty_0*y.gropri_0*x.ratmlt_0),'A',(y.qty_0*y.gropri_0*x.ratmlt_0)*-1) HTB ,
substr(x.bpr_0,2,1) categ,
CASE
  WHEN (CASE
  WHEN substr(x.gte_0,1,1) = 'F' THEN y.sdhnum_0
  WHEN substr(x.gte_0,1,1) = 'A' THEN y.srhnum_0
  ELSE 'FORFAIT'
END) = 'FORFAIT' THEN
    MAX(
      NVL(
        (SELECT MAX(ii.axeproj_0)
         FROM xprojet ii
         WHERE ii.sdhnum_0 =
               DECODE(SUBSTR(x.gte_0,1,1),
                      'F', y.sdhnum_0,
                      'A', y.srhnum_0)
           AND ii.bpcord_0 = x.bpr_0),
        ' '
      )
    ) OVER (PARTITION BY x.num_0)

  ELSE
    NVL(
      (SELECT MAX(ii.axeproj_0)
       FROM xprojet ii
       WHERE ii.sdhnum_0 =
             DECODE(SUBSTR(x.gte_0,1,1),
                    'F', y.sdhnum_0,
                    'A', y.srhnum_0)
         AND ii.bpcord_0 = x.bpr_0),
      ' '
    )
END AS proj,
CASE

  WHEN (
        SELECT MAX(ii.axeproj_0)
        FROM xprojet ii
        WHERE ii.sdhnum_0 = y.sdhnum_0
          AND ii.bpcord_0 = x.bpr_0
       ) IS NULL
  THEN 'DISTRIBUTION'

  WHEN SUBSTR(
        (SELECT MAX(ii.axeproj_0)
         FROM xprojet ii
         WHERE ii.sdhnum_0 = y.sdhnum_0
           AND ii.bpcord_0 = x.bpr_0),
        2,1
       ) = 'U'
  THEN 'APPEL OFFRE'

  WHEN SUBSTR(
        (SELECT MAX(ii.axeproj_0)
         FROM xprojet ii
         WHERE ii.sdhnum_0 = y.sdhnum_0
           AND ii.bpcord_0 = x.bpr_0),
        2,1
       ) <> 'U'
  THEN 'MARCHE PRIVE'

  WHEN SUBSTR(x.bpr_0,2,1) = 'U'
  THEN 'APPEL OFFRE'

  WHEN x.bpr_0 IN (
        SELECT bpcnum_0
        FROM bpcustomer
        WHERE xclasse_0 = '1'
  )
  THEN 'GRAND COMPTE'

  WHEN x.bpr_0 IN (
        SELECT bpcnum_0
        FROM bpcustomer
        WHERE xclasse_0 = '2'
  )
  THEN 'PARTICULIER'

  WHEN NVL(
        (SELECT MAX(ii.axeproj_0)
         FROM xprojet ii
         WHERE ii.sdhnum_0 =
               DECODE(SUBSTR(x.gte_0,1,1),
                      'F', y.sdhnum_0,
                      'A', y.srhnum_0)
           AND ii.bpcord_0 = x.bpr_0),
        '     '
       ) = 'RRRR'
  THEN 'SOLAIRE'


END AS canal,
decode((select t.itmref_0 from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') sicda,
NVL(decode((select a.itmref_0 from bom a where a.itmref_0=y.itmref_0),null,'NON','OUI'),'        ') AS ARTF,
NVL((select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0),'        ') AS frs,
NVL((select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) ),'                                                ') AS lib_frs2,
(select f.xclasse_0 from bpcustomer f where f.bpcnum_0=x.bpr_0) xclasse  
from sinvoice x,sinvoiced y where x.num_0=y.num_0  and x.accdat_0 between '01/01/2020' and '31/12/2026' and x.gte_0 <> 'AFV'
/




-------------------------------------
update datamart_bl_ret_fac y set 
fcmkt = (select xfc_0 from itmmaster t where t.itmref_0=y.itmref_0),
FCLIBMKT=(select xfclib_0 from itmmaster t where t.itmref_0=y.itmref_0) ,
FTMKT=(select xfT_0 from itmmaster t where t.itmref_0=y.itmref_0) ,
FTLIBMKT=(select xfTlib_0 from itmmaster t where t.itmref_0=y.itmref_0) ,
FDMKT=(select xfD_0 from itmmaster t where t.itmref_0=y.itmref_0) ,
FDLIBMKT=(select xfDlib_0 from itmmaster t where t.itmref_0=y.itmref_0) ,
proj = (select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0) and ii.bpcord_0=x.bpr_0) ,
sicda = decode((select t.itmref_0 from itmbps t where t.itmref_0=y.itmref_0 and t.bpsnum_0='208'),null,'NON',' ','NON','OUI') ,
ARTF = decode((select a.itmref_0 from bom a where a.itmref_0=y.itmref_0),null,'NON','OUI'),
frs = (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0),
lib_frs2 = (select t.bpsnam_0  from bpsupplier t where t.bpsnum_0=  (select max(u.bpsnum_0)  from itmbps u where u.itmref_0=y.itmref_0) )
/

------------------------------------
update datamart_BL_RET_FAC set canal='APPEL OFFRE' where substr(x.bpr_0,2,1)='U'
/
update datamart_bl_ret_fac set canal = 'GRAND COMPTE' where x.bpr_0 in (select bpcnum_0 from bpcustomer where xclasse_0='1')
/
update datamart_bl_ret_fac set canal = 'PARTICULIER' where x.bpr_0 in (select bpcnum_0 from bpcustomer where xclasse_0='2')
/
update datamart_bl_ret_fac set canal = 'SOLAIRE' where NVL((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0) and ii.bpcord_0=x.bpr_0),'     ') = 'RRRR'
/
update datamart_BL_RET_FAC set piece ='FORFAIT' where piece is null or piece=' '
/
update datamart_BL_RET_FAC set date_piece=date_fac where piece='FORFAIT'
/
update datamart_BL_RET_FAC(table actuel) z set z.proj=(select max(u.proj) from datamart_BL_RET_FAC(la table actuel) u where u.fac=z.fac and u.piece<>'FORFAIT' and u.proj is not null),canal=(select max(u.canal) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.canal is not null) where z.piece='FORFAIT' 
/
update datamart_BL_RET_FAC(table actuel) z set z.proj=(select max(NVL((select max( ii.axeproj_0)  from xprojet ii where ii.sdhnum_0=decode(substr(x.gte_0,1,1),'F',y.sdhnum_0,'A',y.srhnum_0) and ii.bpcord_0=x.bpr_0),'     ')) from this qui est en train de secrit  where u.fac=z.fac and u.piece<>'FORFAIT' and u.proj is not null),canal=(select max(u.canal) from datamart_BL_RET_FAC u where u.fac=z.fac and u.piece<>'FORFAIT' and u.canal is not null) where z.piece='FORFAIT' 

commit
/
 

commit
/




