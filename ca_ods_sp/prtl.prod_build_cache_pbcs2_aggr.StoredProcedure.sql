USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_pbcs2_aggr]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [prtl].[prod_build_cache_pbcs2_aggr](@permission_key datetime)
as
if @permission_key = (select cutoff_date from ref_Last_DW_Transfer )
begin
		declare @loop int
		declare @date varchar(50)
		declare @qry_id bigint
		declare @age_grouping_cd varchar(30)
		declare @race_cd varchar(30)
		declare @cd_office  varchar(200)
		declare  @cd_reporter_type varchar(100) 
		declare  @filter_access_type varchar(30) 
		declare  @filter_allegation  varchar(100)
		declare @filter_finding varchar(100)
		declare @max_qry_id int

		set @max_qry_id = (select max(qry_id) from prtl.cache_pbcs2_params where qry_id <=36 )

		
		set @date='2006-01-01,' + convert(varchar(10),(select dateadd(mm,-1,[month]) from dbo.calendar_dim where CALENDAR_DATE =(select cutoff_date from ref_Last_DW_Transfer)),121)
		
		
		truncate table prtl.cache_pbcs2_aggr;
		truncate table prtl.cache_qry_param_pbcs2;
		--truncate table prtl.cache_pbcs2_params;
		

		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.cache_pbcs2_params	where qry_id <=52;

		truncate table prtl.cache_pbcs2_params;

		set @loop =1 

		while @loop <=@max_qry_id
		begin


				SELECT @qry_id=[qry_ID]
					  ,@age_grouping_cd=[age_grouping_cd]
					  ,@race_cd=[cd_race_census]
					  ,@cd_office=cd_office
					  ,@cd_reporter_type=[cd_reporter_type]
					  ,@filter_access_type=[filter_access_type]
					  ,@filter_allegation=[filter_allegation]
					  ,@filter_finding=[filter_finding]
				FROM #params
				where qry_ID=@loop


 
				exec [prtl].[sp_cache_pbcs2_insert_only]
					@date  --  p_date
					,@age_grouping_cd
					,@race_cd
					,@cd_office
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
			

				set @loop=@loop + 1;
			end ;



	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcs2_aggr)
	  where tbl_id=34;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_pbcs2_params)
	  where tbl_id=35;

	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.cache_qry_param_pbcs2)
	  where tbl_id=36;


	  update statistics prtl.cache_pbcs2_params;
	  update statistics prtl.cache_pbcs2_aggr;
		 end;


GO
