
CREATE procedure [prtl].[prod_build_cache_poc3ab_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
declare @starttime datetime=getdate()
		declare @loop int
		declare @date varchar(50)
			declare @qry_id bigint
			declare @age_grouping_cd varchar(100)
			declare @cd_race_census varchar(30)
			declare @cd_county  varchar(250)
			declare  @cd_reporter_type varchar(100) 
			declare @bin_ihs_svc_cd varchar(30) 
			declare  @filter_access_type varchar(30) 
			declare  @filter_allegation  varchar(100)
			declare @filter_finding varchar(30)
			declare @max_qry_id int

		select @max_qry_id =max(qry_id) from prtl.ihs_params_backup
		
			
		truncate table prtl.cache_poc3ab_aggr;
		truncate table prtl.cache_qry_param_poc3ab;
		truncate table prtl.cache_poc3ab_params;
		

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.ihs_params	 where qry_id <= @max_qry_id 

		--  select * from  prtl.ihs_params

		

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
				FROM #params
				where qry_ID=@loop


 
				exec prtl.sp_cache_poc3ab_counts_insert_only
					@age_grouping_cd
					,@cd_race_census
					,@cd_county
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding

				set @loop=@loop + 1;
			end ;

	declare @endtime datetime=getdate()
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc3ab_aggr)
	  ,load_time_mins=dbo.fnc_datediff_mis(@starttime,@endtime)
	  where tbl_id=16;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc3ab_params)
	  ,load_time_mins=0
	  where tbl_id=17;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_poc3ab)
	  	  ,load_time_mins=2
	  where tbl_id=18;


	  update statistics prtl.cache_poc3ab_params;
	  update statistics prtl.cache_poc3ab_aggr;

		end;
	

