drop table bi_xprojet
/
create table bi_xprojet as select distinct sdhnum_0,bpcord_0,sohnum_0,axeproj_0,cusquoref_0,(select distinct date_depot from suivinst.i_projet where projet_analytique=axeproj_0 and rownum=1) date_cloture from xprojet where axeproj_0 is not null
/

begin 
    betude.DATAMART_SYNC;
    betude.datamart_sync_R;
     betude.datamart_sync_TE;
     betude.datamart_sync_p;
end;
/
begin
betude.datamart_sync2;
end;
/
drop table datamart_affaire
/
drop table datamart_affaire_R
/
drop table datamart_affaire_TE
/
create table datamart_affaire as select * from betude.datamart_affaire
/
create table datamart_affaire_R as select * from betude.datamart_affaire_R
/
create table datamart_affaire_TE as select * from betude.datamart_affaire_TE
/
drop table datamart_affaire2
/
create table datamart_affaire2 as select * from betude.datamart_affaire2
/
drop table datamart_affaire_P
/
create table  datamart_affaire_P as select * from betude.datamart_affaire_P
/
exit
/