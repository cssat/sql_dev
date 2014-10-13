
--  exec prtl.prod_build_rate_care_day_maltreatment
alter procedure prtl.prod_build_rate_care_day_maltreatment
as 

declare @fystart int = 2000
declare @fystop int = 2013
truncate table  prtl.rate_care_day_maltreatment;
insert into  prtl.rate_care_day_maltreatment(date_type,qry_type,fiscal_yr,county_cd
	,care_days,cnt_incidents,care_day_finding_rate)
select  0 date_type,2 qry_type
			, cd.fiscal_yr
			, cd.county_cd
			, sum(care_days) care_days
			, coalesce(cnt_abuse,0) cnt_abuse
			, IIF( sum(care_days) >0,coalesce(cnt_abuse,0) /(sum(care_days) * 1.00000000) * 100000,null)  [care_day_finding_rate]
 from base.placement_care_days_mobility  cd
 left join (select distinct 0 date_type
							,2 qry_type
							,cd.sfy  fiscal_yr
							,count(distinct abse.ID_ABUSE_FACT) as cnt_abuse
							,county_cd
					from   (
							select id_case,child,removal_dt,rp.id_removal_episode_fact
							, iif(rp.[18bday] < rp.discharge_dt and rp.[18bday]<cutoff_date
											,rp.[18bday]
											,rp.discharge_dt)  discharge_dt,cnty.cd_cnty county_cd
								from base.rptPlacement rp 
								join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
								join prm_cnty cnty on cnty.match_code=rp.removal_county_cd
								where  age_at_removal_mos< (18*12)  and max_bin_los_cd>=1
								) q 
							join abuse_fact abse on abse.ID_PRSN_VCTM=q.child
								and IIF(id_calendar_dim_incident>0,convert(datetime,convert(varchar,abse.id_calendar_dim_incident),112),'1900-01-01')   between dateadd(dd,7,q.removal_dt) and q.discharge_dt
								and not exists (select id_prsn from vw_nondcfs_combine_adjacent_segments nd where nd.id_prsn=abse.ID_PRSN_VCTM 
										and  IIF(id_calendar_dim_incident>0,convert(datetime,convert(varchar,abse.id_calendar_dim_incident),112),'1900-01-01') between nd.cust_begin and nd.cust_end)
								and not exists(select evt.ID_REMOVAL_EPISODE_FACT from base.WRK_TRHEvents evt where  evt.id_removal_episode_fact= q.id_removal_episode_fact
										and   IIF(id_calendar_dim_incident>0,convert(datetime,convert(varchar,abse.id_calendar_dim_incident),112),'1900-01-01')  between evt.TRH_begin and evt.TRH_End)
							join (select STATE_FISCAL_YYYY sfy,min(calendar_date) fy_start,max(calendar_date) fy_stop
									from CALENDAR_DIM cd
									where cd.STATE_FISCAL_YYYY between @fystart and @fystop
									group by cd.state_fiscal_yyyy) cd on IIF(id_calendar_dim_incident>0,convert(datetime,convert(varchar,abse.id_calendar_dim_incident),112),'1900-01-01') between fy_start and fy_stop
							group by cd.sfy,county_cd
					  ) malt on cd.fiscal_yr=malt.fiscal_yr 
					  and cd.county_cd=malt.county_cd
 where age_yrs_exit=-99 and age_yrs_removal=-99  and cd_race=0 
 and exclude_7day=1 and exclude_trh=1  and exclude_nondcfs=1
 group by cd.fiscal_yr,cd.county_cd ,cnt_abuse
 order by cd.county_cd,fiscal_yr


--  select * from prtl.rate_care_day_maltreatment m where county_cd=0 order by m.fiscal_yr
