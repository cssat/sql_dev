SELECT        fiscal_yr,  SUM(care_days) AS care_days, SUM(ISNULL(placement_moves, 0)) AS placement_moves, SUM(ISNULL(kin_cnt, 0)) AS kin_moves, 
                         SUM(ISNULL(foster_cnt, 0)) AS foster_moves, SUM(ISNULL(group_cnt, 0)) AS group_moves, SUM(ISNULL(placement_moves, 0)) * 1000.0 / SUM(care_days) 
                         AS placement_mobility, SUM(ISNULL(foster_cnt, 0)) * 1000.0 / SUM(care_days) AS placement_mobility_to_foster, SUM(ISNULL(kin_cnt, 0)) * 1000.0 / SUM(care_days) 
                         AS placement_mobility_to_kin, SUM(ISNULL(group_cnt, 0)) * 1000.0 / SUM(care_days) AS placement_mobility_to_group
FROM            base.placement_care_days_mobility
WHERE        (exclude_7day = 0) AND (exclude_trh = 0) AND (age_yrs_exit = - 99) AND (age_yrs_removal = - 99) 
AND (county_cd = 0) AND (cd_race = 0) 
and years_in_care=0
GROUP BY fiscal_yr
order by fiscal_yr

	select  
		fy_start_date
						,sum(DATEDIFF(d
         , iif(  begin_date < fy_start_date, fy_start_date , begin_date  )
         , iif( isnull(end_date , '9999-01-01')  > fy_stop_date , fy_stop_date 
		 , end_date)
           ) + 1 ) n_care_days
		,sum(iif(plcmnt_seq > 1 and begin_date between fy_start_date and fy_stop_date,1,0)) placement_moves
	from (select state_fiscal_yyyy sfy,min(calendar_date) fy_start_date,max(calendar_date) fy_stop_date from calendar_dim where state_fiscal_yyyy between 2012 and 2012 group by state_fiscal_yyyy) cd
			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			join ca_ods.base.rptPlacement_Events rp 
					on removal_dt <= cd.fy_stop_date
			and  iif(dbo.lessorDate( [18bday],rp.discharge_dt) > cutoff_date
				, cutoff_date
				,dbo.lessorDate( [18bday],rp.discharge_dt))  >=cd.fy_start_date
			and rp.begin_date<= cd.fy_stop_date
			and coalesce(rp.end_date,'12/31/3999') >=cd.fy_start_date
		--	and rp.derived_county=17
where dbo.fnc_datediff_yrs(rp.removal_dt, iif(begin_date<fy_start_date,fy_start_date,begin_date))=0
group by fy_start_date,sfy

drop table #temp
	select  *,DATEDIFF(d
         , iif(  begin_date < fy_start_date, fy_start_date , begin_date  )
         , iif( isnull(end_date , '9999-01-01')  > fy_stop_date , fy_stop_date 
		 , end_date)
           ) + 1  n_care_days
	, iif(isnull((select  top 1 calendar_date from calendar_dim where state_fiscal_yyyy=cd.sfy and month(removal_dt)=month(calendar_date) and day(removal_dt)=day(calendar_date)),'9999-12-31')<>'9999-12-31'
					 ,(select  top 1 calendar_date from calendar_dim where state_fiscal_yyyy=cd.sfy and month(removal_dt)=month(calendar_date) and day(removal_dt)=day(calendar_date))
					,(select top 1 calendar_date from calendar_dim where state_fiscal_yyyy=cd.sfy  and month(calendar_date)=2 and day(calendar_date)=28) 
					) anniv_removal_dt
		into #temp
	from (select state_fiscal_yyyy sfy,min(calendar_date) fy_start_date,max(calendar_date) fy_stop_date from calendar_dim where state_fiscal_yyyy between 2012 and 2012 group by state_fiscal_yyyy) cd
			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			join ca_ods.base.rptPlacement_Events rp 
					on removal_dt <= cd.fy_stop_date
			and  iif(dbo.lessorDate( [18bday],rp.discharge_dt) > cutoff_date
				, cutoff_date
				,dbo.lessorDate( [18bday],rp.discharge_dt))  >=cd.fy_start_date
			and rp.begin_date<= cd.fy_stop_date
			and coalesce(rp.end_date,'12/31/3999') >=cd.fy_start_date
		--	and rp.derived_county=17
where dbo.fnc_datediff_yrs(rp.removal_dt, iif(begin_date<fy_start_date,fy_start_date,begin_date))=0

SELECT        fiscal_yr,  SUM(care_days) AS care_days, SUM(ISNULL(placement_moves, 0)) AS placement_moves, SUM(ISNULL(kin_cnt, 0)) AS kin_moves, 
                         SUM(ISNULL(foster_cnt, 0)) AS foster_moves, SUM(ISNULL(group_cnt, 0)) AS group_moves, SUM(ISNULL(placement_moves, 0)) * 1000.0 / SUM(care_days) 
                         AS placement_mobility, SUM(ISNULL(foster_cnt, 0)) * 1000.0 / SUM(care_days) AS placement_mobility_to_foster, SUM(ISNULL(kin_cnt, 0)) * 1000.0 / SUM(care_days) 
                         AS placement_mobility_to_kin, SUM(ISNULL(group_cnt, 0)) * 1000.0 / SUM(care_days) AS placement_mobility_to_group
FROM            base.placement_care_days_mobility
WHERE        (exclude_7day = 0) AND (exclude_trh = 0) AND (age_yrs_exit = - 99) AND (age_yrs_removal = - 99) 
AND (county_cd = 0) AND (cd_race = 0) 
and years_in_care=0 and fiscal_yr=2012
GROUP BY fiscal_yr
order by fiscal_yr

select   sum(n_care_days)
  from  #temp  where removal_dt between fy_start_date and fy_stop_date
union
select   sum(datediff(d,iif(begin_date<fy_start_date,fy_start_date,begin_date),anniv_removal_dt))
from #temp rp
where not(removal_dt between fy_start_date and fy_stop_date)
and anniv_removal_dt between begin_date and end_date
union 
select   sum(n_care_days)
  from  #temp  where not abs(datediff(d,removal_dt,anniv_removal_dt)) between 0 and 1
  and anniv_removal_dt not between begin_date and end_date