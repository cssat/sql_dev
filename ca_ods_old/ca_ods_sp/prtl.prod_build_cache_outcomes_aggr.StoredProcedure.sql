USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_outcomes_aggr]    Script Date: 4/14/2014 7:30:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_cache_outcomes_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
		declare @loop int
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
			declare @bin_dep_cd varchar(20)
			declare @max_qry_id int
			DECLARE @RC int
		set @max_qry_id = (select max(qry_id) from prtl.cache_ooh_params_backup)




 
		truncate table prtl.cache_outcomes_aggr;
		truncate table prtl.cache_qry_param_outcomes;
		truncate table prtl.cache_outcomes_params;
		
		

		select *
		into  #params
		from prtl.cache_ooh_params_backup;

		create index idx_prm on #params(qry_id);

		

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
					  ,@bin_dep_cd=bin_dep_cd
				FROM #params
				where qry_ID=@loop;







					EXECUTE @RC = prtl.sp_cache_outcomes_insert_only
										@age_grouping_cd
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
										,@filter_service_budget
										,@bin_dep_cd;

				set @loop=@loop + 1;
			end ;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_outcomes_aggr)
	  where tbl_id=19;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_outcomes_params)
	  where tbl_id=20;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_outcomes)
	  where tbl_id=21;

end;
	

