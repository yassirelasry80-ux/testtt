select ll.bpr_0,DMP(ll.bpr_0,'31/12/2025') dmp from (select distinct bpr_0 from balance where fiy_0 between 3 and 6 and acc_0='34210000' and substr(bpr_0,2,1)='R') ll
