USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_ooh_cache_tables]    Script Date: 6/26/2014 3:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [prtl].[prod_build_ooh_cache_tables](@permission_key datetime, @prm_procedure_id int)
as
--  @prm_procedure_id is ID from ref_lookup_max_date :  0 means run all
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
			declare @bin_dep_cd varchar(20)
			declare @max_qry_id int
			declare @mysql varchar(5000)
			declare @flag_run_all_procedures  int
			declare @procedure_id int
			declare @loop_procedure int;
			declare @stop_loop_procedure int;
			declare @tbl_id varchar(2);
			declare @tbl_name varchar(300)
			--declare @prm_procedure_id int
			-- for testing
	--		set @procedure_id=0
	--	set @prm_procedure_id=19
		set @procedure_id=@prm_procedure_id
		set @flag_run_all_procedures=0;	
		if  @procedure_id=0 set  @flag_run_all_procedures=1 


		set @max_qry_id = (select  max(qry_id) from  prtl.cache_ooh_params_backup )
		
		
		set @date='2000-01-01,' + convert(varchar(10),(select dateadd(mm,-1,[month]) from dbo.calendar_dim 
				where CALENDAR_DATE =(select cutoff_date from ref_Last_DW_Transfer)),121)
		
		



		if OBJECT_ID('tempDB..#params') is not null drop table #params
		select *
		into #params
		from prtl.cache_ooh_params_backup	
		where  qry_id <=@max_qry_id 
		order by qry_id asc

		set @mysql='';
		set @loop=1;
		while @loop <=3
		begin
		set @mysql=@mysql + 'truncate table prtl.'
		set @mysql=@mysql + (select top 1 tbl_name from prtl.tbl_procedure_xwalk where procedure_id=@procedure_id  and tbl_seq_nbr=@loop ) + ';' +  char(13) + char(10)
		--select @mysql
		exec (@mysql);
		set @mysql=''; 
		set @loop+=1;
		end

		


		if object_ID('tempDB..#procs') is not null drop table #procs;
		select id [procedure_id],[procedure_name] name,ROW_NUMBER() over (order by id) sort_key 
		 into #procs from ref_lookup_max_date where is_current=1
			and charindex('ooh',[procedure_name])>0 and charindex('rate',[procedure_name])=0  and charindex('pvt',[procedure_name])=0 order by id


		set @loop_procedure=(select sort_key from #procs where procedure_id=@procedure_id);
		set @stop_loop_procedure=(select sort_key from #procs where procedure_id=@procedure_id);



		if @flag_run_all_procedures=1 
				begin
						set @loop_procedure=1 ;
						 select @stop_loop_procedure=max(sort_key) from #procs;
				 end;
			

	while @loop_procedure <=@stop_loop_procedure
	begin
			set @loop =1 
			select @procedure_id=procedure_id from #procs where sort_key=@loop_procedure;
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

				
						if @procedure_id in  (19,24,25) and @age_grouping_cd='1,2,3,4,5,6,7' set @age_grouping_cd='1,2,3,4';
				
						set @mysql='exec prtl.'
						set   @mysql=@mysql + (select [procedure_name] from ref_lookup_max_Date where id=@procedure_id);

						set @mysql = @mysql + char(13) + char(10)  ;
						set @mysql=@mysql +   char(39) + @date   +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @age_grouping_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @race_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @gender_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @init_cd_plcm_setng +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @long_cd_plcm_setng +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @County_Cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @bin_los_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @bin_placement_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @bin_ihs_svc_cd +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) +  @cd_reporter_type +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @filter_access_type +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @filter_allegation +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @filter_finding +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @filter_service_category +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @filter_service_budget +   char(39) + char(13) + char(10) + ',';
						set @mysql=@mysql +   char(39) + @bin_dep_cd +   char(39) + char(13) + char(10) + ',0';

						exec  (@mysql);
						set @mysql='';
						set @loop+= 1;
				end ;
				set @loop_procedure+=1;
				set @loop=1;
				while @loop <=3
				begin
					set @mysql=' ';
						
					set @mysql=@mysql + 'update prtl.prtl_tables_last_update' + char(13) + char(10)
					set @mysql=@mysql + 'set last_build_date=getdate()'  + char(13) + char(10)
					set @mysql=@mysql + ',row_count=(select count(*) from prtl.'  + ((select xwlk.tbl_name from prtl.prtl_tables_last_update  tbl join prtl.tbl_procedure_xwalk xwlk on tbl.tbl_id=xwlk.tbl_id where xwlk.procedure_id=@procedure_id and tbl_seq_nbr=@loop ) ) +  ')' + char(13) + char(10)
					set @mysql=@mysql +'where tbl_id='  +   ((select convert(varchar(2),xwlk.tbl_id)  from prtl.prtl_tables_last_update  tbl join prtl.tbl_procedure_xwalk xwlk on tbl.tbl_id=xwlk.tbl_id where procedure_id=@procedure_id and tbl_seq_nbr=@loop ))  + char(13) + char(10)
					exec (@mysql);
					
					set @loop+=1;
			end;
	 end;
end
