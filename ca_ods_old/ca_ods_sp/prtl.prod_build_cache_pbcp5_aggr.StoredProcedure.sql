USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_pbcp5_aggr]    Script Date: 2/18/2014 10:41:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_cache_pbcp5_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin

		set nocount off
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
			declare @bin_dep_cd varchar(20)
			declare @max_qry_id int
			declare @min_qry_id int

		select @max_qry_id=max(qry_id) ,@min_qry_id=min(qry_id) from prtl.cache_ooh_params_backup ;
		
	set @date='2000-01-01,' + convert(varchar(10),(select max_date_any from ref_lookup_max_date where id=9),120)
		
		
		truncate table prtl.cache_pbcp5_aggr;
		truncate table prtl.cache_qry_param_pbcp5;
		truncate table prtl.cache_pbcp5_params;
		

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.cache_ooh_params_backup	
		order by qry_id;

		

		set @loop =@min_qry_id 
		print @min_qry_id
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
				where qry_ID=@loop


 
				exec prtl.[sp_cache_pbcp5_insert_only]
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
					,@filter_service_budget
					,@bin_dep_cd;

				select @loop=min(qry_id) from #params where qry_id>@loop;
				print @loop;
			end ;
	
			delete pbcp5
			from prtl.cache_pbcp5_aggr pbcp5
            join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=pbcp5.bin_dep_cd 
                  and dateadd(dd,abs(ref_dep.lag),dateadd(mm,9,dateadd(dd,-1,dateadd(yy,1,cohort_exit_year))))  > (select cutoff_date from ref_last_dw_transfer)
           

	    delete pbcp5
		from prtl.cache_pbcp5_aggr pbcp5
		join ref_filter_los ref_los on ref_los.bin_los_cd=pbcp5.bin_los_cd 
                                     and dateadd(dd,abs(ref_los.lag),dateadd(mm,9,dateadd(dd,-1,dateadd(yy,1,cohort_exit_year))))  > (select cutoff_date from ref_last_dw_transfer)
		
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcp5_aggr)
	  where tbl_id=22;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcp5_params)
	  where tbl_id=23;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_pbcp5)
	  where tbl_id=24;

end;
	


	