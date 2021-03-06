USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[sp_cache_poc2ab_counts]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [prtl].[sp_cache_poc2ab_counts](
  @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @cd_office varchar(1000)
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30) )
as
 set nocount on



	--declare @date varchar(3000)
	--declare @age_grouping_cd varchar(30)
	--declare @race_cd varchar(30)
	--declare @gender_cd varchar(10)
	--declare @cd_office  varchar(250)
	--declare  @cd_reporter_type varchar(100) 
	--declare  @filter_access_type varchar(30) 
	--declare  @filter_allegation  varchar(100)
	--declare @filter_finding varchar(100)

	

	--set @date='1/1/2006,07/31/2013'
	--set @age_grouping_cd='0'
	----set @age_grouping_cd='1,2,3,4'
	----set @race_cd='0'
	--set @race_cd='0'
	----  set @gender_cd='0'
	--set @cd_office='0'
	--set @cd_reporter_type='0'
	--set @filter_access_type='0'
	--set @filter_allegation='0'
	--set @filter_finding='0'

	
	 declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;


	declare @cache_qry_id int;
    declare @x1 float;
    declare @x2 float;

	declare @var_row_cnt_param int;
	declare @var_row_cnt_cache int;
    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();



	select  @mindate=min_date_any,@maxdate=max_date_any ,@minmonthstart=min_date_any,@maxmonthstart=max_date_any
	from  ref_lookup_max_date where id=18


   

   
			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,tx_race varchar(200),match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
	     
     
			if OBJECT_ID('tempDB..#ofc') is not null drop table #ofc;
			create table #ofc(cd_office int,tx_office varchar(200),match_code int );
				create index idx_ofc_match_code on #ofc(match_code);
     


			--- new filters
		
   
			if OBJECT_ID('tempDB..#rpt') is not null drop table #rpt;
			create table #rpt(cd_reporter_type int,match_code int  ,primary key(cd_reporter_type,match_code));
			create index idx_reporter_match_code on #rpt(match_code)

			if OBJECT_ID('tempDB..#access_type') is not null drop table #access_type;
			create table #access_type(cd_access_type int,match_code int  );
			create index idx_cd_access_type on #access_type(cd_access_type,match_code)


	

			-- allegation tables
			if OBJECT_ID('tempDB..#algtn') is not null drop table #algtn;
			create table #algtn(cd_allegation  int,match_code decimal(18,0) ,primary key(cd_allegation,match_code));
			create index idx_algtn on #algtn(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..#find') is not null drop table #find
			create table #find(cd_finding int,match_code decimal(18,0) ,primary key(cd_finding,match_code));
			create index idx_finding on #find(match_code)

	

		------------------------------------------------  AGE

		insert into #age(age_grouping_cd,match_code)
		select cd_sib_age_grp,match_code
		from prm_cd_sib_age_grp age
		join dbo.fn_ReturnStrTableFromList(@age_grouping_cd,0) tmp on age.cd_sib_age_grp=cast(tmp.arrValue as int);


		update statistics #age

		

		------------- race -----------------------------------------------------------------------------
	insert into #eth(cd_race,cd_origin,match_code)

	select eth.cd_race,eth.cd_origin,eth.match_code
	from prm_eth_census eth
	join [dbo].[fn_ReturnStrTableFromList](@race_cd,0) 
	on cast(arrValue as int)=eth.cd_race

	update statistics #eth
	
	
		---------------------------------------  OFFICE -------------------------
    
    insert into #ofc(cd_office,match_code)
	select  ofc.cd_office,match_code
	from prm_office_collapse ofc
	join dbo.fn_ReturnStrTableFromList(@cd_office,0) tmp on tmp.arrValue=ofc.cd_office

	update statistics #ofc

	
		------------------------------------  REPORTER FILTER ------------------------------

	insert into #rpt(cd_reporter_type,match_code)
	select rpt.cd_reporter_type,rpt.match_code
	from prm_rpt rpt
	join dbo.fn_ReturnStrTableFromList(@cd_reporter_type,0) sel
	on cast(sel.arrValue as int)=rpt.cd_reporter_type

			
					
	update statistics #rpt		
		-----------------------------------   access_type --------------------------------------
	insert into #access_type(cd_access_type,match_code)
	select  acc.cd_access_type,acc.match_code
	from prm_acc acc			
	join dbo.fn_ReturnStrTableFromList(@filter_access_type,0) sel
	on cast(sel.arrValue as int)=acc.cd_access_type


	update statistics #access_type		;
	----------------------------------   ALLEGATIONS ---------------------------------------
	--  @filter_allegation	;
	insert into #algtn(cd_allegation,match_code)
	select alg.cd_allegation,alg.match_code
	from prm_alg alg
	join dbo.fn_ReturnStrTableFromList(@filter_allegation,0) sel
	on cast(sel.arrValue as int)=alg.cd_allegation

	update statistics #algtn
	------------------------------------  FINDINGS --------------------------------------
	--  	prm_fnd   @filter_finding
	
	insert into #find(cd_finding,match_code)
	select fnd.cd_finding,fnd.match_code
	from prm_fnd fnd
	join dbo.fn_ReturnStrTableFromList(@filter_finding,0) sel
	on cast(sel.arrValue as int)= fnd.cd_finding
				
	update statistics #find			

					

 				if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
									,int_match_param_key int not null
								,age_grouping_cd int not null
								,cd_race_census int not null
								,cd_office int not null
								,match_age_grouping_cd int not null
								,match_cd_race_census int not null
								,match_cd_hispanic_latino_origin int not null
								,match_cd_office int not null
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(int_param_key,int_match_param_key,age_grouping_cd
										,cd_race_census
							,cd_office							
							,match_age_grouping_cd
							,match_cd_race_census
							,match_cd_hispanic_latino_origin
							,match_cd_office)

					select distinct
						 power(10,6) 
              + (age_grouping_cd *  power(10,5))
              + (cd_race *  power(10,3))
              + (abs(cd_office)) int_param_key 
						,power(10,6) 
              + (age.match_code *  power(10,5))
              + (eth.match_code *  power(10,4))
              + (eth.cd_origin * power(10,3))
              + (abs(ofc.match_code))int_match_param_key
						,age.age_grouping_cd cd_sib_age_grp
						,eth.cd_race cd_race_census
						,ofc.cd_office
						,age.match_code match_cd_sib_age_grp
						,eth.match_code match_cd_race_census
						,eth.cd_origin match_cd_hispanic_latino_origin
						,ofc.match_code match_cd_office
					from  #age age 
            cross join  #eth eth 
            cross join #ofc ofc 

        
	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,age_grouping_cd
						,cd_race_census
						,cd_office)

					create index idx_int_match_cd_race_census on #prmlocdem(
						cd_race_census
						)

					create index idx_age_grouping_cd on #prmlocdem(
						age_grouping_cd
						)
 
					update statistics #prmlocdem


		set @qry_id=(
		select top 1 qry_id from prtl.cache_poc2ab_params
		where age_grouping_cd=left(@age_grouping_cd,20)
		and cd_race_census=left(@race_cd,30) 
		and cd_office=	left(@cd_office,250)   
		and cd_reporter_type=left(@cd_reporter_type,100)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		order by qry_ID desc
		);  


		if @qry_Id is null
			begin

			INSERT INTO [prtl].[cache_poc2ab_params]
					(qry_id
					, [age_grouping_cd]
					,[cd_race_census]
					,[cd_office]
					,[cd_reporter_type]
					,[filter_access_type]
					,[filter_allegation]
					,[filter_finding]
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
				select 
					isnull((select max(qry_id)+1 from prtl.cache_poc2ab_params),1)
					,@age_grouping_cd
					,@race_cd
					,@cd_office
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()
			end
		else
			begin
				update [prtl].[cache_poc2ab_params]
				set cnt_qry=cnt_qry + 1
				where qry_id= @qry_id;
			end
			
						
	select @qry_id=max(qry_id) 
			from prtl.cache_poc2ab_params
			where age_grouping_cd=left(@age_grouping_cd,20)
			and cd_race_census=left(@race_cd,30) 
			and cd_office=	left(@cd_office,250)   
			and cd_reporter_type=left(@cd_reporter_type,100)
			and filter_access_type=left(@filter_access_type,30)
			and filter_allegation=left(@filter_allegation,30)
			and filter_finding=left(@filter_finding,30);
	

				-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;

		   select cast((int_param_key  * power(10.0,5)) as decimal(12,0))
			+ cast((rpt.cd_reporter_type  * power(10.0,3)) as decimal(12,0))
			+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(12,0))
			+  cast((alg.cd_allegation  * power(10.0,1)) as decimal(12,0))
			+ fnd.cd_finding  as int_hash_key
					 ,int_param_key
					 ,cd_reporter_type
					 ,cd_access_type
					 ,cd_allegation
					 ,cd_finding
					 ,0 as in_cache
					 ,@qry_id as qry_id
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd


			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,in_cache);                   

				
			update cache
			set in_cache=1,qry_id=poc2ab.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_poc2ab] poc2ab
			on poc2ab.[int_all_param_key]=cache.int_hash_key
			
	
			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;

	if @var_row_cnt_param <> @var_row_cnt_cache
			begin

									 
			declare @start_year int
			declare @start_year_stop int 
			set @start_year = year(@minmonthstart)
			set @start_year_stop = (select year(cutoff_date) from ref_Last_DW_Transfer);


		
							insert into prtl.cache_poc2ab_aggr( 
								[qry_type]
								,[date_type]
								,[start_date]
								,[int_param_key]
								,[cd_reporter_type]
								,[cd_access_type]
								,[cd_allegation]
								,[cd_finding]
								,cd_sib_age_grp
								,[cd_race]
								,cd_office
								,[cnt_start_date]
								,[cnt_opened]
								,[cnt_closed]
								,[min_start_date]
								,[max_start_date]
								,[x1]
								,[x2]
								,[insert_date]
								,int_all_param_key
								,qry_id
								,start_year)

						SELECT    prtl_poc2ab.qry_type
								, prtl_poc2ab.date_type 
								, prtl_poc2ab.[start_date]
								, mtch.int_param_key
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, mtch.cd_sib_age_grp 
								, mtch.cd_race_census
								, mtch.cd_office
								, isnull(sum(prtl_poc2ab.cnt_start_date),0) as cnt_start_date
								, isnull(sum(prtl_poc2ab.cnt_opened),0) as cnt_opened
								, isnull(sum(prtl_poc2ab.cnt_closed),0) as cnt_closed
								--, '2000-01-01' as minmonthstart
								--, '2013-07-01' as maxmonthstart
								--, null as x1
								--, null   as x2
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								, @x1 as x1  
								, @x2   as x2
								, getdate() as insert_date
								, cast((mtch.int_param_key  * power(10.0,5)) as decimal(12,0))
									+ cast((rpt.cd_reporter_type  * power(10.0,3)) as decimal(12,0))
									+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(12,0))
									+  cast((alg.cd_allegation  * power(10.0,1)) as decimal(12,0))
									+ fnd.cd_finding
								,@qry_id
								,prtl_poc2ab.[start_year]
							FROM prtl.prtl_poc2ab  
								join #prmlocdem mtch on mtch.int_match_param_key=prtl_poc2ab.int_match_param_key 
								join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
								join #rpt rpt on rpt.match_code=prtl_poc2ab.cd_reporter_type
								join #access_type acc on acc.match_code=prtl_poc2ab.fl_cps_invs
								join #algtn alg on alg.match_code=prtl_poc2ab.filter_allegation
								join #find fnd on fnd.match_code=prtl_poc2ab.filter_finding
								join #cachekeys ck on ck.int_hash_key=cast((mtch.int_param_key  * power(10.0,5)) as decimal(12,0))
									+ cast((rpt.cd_reporter_type  * power(10.0,3)) as decimal(12,0))
									+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(12,0))
									+  cast((alg.cd_allegation  * power(10.0,1)) as decimal(12,0))
									+ fnd.cd_finding and ck.in_cache=0
							where prtl_poc2ab.[start_year] between @start_year and @start_year_stop
								
							group by  prtl_poc2ab.qry_type
									,prtl_poc2ab.date_type 
									,prtl_poc2ab.[start_date]
									,prtl_poc2ab.[start_year]
									,mtch.int_param_key
									,mtch.cd_sib_age_grp 
									,mtch.cd_race_census
									,mtch.cd_office
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									, fnd.cd_finding
							
							set @start_year=@start_year + 1;
					

						update statistics prtl.cache_poc2ab_aggr;
		
						insert into prtl.cache_qry_param_poc2ab
						([int_param_key]
						,[cd_sib_age_grp]
						,[cd_race]
						,[cd_office]
						,[cd_reporter_type]
						,[cd_access_type]
						,[cd_allegation]
						,[cd_finding]
						,[qry_id]
						,[int_all_param_key])
		
						select 
						ck.[int_param_key]
						,[cd_sib_age_grp]
						,cd_race_census
						,[cd_office]
						,[cd_reporter_type]
						,[cd_access_type]
						,[cd_allegation]
						,[cd_finding]
						,ck.qry_id
						,ck.int_hash_key
						from #cachekeys ck
						join (select distinct int_param_key
											, cd_sib_age_grp 
											, cd_race_census
											, cd_office
											from #prmlocdem) q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;
						
						
						update statistics prtl.cache_qry_param_poc2ab;

						
					  end -- if @qry_id is null
							SELECT  
								poc2ab.qry_type as   "qry_type_poc2"
								, poc2ab.date_type
								, poc2ab.start_date  as "Month"
								, poc2ab.cd_sib_age_grp as  "Age_Grouping_Cd"
								, ref_age.tx_sib_age_grp as "Age Grouping"
								, poc2ab.cd_race  as "Ethnicity_Cd"
								, ref_eth.tx_race_census as "Race/Ethnicity" 
								, poc2ab.cd_office as "Office_Cd"
								, ref_ofc.tx_office as Office
								, poc2ab.cd_reporter_type
								, ref_rpt.tx_reporter_type as [Reporter Desc]
								, poc2ab.cd_access_type
								, ref_acc.tx_access_type as [Access type desc]
								, poc2ab.cd_allegation
								, ref_alg.tx_allegation as [Allegation]
								, poc2ab.cd_finding
								, ref_fnd.tx_finding as [Finding]
								, case when (cnt_start_date) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_start_date) 
									end  as   "Total Cases First Day"
								, case when (cnt_opened) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_opened) 
									end as "Opened Cases"
								,  case when ( --  first day + entered care < exited care
									(case when (cnt_start_date) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_start_date) 
									end)
									+
									(case when (cnt_opened) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_opened) 
									end)) >= -- exited care
										(case when (cnt_closed) > 0 /* jitter all above 0 */ 
											then 
												case when (round(cnt_closed + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
												then 1
												else round(cnt_closed + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
												end
											else cnt_closed
										end)
                    
									then -- use exits as they are
									(case when (cnt_closed) > 0 /* jitter all above 0 */ 
											then 
												case when (round(cnt_closed + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
												then 1
												else round(cnt_closed + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
												end
											else cnt_closed
										end)
									else -- use first day plus entered
									(case when (cnt_start_date) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_start_date + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_start_date) 
									end)
									+
									(case when (cnt_opened) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_opened + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_opened) 
									end)
								end as "Case Closures"
						FROM prtl.cache_poc2ab_aggr poc2ab  
						join #cachekeys ck on ck.int_hash_key=poc2ab.int_all_param_key
						join (select distinct cd_reporter_type from #rpt) rpt on rpt.cd_reporter_type=poc2ab.cd_reporter_type
						join (select distinct cd_access_type from #access_type) acc on acc.cd_access_type=poc2ab.cd_access_type
						join (select distinct cd_allegation from #algtn) alg on alg.cd_allegation=poc2ab.cd_allegation
						join (select distinct cd_finding from #find) fnd on fnd.cd_finding=poc2ab.cd_finding
						join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=poc2ab.cd_sib_age_grp
						join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc2ab.cd_race
						join ref_lookup_office_collapse ref_ofc on ref_ofc.cd_office=poc2ab.cd_office
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc2ab.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc2ab.cd_access_type
						join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc2ab.cd_allegation
						join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc2ab.cd_finding
            where poc2ab.start_date   between @mindate and @maxdate
			order by date_type,qry_type,start_date;


	
						

			






 
 

GO
