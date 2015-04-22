--    exec [prtl].[prod_build_prtl_outcomes] '2014-08-08'

CREATE procedure [prtl].[prod_build_prtl_outcomes](@permission_key datetime)
as 
set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin

	
		declare @start_date datetime
		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer	
		declare @end_date datetime
		set @end_date=(select dateadd(yy,-1,cd.[year]) from dbo.calendar_dim cd where CALENDAR_DATE=@cutoff_date)
	
		declare @date_type int
		set @date_type=2
			
		set @start_date = '2000-01-01'

-------------------------------------------------------------------------------------------------------------------------------------------------------GET SUBSET OF DATA
	
	if OBJECT_ID('tempDB..#eps') is not null drop table #eps;
	SELECT cohort_entry_year as cohort_entry_date
	, 2 as date_type, 0 as qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, case  when cd_discharge_type <> 0 	 and  exit_within_month_mult3   is  null then 0 else cd_discharge_type end [cd_discharge_type]
	, first_removal_dt [first_removal_date]
	, fl_first_removal
	, removal_dt [state_custody_start_date], federal_discharge_date, orig_federal_discharge_date
	,  eps.entry_cdc_census_mix_age_cd [age_grouping_cd], pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd
	, entry_int_match_param_key_cdc_census_mix [int_match_param_key]
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, int_filter_service_category filter_service_category
	, filter_service_budget
	, case when exit_within_month_mult3 = 3 or exit_within_month_mult3 is null then 1 else 0 end discharge_count
	, exit_within_month_mult3 [exit_within_min_month_mult3] 
	, cast(null as int) as row_num
	, case when cd_discharge_type=0 then 48 
		when exit_within_month_mult3 between 3 and 48 then  exit_within_month_mult3 - 3
		when cd_discharge_type <> 0 and exit_within_month_mult3 is null then 48
	 end  [max_still_in_care_month]
	 , 1 as cohort_count
	 , 3 as mnth
	into #eps
	from prtl.ooh_dcfs_eps eps
	where cohort_entry_year between @start_date and @end_date
		--select max_bin_los_cd,id_prsn_child,id_removal_episode_fact,state_custody_start_date,Federal_Discharge_Date,dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date) as mo
		--	 from #eps where bin_los_cd=4 and (extm9 > 0 or extm6>0 or extm3>0 or extm12>0 or extm15>0 or extm18>0 or extm21>0) and cd_discharge_type <>0

	

update eps
set row_num=q.row_num2
from #eps eps 
join (select tce.* ,row_number() over (-- only want one episode per cohort_period
				partition by tce.id_prsn_child,tce.cohort_entry_date
					order by id_prsn_child,cohort_entry_date asc ,state_custody_start_date asc,federal_discharge_date asc) as row_num2
					from #eps tce
					-- order by  tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
					) q on q.id_removal_episode_fact=eps.id_removal_episode_fact and q.state_custody_start_date=eps.state_custody_start_date

-- only want first in cohort period
delete from #eps where row_num > 1;



CREATE NONCLUSTERED INDEX idx_rownum
ON #eps ([row_num])
	CREATE NONCLUSTERED INDEX idx_temp_3
ON #eps ([id_removal_episode_fact],[state_custody_start_date])
INCLUDE ([row_num])
create nonclustered index idx_fl_first_removal on #eps(fl_first_removal)



-- insert remaining months for discharges including still in care 
-- since we changed those with a discharge after 48 months to still in care in qry above
	insert into #eps
	SELECT distinct cohort_entry_date
	, date_type, qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, cd_discharge_type
	, first_removal_date, fl_first_removal
	, state_custody_start_date, federal_discharge_date, orig_federal_discharge_date
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, filter_service_category
	, filter_service_budget
	, case when n.mnth >=exit_within_min_month_mult3 and cd_discharge_type<> 0 then 1 
			when n.mnth <=#eps.max_still_in_care_month  and cd_discharge_type=0 then 1 
			when  exit_within_min_month_mult3 is null then 1 else 0 end as discharge_count
	, [exit_within_min_month_mult3] 
	, row_num
	, max_still_in_care_month
	, 0 as cohort_count
	, n.mnth
from #eps
, (select number * 3 as mnth from numbers where number between 2 and 16) n 

drop index idx_rownum ON #eps
drop INDEX idx_temp_3 ON #eps
drop  index idx_fl_first_removal on #eps

-- now include other months for those still in care that had discharge within 48 months
	insert into #eps
	SELECT distinct cohort_entry_date
	, date_type, qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, 0 as cd_discharge_type
	, first_removal_date, fl_first_removal
	, state_custody_start_date, federal_discharge_date, orig_federal_discharge_date 
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, filter_service_category
	, filter_service_budget
	-- still in care persons count as 1
	, case when n.mnth <=max_still_in_care_month then 1 else 0 end [discharge_count]
	, [exit_within_min_month_mult3] 
	, row_num
	, max_still_in_care_month
	, 0 as cohort_count
	, n.mnth
from #eps
, (select number * 3 as mnth from numbers where number between 1 and 16) n 
where cd_discharge_type <> 0 

		-- insert first removals
		insert into #eps
		SELECT cohort_entry_date
	, date_type, fl_first_removal as qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, cd_discharge_type
	, first_removal_date, fl_first_removal
	, state_custody_start_date, federal_discharge_date, orig_federal_discharge_date
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs,fl_far, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, filter_service_category
	, filter_service_budget
	, discharge_count
	, [exit_within_min_month_mult3] 
	, row_num
	, max_still_in_care_month
	, cohort_count
	, mnth
		from #eps eps
		where fl_first_removal=1;
		
		ALTER TABLE prtl.prtl_outcomes NOCHECK CONSTRAINT ALL ;
		truncate table prtl.prtl_outcomes;
		insert into prtl.prtl_outcomes(cohort_entry_date,date_type,qry_type,cd_discharge_type,age_grouping_cd,pk_gndr,cd_race_census
		,census_Hispanic_Latino_Origin_cd,init_cd_plcm_setng,long_cd_plcm_setng,Removal_County_Cd,int_match_param_key
		,bin_dep_cd,max_bin_los_cd,bin_placement_cd
		,cd_reporter_type,bin_ihs_svc_cd,filter_access_type,filter_allegation
		,filter_finding,filter_service_category,filter_service_budget,mnth,discharge_count,cohort_count
		)
		select 
			cohort_entry_date
			,date_type
			,qry_type
			,cd_discharge_type
			,age_grouping_cd
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			-- select * from ref_filter_access_type
	, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
				+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
				+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
				+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
				+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
				+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
				+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]			-- select * from ref_filter_allegation
		,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
				+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
				+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
				+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
				+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
		,(select cd_multiplier from ref_filter_finding where cd_finding=0)
				+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
				+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
				+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
				+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			, filter_service_category
			, filter_service_budget
			, mnth
			,sum(discharge_count) as discharge_count
			,sum(cohort_count)		
		from #eps
		group by cohort_entry_date
			,date_type
			,qry_type
			,cd_discharge_type
			,age_grouping_cd
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			,fl_cps_invs
			,fl_alternate_intervention
			,fl_frs
			,fl_far
			,fl_risk_only
			,fl_cfws
			,fl_any_legal
			,fl_neglect
			,fl_sexual_abuse
			,fl_phys_abuse
			,fl_found_any_legal
			,fl_founded_neglect
			,fl_founded_sexual_abuse
			,fl_founded_phys_abuse
			, filter_service_category
			, filter_service_budget
			, mnth

		ALTER TABLE prtl.prtl_outcomes CHECK CONSTRAINT ALL ;

			
	update statistics prtl.prtl_outcomes;
			
	update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_outcomes)
	  where tbl_id=4;

end
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end

