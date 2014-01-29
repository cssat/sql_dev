select year(inf.inv_ass_start) * 100 + month(inf.inv_ass_start)			
,sum(case when fl_reopen_case=0 then 1 else 0 end) as cnt_referrals			
,sum(case when cd_access_type in (1,4) and cd_final_decision=1 then 1 else 0 end) as cnt_cps_sI			
,sum(case when cd_final_decision=1 then (fl_cps_invs) else 0 end )as cnt_cps_inv			
,cps_invs_completed			
from base.tbl_intakes inf			
left join (select year(inv_ass_stop) * 100 + month(inv_ass_stop) as yrmo			
			,count(distinct ID_INVESTIGATION_ASSESSMENT_FACT) as cps_invs_completed
			from base.tbl_intakes 
			where --and rfrd_date between '9/1/2010' and '9/30/2010' 
			 year(inv_ass_stop) * 100 + month(inv_ass_stop)
			  between 201009 and 201206 and fl_cps_invs=1
			group by year(inv_ass_stop) * 100 + month(inv_ass_stop)
			
			) q on q.yrmo=year(inf.inv_ass_start) * 100 + month(inf.inv_ass_start)
where year(inf.inv_ass_start) * 100 + month(inf.inv_ass_start) between 201009 and 201206 			
and inf.fl_reopen_case=0 			
group by year(inf.inv_ass_start) * 100 + month(inf.inv_ass_start),cps_invs_completed			
order by year(inf.inv_ass_start) * 100 + month(inf.inv_ass_start)			
