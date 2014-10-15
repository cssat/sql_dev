/**
Of all children in foster care during a 12-month period,what is the rate of victimization
 per day of foster care? 5 
The indicator includes all cases of substantiated or indicated maltreatment while in foster 
care and all days for all children in foster care at any point during a 12-month period. 

The denominator is all child days in foster care over a 12-month period, 
and the numerator is the number of instances of substantiated or indicated maltreatment among children 
in foster care over that same period. The definition of ‘‘children’’ for this indicator (and all indicators) 
includes those under the age of 18. This indicator includes all maltreatment types by any perpetrator, which may include foster parents, facility staff
 members, parents, or others. In addition, this indicator includes all days for all children in foster care at any point during a 12- month period. 
Some states provide incident dates in their NCANDS data submissions. If a state provides incident dates, records with an incident date occurring before the 
date of removal will be excluded. Children in foster care for less than 8 days 
and any report that occurs within the first 7 days of removal are excluded from 
this indicator. This indicator is calculated using data that match Almost all states report AFCARS identifiers in the NCANDS data. For those states that do 
not, a Children’s Bureau-approved alternate source will be required to assess performance on this indicator. 7 See Drake, Jonson-Reid, Way, & Chung (2003). 
Substantiation and Recidivism. Child Maltreatment. Vol. 8, No. 4, 248–260.
children across AFCARS and NCANDS
**/
--  exec prtl.prod_build_rate_care_day_maltreatment
alter procedure prtl.prod_build_rate_care_day_maltreatment
as 

declare @fystart int = 2000
declare @fystop int = 2013
truncate table  prtl.rate_care_day_maltreatment;
insert into  prtl.rate_care_day_maltreatment(date_type,qry_type,fiscal_yr,county_cd
	,care_days,cnt_incidents,care_day_incident_rate)
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
							,count(distinct q.id_removal_episode_fact) as cnt_abuse
							,county_cd
					from   (
									select rp.id_case,rp.child,rp.removal_dt,rp.id_removal_episode_fact
											, iif(rp.[18bday] < rp.discharge_dt and rp.[18bday]<cutoff_date
											,rp.[18bday]
											,rp.discharge_dt)  discharge_dt
											,cnty.cd_cnty county_cd
											,rp.begin_date
											,rp.end_date
											,plc.[18bday]
								from base.rptPlacement_Events rp 
								join base.rptPlacement plc on plc.id_removal_episode_fact=rp.id_removal_episode_fact
								join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
								join prm_cnty cnty on cnty.match_code=rp.derived_county -- county location of child placement
								where  rp.begin_date<plc.[18bday] -- child is less than 18
										and plc.max_bin_los_cd>=1 -- episode at least 8 days long
								) q 
							join INTAKE_VICTIM_FACT ivf  on ivf.ID_PRSN_VCTM=q.child
							join prtl.vw_referrals_grp intk on intk.ID_INTAKE_FACT=ivf.ID_INTAKE_FACT
							and convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121))
									between dateadd(dd,7,removal_dt) and discharge_dt
							and convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121))
									between q.begin_date and q.end_date
							-- child is less than 18 years old
							and convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121)) < q.[18bday]
							and intk.cd_final_decision=1 -- screened in 
							and intk.fl_founded_any_legal=1  -- substantiated
							join (select STATE_FISCAL_YYYY sfy,min(calendar_date) fy_start,max(calendar_date) fy_stop
									from CALENDAR_DIM cd
									where cd.STATE_FISCAL_YYYY between @fystart and @fystop
									group by cd.state_fiscal_yyyy) cd 
										on convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121))
												between fy_start and fy_stop
							where  not exists (select id_prsn from vw_nondcfs_combine_adjacent_segments nd where nd.id_prsn=ivf.ID_PRSN_VCTM 
										and convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121))
												between nd.cust_begin and nd.cust_end)
								and not exists(select evt.ID_REMOVAL_EPISODE_FACT from base.WRK_TRHEvents evt where  evt.id_removal_episode_fact= q.id_removal_episode_fact
										and  convert(datetime,convert(varchar(10),isnull(grp_rfrd_date,rfrd_date),121))
												between evt.TRH_begin and evt.TRH_End)
								group by cd.sfy,county_cd
					  ) malt on cd.fiscal_yr=malt.fiscal_yr 
					  and cd.county_cd=malt.county_cd
	 where age_yrs_exit=-99 and age_yrs_removal=-99  and cd_race=0 
	 and exclude_7day=1 and exclude_trh=1  and exclude_nondcfs=1
	 group by cd.fiscal_yr,cd.county_cd ,cnt_abuse
	 order by cd.county_cd,fiscal_yr


 ---select * from prtl.rate_care_day_maltreatment where county_cd=0  order by fiscal_yr
