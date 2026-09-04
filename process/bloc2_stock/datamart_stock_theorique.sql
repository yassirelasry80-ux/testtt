select stofcy_0,to_char(sysdate,'dd/mm/yyyy') dateinv,itmref_0,sum(qtypcu_0) stk 
from stock  
group by stofcy_0,itmref_0