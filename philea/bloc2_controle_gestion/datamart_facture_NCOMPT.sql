select 
    a.num_0,a.bpr_0,a.accdat_0,decode(substr(a.num_0,1,1),'A',a.amtnot_0*-1,a.amtnot_0) ht,decode(substr(a.num_0,1,1),'A',a.amtati_0*-1,a.amtati_0) ttc,
    decode(substr(a.num_0,1,1),'A',(a.amtati_0-a.amtnot_0)*-1,(a.amtati_0-a.amtnot_0)) tva 
from sinvoice a 
where a.accdat_0 > TO_DATE('01/01/2010','DD/MM/YYYY') and a.amtnot_0 > 0 and a.sta_0<>3