






CREATE view [dbo].[vw_episodes]
as 
select distinct tbl_child_episodes.id_removal_episode_fact
	, tbl_child_episodes.id_prsn_child
	, state_custody_start_date as eps_begin
	--, federal_discharge_date as eps_end
--	, federal_discharge_date as orig_fed_discharge_date
	, case when  federal_discharge_date  is null 
			and tcps.trh_begin_date is not null
			and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
			then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) else federal_discharge_date end as eps_end
	, federal_discharge_date_force_18 as earlier_of_eps_end_18th_bday
	, tbl_child_episodes.first_removal_date as first_removal_date
	, tbl_child_episodes.latest_removal_date as latest_removal_date
	--,  tbl_child_episodes.Federal_Discharge_Reason_Code as fed_dsch_rsn_cd
	, tbl_child_episodes.init_cd_plcm_setng as frst_plcm_setng_cd
	, frstdesc.tx_plcm_setng as frst_plcm_setng
	, tbl_child_episodes.long_cd_plcm_setng as longest_plcm_setng_cd
	, longdesc.tx_plcm_setng  as longest_plcm_setng
	, First_Removal_Date as frst_eps_date
	, Latest_Removal_Date as latest_eps_date
	, tbl_child_episodes.dt_birth
	, CHILD_AGE_REMOVAL_BEGIN as age_eps_begin
	, CHILD_AGE_REMOVAL_END as age_eps_end
	, age_dim.census_child_group_cd
	, age_dim.census_child_group_tx
	, age_dim.census_20_group_cd
	, age_dim.census_20_group_tx
	, age_dim.custom_group_cd
	, age_dim.custom_group_tx
	, cd_gndr
	, tbl_child_episodes.cd_race_census
	, race.tx_race_census 
	, tbl_child_episodes.census_Hispanic_Latino_Origin_cd as ethnicity_cd
	, eth.census_hispanic_latino_origin as ethnicity
--	, tbl_child_episodes.dur_days
	, case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end as dur_days
	, tbl_child_episodes.dur_days_longest_plcm
--	, tbl_child_episodes.dur_days as orig_dur_days
	, case when (case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end) <=7 then 1 else 0 end as fl_dur_7
	, case when (case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end) <= 90 then 1 else 0 end as [fl_dur_90]
	, eps_rank
	, eps_total
	, case when ((case when  federal_discharge_date  is null 
			and tcps.trh_begin_date is not null
			and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
			then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) else isnull(federal_discharge_date,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end) end)is not null
			)  then 1 else 0 end as fl_close
--	,tbl_child_episodes.fl_close as orig_fl_close
--	, petition_dependency_date
	, tbl_child_episodes.Removal_County_Cd as county_cd
	, tbl_child_episodes.Removal_County as county
	--,  tbl_child_episodes.Federal_Discharge_Reason as fed_dsch_rsn
	--,  tbl_child_episodes.state_discharge_reason_code as st_dsch_rsn_cd
	--, tbl_child_episodes.state_discharge_reason as st_dsch_rsn
	--, tbl_child_episodes.Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON as lst_plcm_end_rsn
	,   iif(tbl_child_episodes.cd_discharge_type=0,'Still in care', toe.discharge_type)as outcome
	,  cnt_plcm
	, isnull(intk_si.fl_cps_invs,0) as fl_cps_invs
	, isnull( intk_si.fl_frs,0) as fl_frs
	, isnull( intk_si.fl_cfws,0) as fl_cfws
	, isnull( intk_si.fl_alternate_intervention,0) as fl_alternate_intervention
	, isnull( intk_si.fl_risk_only,0) as fl_risk_only
	, isnull( intk_si.fl_phys_abuse,0) as  fl_alleg_phys_abuse
	, isnull( intk_si.fl_sexual_abuse,0) as  fl_alleg_sexual_abuse
	, isnull( intk_si.fl_neglect,0) as  fl_alleg_neglect
	, isnull( intk_si.fl_other_maltreatment,0) as  fl_alleg_other_maltreatment
	, isnull( intk_si.fl_founded_phys_abuse,0) as  fl_founded_phys_abuse
	, isnull( intk_si.fl_founded_sexual_abuse,0) as  fl_founded_sexual_abuse
	, isnull( intk_si.fl_founded_neglect,0) as  fl_founded_neglect
	, isnull( intk_si.fl_founded_other_maltreatment,0) as fl_founded_other_maltreatment 
	, isnull( intk_si.fl_prior_phys_abuse,0) as  fl_prior_alleg_phys_abuse
	, isnull( intk_si.fl_prior_sexual_abuse,0) as  fl_prior_alleg_sexual_abuse
	, isnull( intk_si.fl_prior_neglect,0) as  fl_prior_alleg_neglect
	, isnull( intk_si.fl_prior_other_maltreatment,0) as  fl_prior_alleg_other_maltreatment
	, isnull( intk_si.fl_founded_prior_phys_abuse,0) as  fl_founded_prior_phys_abuse
	, isnull( intk_si.fl_founded_prior_sexual_abuse,0) as  fl_founded_prior_sexual_abuse
	, isnull( intk_si.fl_founded_prior_neglect,0) as  fl_founded_prior_negelect
	, isnull( intk_si.fl_founded_prior_other_maltreatment,0) as  fl_founded_prior_other_maltreatment
	, isnull(intk_si.fl_hh_is_mother,0) as fl_hh_is_mother
	, intk_si.inv_ass_start as intake_referral_date
	, (tbl_child_episodes.bin_dep_cd) 
	, dpnd.bin_dep_desc
	, (tbl_child_episodes.fl_dep_exist) 
--	,  datediff(dd,trh_begin_date,isnull(trh_end_date,(select cutoff_date from ref_last_dw_transfer))) as dur_last_trh_plcmnt
	--, coalesce(xw3.cd_discharge_type, xwS.cd_discharge_type, xwE.cd_discharge_type, xwF.cd_discharge_type, pl.cd_discharge_type , 0)  as dschtype_cd
	--, coalesce(xw3.discharge_type, xwS.discharge_type, xwE.discharge_type, xwF.discharge_type, pl.discharge_type , 'Still in Care')  as dschtype
--into ##temp
from base.tbl_child_episodes	
join dbo.ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
left join base.tbl_child_placement_settings tcps on tcps.id_removal_episode_fact=tbl_child_episodes.id_removal_episode_fact
		and fl_lst_ooh_plcm =1 and Trial_Return_Home_Cd=1 
		and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
left join dbo.ref_lookup_hispanic_latino_census	eth on eth.census_Hispanic_Latino_Origin_cd=tbl_child_episodes.census_hispanic_latino_origin_cd
left join dbo.ref_lookup_ethnicity_census race on race.cd_race_census=tbl_child_episodes.cd_race_census
left join dbo.ref_lookup_plcmnt frstdesc on frstdesc.cd_plcm_setng=tbl_child_episodes.init_cd_plcm_setng
left join dbo.ref_lookup_plcmnt longdesc on longdesc.cd_plcm_setng=tbl_child_episodes.long_cd_plcm_setng
left join ref_lookup_cd_discharge_type_exits toe on toe.cd_discharge_type=tbl_child_episodes.cd_discharge_type
	-- match on state discharge reason code ... CD_DSCH_RSN 
-- get the last placement
--left join base.tbl_child_placement_settings tcpsLst on tcpsLst.id_removal_episode_fact=tbl_child_episodes.id_removal_episode_fact
--		and tcpsLst.fl_lst_ooh_plcm =1
left join base.tbl_intakes intk_si on intk_si.id_intake_fact=tbl_child_episodes.id_intake_fact and intk_si.cd_final_decision=1
left join dbo.age_dim on age_dim.age_mo=tbl_child_episodes.age_eps_begin_mos
left join dbo.ref_filter_dependency dpnd on dpnd.bin_dep_cd=tbl_child_episodes.bin_dep_cd
group by tbl_child_episodes.id_removal_episode_fact
	, tbl_child_episodes.id_prsn_child
	, state_custody_start_date 
		,case when  federal_discharge_date  is null 
			and tcps.trh_begin_date is not null
			and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
			then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) else federal_discharge_date end
--	, federal_discharge_date
	, federal_discharge_date_force_18 
--	,  tbl_child_episodes.Federal_Discharge_Reason_Code 
	, frstdesc.tx_plcm_setng 
	, tbl_child_episodes.init_cd_plcm_setng
	, longdesc.tx_plcm_setng 
	, tbl_child_episodes.long_cd_plcm_setng 
	, First_Removal_Date 
	, Latest_Removal_Date
	, tbl_child_episodes.dt_birth
	, CHILD_AGE_REMOVAL_BEGIN 
	, CHILD_AGE_REMOVAL_END 
	, cd_gndr
	, tbl_child_episodes.cd_race_census
	, race.tx_race_census 
	, tbl_child_episodes.census_Hispanic_Latino_Origin_cd 
	, eth.census_hispanic_latino_origin 
	, iif(tbl_child_episodes.cd_discharge_type=0,'Still in care', toe.discharge_type)
, case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end
--	,tbl_child_episodes.dur_days
	--, dur_trh_days
	--, cnt_trh
	, case when (case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end) <=7 then 1 else 0 end 
	, case when (case when datediff(dd,state_custody_start_date
							,isnull(isnull((case when  federal_discharge_date  is null 
										and tcps.trh_begin_date is not null
										and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
										then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
										else federal_discharge_date end)
										,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end)
										,cutoff_date)) + 1 
							<> tbl_child_episodes.dur_days 
			then datediff(dd,state_custody_start_date
						,isnull(isnull((
						case when  federal_discharge_date  is null 
								and tcps.trh_begin_date is not null
							and (tcps.trh_end_date is not null or (tcps.trh_end_date is null 
							and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
							then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) 
							else federal_discharge_date end),case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end),cutoff_date)) + 1
			else tbl_child_episodes.dur_days end) <= 90 then 1 else 0 end
		, eps_rank
	, eps_total
	, case when ((case when  federal_discharge_date  is null 
			and tcps.trh_begin_date is not null
			and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,cutoff_date) >=183))
			then isnull(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) else isnull(federal_discharge_date,case when federal_discharge_date_force_18 >=state_custody_start_date then federal_discharge_date_force_18 else null end) end)is not null
			)  then 1 else 0 end
--	,tbl_child_episodes.fl_close
	--, tbl_child_episodes.fl_close
	--, petition_dependency_date
	, tbl_child_episodes.Removal_County_Cd 
	, tbl_child_episodes.Removal_County 
	--, tbl_child_episodes.fam_structure_cd
	--, tbl_child_episodes.fam_structure_tx
	--,  tbl_child_episodes.Federal_Discharge_Reason 
	--,  tbl_child_episodes.state_discharge_reason_code 
	--, tbl_child_episodes.state_discharge_reason
	--, tbl_child_episodes.Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON 
	,  cnt_plcm
	, tbl_child_episodes.id_intake_fact
	, isnull(intk_si.fl_cps_invs,0)
	, isnull(intk_si.fl_frs,0)
	, isnull(intk_si.fl_cfws,0)
	, isnull(intk_si.fl_alternate_intervention,0)
	, isnull(intk_si.fl_risk_only,0)
	, isnull(intk_si.fl_phys_abuse ,0)
	, isnull(intk_si.fl_sexual_abuse ,0)
	, isnull(intk_si.fl_neglect ,0)
	, isnull(intk_si.fl_other_maltreatment ,0)
	, isnull(intk_si.fl_founded_phys_abuse,0)
	, isnull(intk_si.fl_founded_sexual_abuse,0)
	, isnull(intk_si.fl_founded_neglect,0)
	, isnull(intk_si.fl_founded_other_maltreatment,0)
	, isnull(intk_si.fl_prior_phys_abuse ,0)
	, isnull(intk_si.fl_prior_sexual_abuse ,0)
	, isnull(intk_si.fl_prior_neglect ,0)
	, isnull(intk_si.fl_prior_other_maltreatment ,0)
	, isnull(intk_si.fl_founded_prior_phys_abuse,0)
	, isnull(intk_si.fl_founded_prior_sexual_abuse,0)
	, isnull(intk_si.fl_founded_prior_neglect,0)
	, isnull(intk_si.fl_founded_prior_other_maltreatment,0)
	, isnull(intk_si.fl_hh_is_mother,0)
	,intk_si.inv_ass_start
	, age_dim.census_child_group_cd
	, age_dim.census_child_group_tx
	, age_dim.census_20_group_cd
	, age_dim.census_20_group_tx
	, age_dim.custom_group_cd
	, age_dim.custom_group_tx
, tbl_child_episodes.dur_days_longest_plcm
	, (tbl_child_episodes.bin_dep_cd) 
	, dpnd.bin_dep_desc
	, (tbl_child_episodes.fl_dep_exist) 
--where state_custody_start_date < coalesce(federal_discharge_date_force_18, '12/31/3999')

/**						
from #eps eps
					join #plcmnt plc on plc.id_removal_episode_fact=eps.id_removal_episode_fact and record_num=1
					join dbo.ref_state_discharge_xwalk xw 
							on xw.CD_DSCH_RSN=plc.placement_end_reason_code
					where eps.dschtype=0 and eps.federal_discharge_date is not null 		**/					
						

		 
					
					 
					
					 
					 
					 
































