

create procedure prtl.prod_build_rate_care_day_maltreatment
as 
insert into  prtl.rate_care_day_maltreatment(date_type,qry_type,fiscal_yr,county_cd
	,care_days,cnt_incidents,care_day_finding_rate)
select  0 date_type,2 qry_type
			, cd.fiscal_yr
			, cd.county_cd
			, sum(care_days) care_days
			, coalesce(cnt_abuse,0) cnt_abuse
			, IIF( sum(care_days) >0,cnt_abuse /(sum(care_days) * 1.00000000) * 100000,null)  [care_day_finding_rate]
 from base.placement_care_days_mobility  cd
 left join (select distinct 0 date_type
							,2 qry_type
							,cd.sfy  fiscal_yr
							,count(distinct abse.ID_ABUSE_FACT) as cnt_abuse
							,county_cd
					from   (
							select id_case,child,removal_dt, iif(rp.[18bday] < rp.discharge_dt and rp.[18bday]<cutoff_date
											,rp.[18bday]
											,rp.discharge_dt)  discharge_dt,cnty.cd_cnty county_cd
								from base.rptPlacement rp 
								join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
								join prm_cnty cnty on cnty.match_code=rp.removal_county_cd
								where  age_at_removal_mos< (18*12)  and max_bin_los_cd>=1
								) q 
							join abuse_fact abse on abse.ID_PRSN_VCTM=q.child
								and coalesce(dbo.IntDate_to_CalDate(id_calendar_dim_incident),'1900-01-01')  between dateadd(dd,7,q.removal_dt) and q.discharge_dt
							join (select STATE_FISCAL_YYYY sfy,min(calendar_date) fy_start,max(calendar_date) fy_stop
									from CALENDAR_DIM cd
									where cd.STATE_FISCAL_YYYY between 2000 and 2013
									group by cd.state_fiscal_yyyy) cd on IIF(id_calendar_dim_incident>0,convert(datetime,convert(varchar,abse.id_calendar_dim_incident),112),'1900-01-01') between fy_start and fy_stop
							group by cd.sfy,county_cd
					  ) malt on cd.fiscal_yr=malt.fiscal_yr 
					  and cd.county_cd=malt.county_cd
 where age_yrs_exit=-99 and age_yrs_removal=-99 
 and cd_race=0 and exclude_7day=1 and exclude_trh=0 
 group by cd.fiscal_yr,cd.county_cd ,cnt_abuse
 order by cd.county_cd,fiscal_yr

 
