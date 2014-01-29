--  truncate table dbo.prtl_ci_risks

declare @surv_data surv_table
declare @result table (
	filtercode bigint
	,dur_days float
	,fl_close smallint -- Events
	,num int -- num of values at specific time
	,n_i int -- children awaiting exit
	,q_i float -- rate of survivors (qi=(ni-di)/ni)
	,s_i float-- survival rate (q1 * q2 * ... * qi)
	)
declare @usegroup int
set @usegroup=1
declare @risk_data risk_table
declare @outcome_cd int
declare @outcome varchar(100)
declare @cd_race int
set @cd_race=1

-- declare @age_grouping_cd int
--set @age_grouping_cd=1select
set @outcome_cd=1


		while @outcome_cd<=5
		begin

			select top 1 @outcome=xw.discharge_type from [dbo].[ref_state_discharge_xwalk] xw  where xw.cd_discharge_type=@outcome_cd
			if @outcome_cd=2 set @outcome='Deceased'
		
			-- for each outcome reset fl_risk, fl_rightcensor, fl_competing_risks
			if @outcome_cd=1 
				begin
					insert into @risk_data(id_prsn_child,outcome_cd,outcome,dur_days,param_id,fl_risk,fl_rightcensor,fl_competingrisk)
					Select  
						  ID_PRSN_CHILD as id_prsn_child
						, case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end as outcome_cd
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end)=2 then 'Deceased' 
							else vw.outcome end as outcome
						, dur_days
						, cast(concat(cast(dbo.julian_date(cd.[year])   as char(7)) , '2', cast(prm.param_key as char(9))) as bigint)  as param_id
						, case when ((case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end))=@outcome_cd then 1 else 0 
							end as fl_risk
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end) in (0,6) then 1 else 0 
							end as fl_rightcensor
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end) not in (0,6,@outcome_cd) then 1 else 0 
							end as fl_competingrisk
					  from dbo.vw_episodes vw
					  join ca.calendar_dim cd on cd.calendar_date=vw.eps_begin
					  left join (select distinct xw.cd_discharge_type as outcome_cd,xw.discharge_type as outcome from ref_state_discharge_xwalk xw) q on q.outcome=vw.outcome
					  join dbo.ref_age_groupings_census age on vw.age_eps_begin >=  age.age_begin and vw.age_eps_begin < age.age_lessthan_end
						   and age_grouping_cd=0 --  @age_grouping_cd -- > 0
					  join dbo.ref_lookup_gender gdr on gdr.cd_gndr=vw.cd_gndr  and gdr.pk_gndr in (1,2)
					  join ref_match_ooh_parameters prm on 
									  prm.age_grouping_cd=0--@age_grouping_cd--age.age_grouping_cd
								  and prm.pk_gndr=gdr.pk_gndr
								  and prm.cd_race_census=0 --tce.cd_race_census 
								  and prm.init_cd_plcm_setng=0 -- tce.frst_plcm_setng_cd
								  and prm.longest_plcm_setng_cd =0 -- tce.longest_plcm_setng_cd
								  and prm.county_cd=0-- tce.county_cd	
      
					  where vw.eps_begin between '2000-01-01' and '2012-12-31' 
					  and age_eps_begin between 0 and 17
					  
				union all
					Select  
    					  ID_PRSN_CHILD as id_prsn_child
						, case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end as outcome_cd
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end)=2 then 'Deceased' 
							else vw.outcome end as outcome
						, dur_days
						, cast(concat(cast(dbo.julian_date(cd.[month])   as char(7)) , '0', cast(prm.param_key as char(9))) as bigint) as param_id
						, case when ((case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end))=@outcome_cd then 1 else 0 end as fl_risk
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end) in (0,6) then 1 else 0 end as fl_rightcensor
						, case when (case when vw.fl_death=1 then 2 
							when q.outcome_cd=6 then 0  -- these are right censors
							else q.outcome_cd end) not in (0,6,@outcome_cd) then 1 else 0 end as fl_competingrisk

				  from dbo.vw_episodes vw
				  join ca.calendar_dim cd on cd.calendar_date=vw.eps_begin
				  left join (select distinct xw.cd_discharge_type as outcome_cd,xw.discharge_type as outcome from ref_state_discharge_xwalk xw) q on q.outcome=vw.outcome
				   join dbo.ref_age_groupings_census age on vw.age_eps_begin >=  age.age_begin and vw.age_eps_begin < age.age_lessthan_end
						   and age_grouping_cd=0 --  @age_grouping_cd -- > 0
					join dbo.ref_lookup_gender gdr on gdr.cd_gndr=vw.cd_gndr and gdr.pk_gndr in (1,2)
				  join ref_match_ooh_parameters prm on 
					  prm.age_grouping_cd=0 --age.age_grouping_cd
					  and prm.pk_gndr=gdr.pk_gndr
					  and prm.cd_race_census=0 --tce.cd_race_census 
					  and prm.init_cd_plcm_setng=0 -- tce.frst_plcm_setng_cd
					  and prm.longest_plcm_setng_cd =0 -- tce.longest_plcm_setng_cd
					  and prm.county_cd=0-- tce.county_cd	
					  
   			  where vw.eps_begin between '2000-01-01' and '2013-04-30' 
				  and age_eps_begin between 0 and 17
				  order by param_id,[outcome_cd],dur_days
			end
		else
			begin
				update @risk_data
				set fl_risk=0,fl_rightcensor=0,fl_competingrisk=0;
		
				update @risk_data
				set fl_risk=case when outcome_cd=@outcome_cd  then 1 else 0 end
				,fl_rightcensor=case when (outcome_cd in (6,0)) then 1 else 0 end
				,fl_competingrisk=case when (outcome_cd not in (@outcome_cd,6,0) )   then 1 else 0 end

			end

			insert into  dbo.prtl_ci_outcomes  
				([param_id],[outcome_cd],[outcome],[dur_days],[fl_risk],[fl_competingrisk],[fl_rightcensor],[num],[n_j],[e_j],[r_j],[c_j],[q1_j],[q2_j],[s1_j],[s2_j],[ci_j])
			select distinct
				  ci.param_id
				, ci.outcome_cd
				, case when ci.outcome_cd=2 then 'Deceased' else ci.outcome end as outcome
				, ci.dur_days
				, ci.fl_risk
				, ci.fl_competingrisk
				, ci.fl_rightcensor
				, ci.num
				, ci.n_j
				, ci.e_j
				, ci.r_j
				, ci.c_j
				, ci.q1_j
				, ci.q2_j
				, ci.s1_j
				, ci.s2_j
				, ci.ci_j
			from dbo.compute_ci(@risk_data,@outcome_cd,@outcome,@usegroup) ci

		
			set @outcome_cd=@outcome_cd + 1
			if @outcome_cd=6
				begin
					
					insert into @surv_data(id_prsn_child,filtercode,dur_days,fl_close)
					select s.id_prsn_child,s.param_id,s.dur_days,case when outcome_cd >=1 then 1 else 0 end as fl_close
					from  @risk_data s

					insert into @result  
					select distinct *
					from survfit(@surv_data,1) sf

					update CI
					set overall_survival=r.s_i
					from dbo.prtl_ci_outcomes CI
					join @result R on r.filtercode=CI.param_id
						and r.dur_days=CI.dur_days

					delete from @result
					delete from @surv_data

				end
			end			
	

	




		

		

		


	