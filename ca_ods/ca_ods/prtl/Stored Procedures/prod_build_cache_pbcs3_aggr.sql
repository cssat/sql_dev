
CREATE procedure [prtl].[prod_build_cache_pbcs3_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
		declare @loop int
		declare @starttime datetime=getdate();
			declare @qry_id bigint
			declare @age_grouping_cd varchar(100)
			declare @cd_race_census varchar(30)
			declare @cd_county  varchar(250)
			declare  @cd_reporter_type varchar(100) 
			declare @bin_ihs_svc_cd varchar(30) 
			declare  @filter_access_type varchar(30) 
			declare  @filter_allegation  varchar(100)
			declare @filter_finding varchar(30)
			declare  @filter_service_category  varchar(50)
			declare  @filter_service_budget varchar(50)
			declare @max_qry_id int

		select @max_qry_id=max(qry_id) from prtl.ihs_params_backup
		
				
		truncate table prtl.cache_pbcs3_aggr;
		truncate table prtl.cache_qry_param_pbcs3;
		truncate table prtl.cache_pbcs3_params;
		

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.ihs_params_backup	 where qry_id <= @max_qry_id 

		

		set @loop =1 

		while @loop <=@max_qry_id
		begin


				SELECT @qry_id=[qry_ID]
					  ,@age_grouping_cd=cd_sib_age_grp
					  ,@cd_race_census=[cd_race_census]
					  ,@cd_county=cd_county
					  ,@cd_reporter_type=[cd_reporter_type]
					  ,@bin_ihs_svc_cd=[bin_ihs_svc_cd]
					  ,@filter_access_type=[filter_access_type]
					  ,@filter_allegation=[filter_allegation]
					  ,@filter_finding=[filter_finding]
					  ,@filter_service_category=[filter_srvc_type]
					  ,@filter_service_budget=[filter_budget]
				FROM #params
				where qry_ID=@loop


 
				exec prtl.sp_cache_pbcs3_insert_only
					@age_grouping_cd
					,@cd_race_census
					,@cd_county
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@filter_service_category
					,@filter_service_budget;

				set @loop=@loop + 1;
			end ;
	declare @endtime datetime =getdate()
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcs3_aggr)
	  ,load_time_mins=dbo.fnc_datediff_mis(@starttime,@endtime)
	  where tbl_id=31;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcs3_params)
	   ,load_time_mins=0
	  where tbl_id=32;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_pbcs3)
	   ,load_time_mins=1
	  where tbl_id=33;


	  update statistics prtl.cache_pbcs3_params;
	  update statistics prtl.cache_pbcs3_aggr;

-- loh inserted above
--select * from prtl.cache_pbcs3_params order by qry_id

		end;


