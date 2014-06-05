USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_poc2ab_aggr]    Script Date: 6/4/2014 7:26:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [prtl].[prod_build_cache_poc2ab_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
		declare @loop int
		declare @qry_id bigint
		declare @age_grouping_cd varchar(30)
		declare @race_cd varchar(30)
		declare @cd_county  varchar(200)
		declare  @cd_reporter_type varchar(100) 
		declare  @filter_access_type varchar(30) 
		declare  @filter_allegation  varchar(100)
		declare @filter_finding varchar(100)
		declare @max_qry_id int
		declare @rc int
		select @max_qry_id=max(qry_id) from [prtl].[ia_params_backup]

		
		
		
		truncate table prtl.cache_poc2ab_aggr;
		truncate table prtl.cache_qry_param_poc2ab;
		truncate table prtl.cache_poc2ab_params;
		

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.[ia_params_backup]	where qry_id <=@max_qry_id;



		set @loop =1 

		while @loop <=@max_qry_id
		begin


				SELECT @qry_id=[qry_ID]
					  ,@age_grouping_cd=[age_grouping_cd]
					  ,@race_cd=[cd_race_census]
					  ,@cd_county=cd_county
					  ,@cd_reporter_type=[cd_reporter_type]
					  ,@filter_access_type=[filter_access_type]
					  ,@filter_allegation=[filter_allegation]
					  ,@filter_finding=[filter_finding]
				FROM #params
				where qry_ID=@loop


 
				exec @rc= [prtl].[sp_cache_poc2ab_counts_insert_only]
					 @age_grouping_cd
					,@race_cd
					,@cd_county
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
			

				set @loop=@loop + 1;
			end ;



	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc2ab_aggr)
	  where tbl_id=13;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_poc2ab_params)
	  where tbl_id=14;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_poc2ab)
	  where tbl_id=15;


	  update statistics prtl.cache_poc2ab_params;
	  update statistics prtl.cache_poc2ab_aggr;
		 end;
	

