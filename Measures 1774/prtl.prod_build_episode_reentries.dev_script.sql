	declare @date_type int
	declare @cutoff_date datetime
	declare @start_date datetime
	declare @stop_date datetime


	select @start_date=min_date_any,@stop_date=max_date_yr 
	from ref_lookup_max_date where id=9
	select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer;


	if object_ID('tempDB..#eps') is not null drop table #eps


	select distinct  cohort_exit_year 
				, 2 as date_type, 0 as qry_type, tce.id_prsn_child, id_removal_episode_fact
				, cd_discharge_type, first_removal_dt [first_removal_date], fl_first_removal
				, removal_dt as state_custody_start_date, federal_discharge_date, orig_federal_discharge_date
				, exit_cdc_census_mix_age_cd as age_grouping_cd, tce.pk_gndr, tce.cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
				, long_cd_plcm_setng, exit_county_cd, exit_int_match_param_key_cdc_census_mix as int_match_param_key
				, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
				, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
				, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
				, tce.int_filter_service_category filter_service_category
				, filter_service_budget
				, case when nxt_reentry_within_min_month_mult3 = 3 
					then 1 else 0 end prsn_cnt
				, exit_within_month_mult3 [exit_within_min_month_mult3]
				, nxt_reentry_within_min_month_mult3
				, 3 as mnth
				, fl_reentry
				, next_reentry_date [nxt_reentry_date]
				, child_eps_rank_asc [prsn_eps_sort_asc]
				, child_eps_rank_desc [prsn_eps_sort_desc]
				, cast(null as int) as row_num		
				, case when 3 =nxt_reentry_within_min_month_mult3  
					or nxt_reentry_within_min_month_mult3 is null then 1 else 0 end as cohort_count	
	into #eps	
	from prtl.ooh_dcfs_eps tce
	where tce.cd_discharge_type in (1,3,4)
	and cohort_exit_year between @start_date and @stop_date
	and tce.fl_exit_over_17=0
	order by  tce.id_prsn_child,tce.removal_dt

	update eps
	set row_num=q.row_num2
	from #eps eps 
	join (select tce.* ,row_number() over (-- only want one episode per cohort_period
					partition by tce.id_prsn_child,tce.cohort_exit_year
						order by id_prsn_child,cohort_exit_year asc ,state_custody_start_date asc,federal_discharge_date asc) as row_num2
						from #eps tce
						-- order by  tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
						) q on q.id_removal_episode_fact=eps.id_removal_episode_fact and q.state_custody_start_date=eps.state_custody_start_date			
			
			
							
	--only want child in cohort once
	delete from #eps where row_num > 1;
	-- for adoption discharge, and adoptions support get demographic information from people_dim
	if OBJECT_ID('tempDB..#person') is not null drop table #person
	select distinct pd.id_prsn,dt_birth,cd_gndr,cd_race_census
	into #person
	from people_dim pd
	where exists (select * from #eps eps where eps.id_prsn_child=pd.ID_PRSN and pd.IS_CURRENT=1
	and eps.cd_discharge_type=3)
	union 
	select distinct pd.id_prsn,dt_birth,cd_gndr,cd_race_census
	from people_dim pd
	where exists (select * from payment_fact pf
								join SERVICE_TYPE_DIM std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM
								where pf.id_prsn_child=pd.ID_PRSN and pd.IS_CURRENT=1
								and std.cd_srvc in (22,25)	)

if OBJECT_ID('tempDB..#adptn_support') is not null drop table #adptn_support
select distinct pf.id_case,pf.id_prsn_child,prsn_pay.DT_BIRTH,prsn_pay.cd_race_census,prsn_pay.cd_gndr
,(dbo.IntDate_to_CalDate(pf.ID_CALENDAR_DIM_SERVICE_BEGIN)) 	[svc_begin_dt],eps.id_prsn_child as eps_child,eps.federal_discharge_date,eps.id_removal_episode_fact
,cast(null as int) [row_num]
,cast(null as datetime) as nxt_reentry_date
,cast(null as int) as nxt_reentry_within_min_month_mult3
into #adptn_support
from PAYMENT_FACT pf
join SERVICE_TYPE_DIM std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM
join  #eps eps on dbo.IntDate_to_CalDate(pf.ID_CALENDAR_DIM_SERVICE_BEGIN) between eps.Federal_Discharge_Date  and dateadd(dd,90,Federal_Discharge_Date)
			and eps.cd_discharge_type=3
			and nxt_reentry_within_min_month_mult3 is null
join #person prsn_pay on prsn_pay.id_prsn=pf.id_prsn_child  
join #person prsn_eps on prsn_eps.ID_PRSN=eps.id_prsn_child
where prsn_pay.DT_BIRTH=prsn_eps.DT_BIRTH
and prsn_pay.CD_GNDR=prsn_eps.CD_GNDR
and prsn_pay.cd_race_census=prsn_eps.cd_race_census
and std.cd_srvc in (22,25)
order by id_removal_episode_fact
	
update adp
set row_num=sortkey
from #adptn_support  adp join (			
select id_removal_episode_fact,svc_begin_dt,row_number() over (partition by id_removal_episode_fact order by svc_begin_dt asc) [sortkey] from #adptn_support	) q
on q.id_removal_episode_fact=	adp.id_removal_episode_fact and q.svc_begin_dt=adp.svc_begin_dt

delete from #adptn_support where row_num<>1		

update adp
set nxt_reentry_date=q.next_reentry_date,nxt_reentry_within_min_month_mult3= 
			case when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 3 then 3
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 6 then 6
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 9 then 9
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 12 then 12
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 15 then 15
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 18 then 18
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 21then 21
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 24 then 24
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 27 then 27
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 30 then 30
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 33 then 33
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 36 then 36
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 39 then 39
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 42 then 42
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 45 then 45
				 when IIF(day(next_reentry_date)<day(adp.federal_discharge_date), datediff(mm,adp.federal_discharge_date,next_reentry_date) -1,datediff(mm,adp.federal_discharge_date,next_reentry_date)) < 48 then 48
			end
from #adptn_support  adp join (	
select   adp.* ,rpt.removal_dt next_reentry_date,ROW_NUMBER() over ( partition by rpt.child order by removal_dt asc) sortkey
from #adptn_support adp 
join base.rptPlacement rpt on rpt.child=adp.ID_PRSN_CHILD
and rpt.removal_dt > adp.Federal_Discharge_Date) q on q.ID_PRSN_CHILD=adp.ID_PRSN_CHILD
and q.sortkey=1




update eps
set id_prsn_child=adp.id_prsn_child,nxt_reentry_date=adp.nxt_reentry_date,nxt_reentry_within_min_month_mult3=adp.nxt_reentry_within_min_month_mult3
from #eps eps
join #adptn_support adp on adp.id_removal_episode_fact=eps.id_removal_episode_fact
where adp.nxt_reentry_within_min_month_mult3 is not null
			

						


	insert into #eps
	select distinct  cohort_exit_year 
		, 2 as date_type, 0 as qry_type, id_prsn_child, id_removal_episode_fact
		, cd_discharge_type, first_removal_date, fl_first_removal
		, state_custody_start_date, federal_discharge_date, orig_federal_discharge_date
		, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
		, long_cd_plcm_setng, exit_county_cd, int_match_param_key
		, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
		, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
		, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
		, filter_service_category
		, filter_service_budget
		, case when nxt_reentry_within_min_month_mult3 <= n.mnth then 1 else 0 end prsn_cnt
		, exit_within_min_month_mult3
		, nxt_reentry_within_min_month_mult3
		, n.mnth as mnth
		, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
		, row_num
		, case when n.mnth  =nxt_reentry_within_min_month_mult3 then 1 else 0 end as cohort_count
	from #eps
	, (select number * 3 as mnth from numbers where number between 2 and 16) n 



-- insert first removals
	insert into #eps
	select cohort_exit_year 
	, 2 as date_type, 1 as qry_type, id_prsn_child, id_removal_episode_fact
	, cd_discharge_type, first_removal_date, 1 [fl_first_removal]
	, state_custody_start_date, federal_discharge_date, orig_federal_discharge_date
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, exit_county_cd, int_match_param_key as int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, filter_service_category
	, filter_service_budget
	, prsn_cnt,exit_within_min_month_mult3
	, nxt_reentry_within_min_month_mult3
	, mnth
	, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
	, row_num
	, cohort_count
	from #eps
	where state_custody_start_date=first_removal_date

create table base.episode_reentries
(id_prsn_child int,
lop int,
stat int,
discharge_type varchar(20), 
state_fiscal_yyyy int,
non_dcfs_placements int);

insert into base.episode_reentries

select distinct 
	id_prsn_child
	,datediff(dd, federal_discharge_date, isnull(nxt_reentry_date, '2014-08-01')) + 1 lop
	,fl_reentry stat
	,iif(cd_discharge_type = 1, 'Reunification', 'Guardianship') discharge_type
	,state_fiscal_yyyy
	,non_dcfs_placements = 0
from #eps eps
	join calendar_dim cd
		on eps.federal_discharge_date = cd.calendar_date 
where cd_discharge_type in (1,4)
	and datediff(dd, federal_discharge_date, isnull(nxt_reentry_date, '2014-08-01')) >= 0
order by lop

