USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_outcomes_aggr]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [prtl].[prod_build_cache_outcomes_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
		declare @loop int
		declare @date varchar(50)
			declare @qry_id bigint
			declare @age_grouping_cd varchar(30)
			declare @race_cd varchar(30)
			declare @gender_cd varchar(10)
			declare @init_cd_plcm_setng varchar(30)
			declare @long_cd_plcm_setng varchar(30)
			declare @County_Cd  varchar(200)
			declare @bin_los_cd varchar(30) 
			declare @bin_placement_cd varchar(30) 
			declare @bin_ihs_svc_cd varchar(30) 
			declare  @cd_reporter_type varchar(100) 
			declare  @filter_access_type varchar(30) 
			declare  @filter_allegation  varchar(100)
			declare @filter_finding varchar(100)
			declare  @filter_service_category  varchar(100)
			declare  @filter_service_budget varchar(100)
			declare @max_qry_id int

		set @max_qry_id = (select max(qry_id) from prtl.cache_outcomes_params where qry_id <=57)
		
		set @date='2000-01-01,' + convert(varchar(10),(select dateadd(yy,-1,[year]) from dbo.calendar_dim where CALENDAR_DATE =(select cutoff_date from ref_Last_DW_Transfer)),121)
		
		
		truncate table prtl.cache_outcomes_aggr;
		truncate table prtl.cache_qry_param_outcomes;
		--truncate table prtl.cache_outcomes_params;
		
		if object_ID(N'prtl.cache_outcomes_params_bkp',N'U') is not null drop table prtl.cache_outcomes_params_bkp;
		select *
		into prtl.cache_outcomes_params_bkp
		from prtl.cache_outcomes_params where qry_id <=57;

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.cache_outcomes_params	
		where qry_id <=57;

		truncate table prtl.cache_outcomes_params;

		set @loop =1 

		while @loop <=@max_qry_id
		begin


				SELECT @qry_id=[qry_ID]
					  ,@age_grouping_cd=[age_grouping_cd]
					  ,@race_cd=[cd_race_census]
					  ,@gender_cd=[pk_gndr]
					  ,@init_cd_plcm_setng=[init_cd_plcm_setng]
					  ,@long_cd_plcm_setng=[long_cd_plcm_setng]
					  ,@County_Cd=[county_cd]
					  ,@bin_los_cd=[bin_los_cd]
					  ,@bin_placement_cd=[bin_placement_cd]
					  ,@bin_ihs_svc_cd=[bin_ihs_svc_cd]
					  ,@cd_reporter_type=[cd_reporter_type]
					  ,@filter_access_type=[filter_access_type]
					  ,@filter_allegation=[filter_allegation]
					  ,@filter_finding=[filter_finding]
					  ,@filter_service_category=[filter_srvc_type]
					  ,@filter_service_budget=[filter_budget]
				FROM #params
				where qry_ID=@loop


 
				exec prtl.sp_cache_outcomes_insert_only
					@date  --  p_date
					,@age_grouping_cd
					,@race_cd
					,@gender_cd
					,@init_cd_plcm_setng
					,@long_cd_plcm_setng
					,@County_Cd
					,@bin_los_cd
					,@bin_placement_cd
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@filter_service_category
					,@filter_service_budget;

				set @loop=@loop + 1;
			end ;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc1ab_aggr)
	  where tbl_id=19;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc1ab_params)
	  where tbl_id=20;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_poc1ab)
	  where tbl_id=21;
/**
	  insert into prtl.cache_outcomes_params
select 
	(select max(qry_id) from prtl.cache_outcomes_params)  + vw_age.row_num
, vw_age.age_grouping_cd
, prm.cd_race_census
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
, [dbo].[vw_choose_age_census_mix] vw_age
where prm.age_grouping_cd='1,2,3,4,5,6,7'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + eth.row_num
, prm.age_grouping_cd
, rtrim(ltrim(eth.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_ethnicity] eth on 1=1
left join  prtl.cache_outcomes_params pm
on pm.age_grouping_cd=prm.age_grouping_cd
and pm.cd_race_census=eth.cd_race_census
and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
and pm.county_cd=prm.county_cd
and pm.bin_los_cd=prm.bin_los_cd
and pm.bin_placement_cd=prm.bin_placement_cd
and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
and pm.cd_reporter_type=prm.cd_reporter_type
and pm.filter_access_type=prm.filter_access_type
and pm.filter_allegation=prm.filter_allegation
and pm.filter_finding=prm.filter_finding
and pm.filter_srvc_type=prm.filter_srvc_type
and pm.filter_budget=prm.filter_budget
where pm.age_grouping_cd is null
and prm.age_grouping_cd='0'
and prm.cd_race_census='1,2,3,4,5,6,8,9,10,11,12'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + 1
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, 1
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
-- join [dbo].[vw_choose_ethnicity] eth on 1=1
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='1,2'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'
union 
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + 2
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, 2
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
-- join [dbo].[vw_choose_ethnicity] eth on 1=1
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='1,2'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + fpl.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, fpl.cd_plcm_setng -- .init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
, [dbo].[vw_choose_cd_plcm_setng] fpl
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='3,4,5,6,7'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + lpl.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, lpl.cd_plcm_setng --  prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
, [dbo].[vw_choose_cd_plcm_setng] lpl
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='3,4,5,6,7'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + cnty.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, cnty.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
,[dbo].[vw_choose_county] cnty
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + los.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, los.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
,[dbo].[vw_choose_bin_los_cd] los
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='1,2,3,4'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + plc.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, plc.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
, [dbo].[vw_choose_bin_placement_cd] plc
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='1,2,3,4,5'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + ihs.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, ihs.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
, [dbo].vw_choose_bin_ihs_svc_cd ihs
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='1,2,3'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + rpt.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, rpt.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_reporter_type] rpt on 1=1
left join  prtl.cache_outcomes_params pm
on pm.age_grouping_cd=prm.age_grouping_cd
and pm.cd_race_census=prm.cd_race_census
and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
and pm.county_cd=prm.county_cd
and pm.bin_los_cd=prm.bin_los_cd
and pm.bin_placement_cd=prm.bin_placement_cd
and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
and pm.cd_reporter_type=rpt.cd_reporter_type
and pm.filter_access_type=prm.filter_access_type
and pm.filter_allegation=prm.filter_allegation
and pm.filter_finding=prm.filter_finding
and pm.filter_srvc_type=prm.filter_srvc_type
and pm.filter_budget=prm.filter_budget
where pm.age_grouping_cd is null
and   prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='5,6,7,8,9,11,12,13,14'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';


insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + alg.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, alg.bin_los_cd as filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_bin_los_cd]  alg on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='1,2,3,4'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + fnd.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, fnd.bin_los_cd as    filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_bin_los_cd]  fnd on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='1,2,3,4'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + srvc.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, srvc.service_type  as filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_service_type]  srvc on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + budg.row_num
, prm.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, budg.budget_type as filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [dbo].[vw_choose_budget_type] budg on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='12,14,15,16,18,19,99';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + age_eth.row_num
, age_eth.age_grouping_cd
, rtrim(ltrim(age_eth.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join [vw_choose_age_eth_census_mix] age_eth on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='1,2,3,4,5,6,7'
and prm.cd_race_census='1,2,3,4,5,6,8,9,10,11,12'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + age_lpl.row_num
, age_lpl.age_grouping_cd
, rtrim(ltrim(prm.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, age_lpl.cd_plcm_setng  as long_cd_plcm_setng
, prm.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join vw_choose_age_census_mix_cd_plcm_setng age_lpl on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='1,2,3,4,5,6,7'
and prm.cd_race_census='0'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='3,4,5,6,7'
and prm.county_cd='0'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0'

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + eth_cnty_rpt.row_num
, prm.age_grouping_cd
, rtrim(ltrim(eth_cnty_rpt.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, eth_cnty_rpt.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, eth_cnty_rpt.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join vw_choose_ethnicity_county_rpt eth_cnty_rpt on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='1,2,3,4,5,6,8,9,10,11,12'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='5,6,7,8,9,11,12,13,14'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + eth_cnty_alg.row_num
, prm.age_grouping_cd
, rtrim(ltrim(eth_cnty_alg.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, eth_cnty_alg.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, eth_cnty_alg.filter_finding as filter_allegation
, prm.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join vw_choose_ethnicity_county_finding eth_cnty_alg on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='1,2,3,4,5,6,8,9,10,11,12'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='1,2,3,4'
and prm.filter_finding='0'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';

insert into prtl.cache_outcomes_params
select distinct
	(select max(qry_id) from prtl.cache_outcomes_params)  + eth_cnty_fnd.row_num
, prm.age_grouping_cd
, rtrim(ltrim(eth_cnty_fnd.cd_race_census))
, prm.pk_gndr
, prm.init_cd_plcm_setng
, prm.long_cd_plcm_setng
, eth_cnty_fnd.county_cd
, prm.bin_los_cd
, prm.bin_placement_cd
, prm.bin_ihs_svc_cd
, prm.cd_reporter_type
, prm.filter_access_type
, prm.filter_allegation
, eth_cnty_fnd.filter_finding
, prm.filter_srvc_type
, prm.filter_budget
, prm.min_start_date
, prm.max_start_date
, prm.cnt_qry
, prm.last_run_date
, prm.qry_ID
-- select distinct prm.*
from prtl.cache_outcomes_params prm
join vw_choose_ethnicity_county_finding eth_cnty_fnd on 1=1
--left join  prtl.cache_outcomes_params pm
--on pm.age_grouping_cd=prm.age_grouping_cd
--and pm.cd_race_census=prm.cd_race_census
--and pm.init_cd_plcm_setng=prm.init_cd_plcm_setng
--and pm.long_cd_plcm_setng=prm.long_cd_plcm_setng
--and pm.county_cd=prm.county_cd
--and pm.bin_los_cd=prm.bin_los_cd
--and pm.bin_placement_cd=prm.bin_placement_cd
--and pm.bin_ihs_svc_cd=prm.bin_ihs_svc_cd
--and pm.cd_reporter_type=rpt.cd_reporter_type
--and pm.filter_access_type=prm.filter_access_type
--and pm.filter_allegation=prm.filter_allegation
--and pm.filter_finding=prm.filter_finding
--and pm.filter_srvc_type=prm.filter_srvc_type
--and pm.filter_budget=prm.filter_budget
where  prm.age_grouping_cd='0'
and prm.cd_race_census='1,2,3,4,5,6,8,9,10,11,12'
and prm.pk_gndr='0'
and prm.init_cd_plcm_setng='0'
and prm.long_cd_plcm_setng='0'
and prm.county_cd='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39'
and prm.bin_los_cd='0'
and prm.bin_placement_cd='0'
and prm.bin_ihs_svc_cd='0'
and prm.cd_reporter_type='0'
and prm.filter_access_type='0'
and prm.filter_allegation='0'
and prm.filter_finding='1,2,3,4'
and prm.filter_srvc_type='0'
and prm.filter_budget='0';
**/
end;
	


GO
