

CREATE PROCEDURE [prtl].[sp_cache_poc3ab_counts_insert_only](
    @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @cd_county varchar(1000)
,  @bin_ihs_svc_cd varchar(30) 
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30)
 )
as
 set nocount on

    declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;

	declare @var_row_cnt_param int
	declare @var_row_cnt_cache int;

	declare @tblqryid table(qry_id int);
    declare @x1 float;
    declare @x2 float;
    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();


    -----------------------------------  set dates  -------------------------------------  		
    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any  ,@mindate=min_date_any,@maxdate=max_date_any
	FROM ref_lookup_max_date where id=22;

	
   
			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
		

			if OBJECT_ID('tempDB..#cnty') is not null drop table #cnty;
			create table #cnty(cd_cnty int,match_code int );
			create index idx_cnty_match_code on #cnty(match_code);

			if OBJECT_ID('tempDB..#ihs') is not null drop table #ihs;
			create table #ihs(bin_ihs_svc_cd int,match_code int  ,primary key(bin_ihs_svc_cd,match_code));
			create index idx_ihs_match_code on #ihs(match_code)
    
			if OBJECT_ID('tempDB..#rpt') is not null drop table #rpt;
			create table #rpt(cd_reporter_type int,match_code int  ,primary key(cd_reporter_type,match_code));
			create index idx_reporter_match_code on #rpt(match_code)

			if OBJECT_ID('tempDB..#access_type') is not null drop table #access_type;
			create table #access_type(cd_access_type int,match_code int  );
			create index idx_cd_access_type on #access_type(cd_access_type,match_code)

			-- allegation tables
			if OBJECT_ID('tempDB..#algtn') is not null drop table #algtn;
			create table #algtn(cd_allegation  int,match_code int ,primary key(cd_allegation,match_code));
			create index idx_algtn on #algtn(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..#find') is not null drop table #find
			create table #find(cd_finding int,match_code int ,primary key(cd_finding,match_code));
			create index idx_finding on #find(match_code)

		
		------------------------------------------------  AGE

		insert into #age(age_grouping_cd,match_code)
		select cd_sib_age_grp,match_code
		from prm_cd_sib_age_grp age
		join dbo.fn_ReturnStrTableFromList(@age_grouping_cd,1) tmp on age.cd_sib_age_grp=cast(tmp.arrValue as int);


		update statistics #age

		

		------------- race -----------------------------------------------------------------------------
	insert into #eth(cd_race,cd_origin,match_code)

	select eth.cd_race,eth.cd_origin,eth.match_code
	from prm_eth_census eth
	join [dbo].[fn_ReturnStrTableFromList](@race_cd,1) 
	on cast(arrValue as int)=eth.cd_race

	update statistics #eth
	
		---------------------------------------  County -------------------------
    
			insert into #cnty(cd_cnty,match_code)
			select  cnty.cd_cnty,cnty.match_code
			from prm_cnty cnty
			join dbo.fn_ReturnStrTableFromList(@cd_county,0) sel on cast(sel.arrValue as int)=cnty.cd_cnty

			
		update statistics #cnty

	
		------------------------------------  REPORTER FILTER ------------------------------

	insert into #rpt(cd_reporter_type,match_code)
	select rpt.cd_reporter_type,rpt.match_code
	from prm_rpt rpt
	join dbo.fn_ReturnStrTableFromList(@cd_reporter_type,1) sel
	on cast(sel.arrValue as int)=rpt.cd_reporter_type

			
					
	update statistics #rpt		
		-----------------------------------   access_type --------------------------------------
	insert into #access_type(cd_access_type,match_code)
	select  acc.cd_access_type,acc.match_code
	from prm_acc acc			
	join dbo.fn_ReturnStrTableFromList(@filter_access_type,1) sel
	on cast(sel.arrValue as int)=acc.cd_access_type


	update statistics #access_type		;
	----------------------------------   ALLEGATIONS ---------------------------------------
	--  @filter_allegation	;
	insert into #algtn(cd_allegation,match_code)
	select alg.cd_allegation,alg.match_code
	from prm_alg alg
	join dbo.fn_ReturnStrTableFromList(@filter_allegation,1) sel
	on cast(sel.arrValue as int)=alg.cd_allegation

	update statistics #algtn
	------------------------------------  FINDINGS --------------------------------------
	--  	prm_fnd   @filter_finding
	
	insert into #find(cd_finding,match_code)
	select fnd.cd_finding,fnd.match_code
	from prm_fnd fnd
	join dbo.fn_ReturnStrTableFromList(@filter_finding,1) sel
	on cast(sel.arrValue as int)= fnd.cd_finding
				
	update statistics #find			

		-------------------------------------- IHS SRVC ------------------------------
	insert into #ihs(bin_ihs_svc_cd,match_code)
	select ihs.bin_ihs_svc_cd,ihs.match_code
	from prm_ihs ihs
	join dbo.fn_ReturnStrTableFromList(@bin_ihs_svc_cd,0) sel
	on cast(sel.arrValue as int)=ihs.bin_ihs_svc_cd

	update statistics #ihs



				---  load the demographic ,placement,location parameters --
					if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
									,int_match_param_key int not null
								,age_grouping_cd int not null
								,cd_race_census int not null
								,cd_cnty int not null
								,match_age_grouping_cd int not null
								,match_cd_race_census int not null
								,match_cd_hispanic_latino_origin int not null
								,match_cd_cnty int not null
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(int_param_key,int_match_param_key,age_grouping_cd
										,cd_race_census
							,cd_cnty							
							,match_age_grouping_cd
							,match_cd_race_census
							,match_cd_hispanic_latino_origin
							,match_cd_cnty)

					select distinct
						 power(10,6) 
              + (age_grouping_cd *  power(10,5))
              + (cd_race *  power(10,3))
              + (abs(cd_cnty)) int_param_key 
						,power(10,6) 
              + (age.match_code *  power(10,5))
              + (eth.match_code *  power(10,4))
              + (eth.cd_origin * power(10,3))
              + (abs(cnty.match_code))int_match_param_key
						,age.age_grouping_cd cd_sib_age_grp
						,eth.cd_race cd_race_census
						,cnty.cd_cnty
						,age.match_code match_cd_sib_age_grp
						,eth.match_code match_cd_race_census
						,eth.cd_origin match_cd_hispanic_latino_origin
						,cnty.match_code match_cd_cnty
					from  #age age 
            cross join  #eth eth 
            cross join #cnty cnty

        
	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,age_grouping_cd
						,cd_race_census
						,cd_cnty)

					create index idx_int_match_cd_race_census on #prmlocdem(
						cd_race_census
						)

					create index idx_age_grouping_cd on #prmlocdem(
						age_grouping_cd
						)
 
					update statistics #prmlocdem




		set @qry_id=(
		select top 1 qry_id from prtl.cache_poc3ab_params
		where cd_sib_age_grp=left(@age_grouping_cd,20)
					and cd_race_census=left(@race_cd,30) 
					and cd_county=	left(@cd_county,250)   
					and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
					and cd_reporter_type=left(@cd_reporter_type,100)
					and filter_access_type=left(@filter_access_type,30)
					and filter_allegation=left(@filter_allegation,30)
					and filter_finding=left(@filter_finding,30)
		order by qry_ID desc
		);  


		if @qry_Id is null
		begin

			INSERT INTO [prtl].[cache_poc3ab_params]
					(qry_id
					, cd_sib_age_grp
					,[cd_race_census]
					,cd_county
					,bin_ihs_svc_cd
					,[cd_reporter_type]
					,[filter_access_type]
					,[filter_allegation]
					,[filter_finding]
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_poc3ab_params]),1)
					,@age_grouping_cd
					,@race_cd
					,@cd_county
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()

					select @qry_id=qry_id from @tblqryid;
			end
		else
			begin

					update prtl.cache_poc3ab_params
						set cnt_qry=cnt_qry + 1,last_run_date=getdate()
						where @qry_id=qry_id	
			end;
	
								 
								 
								 		
			-- see if results are in cache as a subset of previously run query
			-- if so get that qry_id
			if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;

		   select (cast((int_param_key  * power(10.0,6)) as decimal(22,0))
			+ cast((rpt.cd_reporter_type  * power(10.0,4)) as decimal(22,0))
			+ cast((ihs.bin_ihs_svc_cd * power(10.0, 3)) as decimal(22,0))
			+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(22,0))
			+  cast((alg.cd_allegation  * 10.0) as decimal(22,0))
			+  fnd.cd_finding ) as int_hash_key
					 ,int_param_key
					 ,cd_reporter_type
					 , bin_ihs_svc_cd
					 ,cd_access_type
					 ,cd_allegation
					 ,cd_finding
					 ,0 as in_cache
					 ,@qry_id as qry_id
					 ,RAND(cast(newid() as varbinary)) x1
					 ,RAND(cast(newid() as varbinary)) x2
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct bin_ihs_svc_cd from #ihs) ihs
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd


			update cache
			set in_cache=1,qry_id=poc3ab.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_poc3ab] poc3ab
			on poc3ab.int_hash_key=cache.int_hash_key

			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,in_cache);

			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;


		if @var_row_cnt_param <> @var_row_cnt_cache
			begin
				insert into prtl.cache_poc3ab_aggr ( 
					[qry_type]
					,[date_type]
					,[start_date]
					,[int_param_key]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,[cd_access_type]
					,[cd_allegation]
					,[cd_finding]
					,cd_sib_age_grp
					,cd_race_census
					,cd_county
					,[cnt_start_date]
					,cnt_opened
					,cnt_closed
					,[min_start_date]
					,[max_start_date]
					,[x1]
					,[x2]
					,[insert_date]
					,qry_id
					,start_year
					,int_hash_key) 

				SELECT    prtl_poc3ab.qry_type
						, prtl_poc3ab.date_type 
						, prtl_poc3ab.[start_date]
						, mtch.int_param_key
						, ihs.bin_ihs_svc_cd
						, rpt.cd_reporter_type
						, acc.cd_access_type
						, alg.cd_allegation
						, fnd.cd_finding
						, mtch.age_grouping_cd 
						, mtch.cd_race_census
						, mtch.cd_cnty
						, isnull(sum(prtl_poc3ab.cnt_start_date),0) as cnt_start_date
						, isnull(sum(prtl_poc3ab.cnt_opened),0) as cnt_opened
						, isnull(sum(prtl_poc3ab.cnt_closed),0) as cnt_closed
						--, '2000-01-01' as minmonthstart
						--, '2013-07-01' as maxmonthstart
						--, null as x1
						--, null   as x2
						, @minmonthstart as minmonthstart
						, @maxmonthstart as maxmonthstart
						, che.x1
						, che.x2
						, getdate() as insert_date
						,che.qry_id
						,prtl_poc3ab.[start_year]
						, che.int_hash_key
					FROM prtl.prtl_poc3ab  
						join #prmlocdem mtch on mtch.int_match_param_key=prtl_poc3ab.int_match_param_key 
						join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
						join #ihs ihs on ihs.match_code=prtl_poc3ab.bin_ihs_svc_cd
						join #rpt rpt on rpt.match_code=prtl_poc3ab.cd_reporter_type
						join #access_type acc on acc.match_code=prtl_poc3ab.filter_access_type
						join #algtn alg on alg.match_code=prtl_poc3ab.filter_allegation
						join #find fnd on fnd.match_code=prtl_poc3ab.filter_finding
						join #cachekeys che on che.int_param_key = mtch.int_param_key
									and che.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
										and che.cd_reporter_type=rpt.cd_reporter_type
									and che.cd_allegation=alg.cd_allegation
									and che.cd_finding=fnd.cd_finding
									and che.cd_access_type=acc.cd_access_type
						and che.in_cache=0
					where prtl_poc3ab.start_date between @minmonthstart and @maxmonthstart
					group by  prtl_poc3ab.qry_type
							,prtl_poc3ab.date_type 
							,prtl_poc3ab.[start_date]
							,prtl_poc3ab.[start_year]
							,mtch.int_param_key
							,mtch.age_grouping_cd 
							,mtch.cd_race_census
							,mtch.cd_cnty
							, ihs.bin_ihs_svc_cd
							, rpt.cd_reporter_type
							, acc.cd_access_type
							, alg.cd_allegation
							, fnd.cd_finding
							, che.int_hash_key
							,che.qry_id
							,che.x1
							,che.x2;

						update cache_poc3ab_aggr
						set cache_poc3ab_aggr.fl_include_perCapita=0
						from prtl.cache_poc3ab_aggr,prm_household_census_population   
						where exists(select * from #cachekeys ck where ck.qry_id=cache_poc3ab_aggr.qry_id)
							and prm_household_census_population.measurement_year=start_year
							and prm_household_census_population.county_cd=cache_poc3ab_aggr.cd_county 
							and prm_household_census_population.cd_race=cache_poc3ab_aggr.cd_race_census
							and prm_household_census_population.cd_sib_age_grp=cache_poc3ab_aggr.cd_sib_age_grp
							and  (cache_poc3ab_aggr.cnt_start_date *1.00 >   pop_cnt * .35  			
									or cache_poc3ab_aggr.cnt_opened *1.00 >   pop_cnt * .35  	
									or cache_poc3ab_aggr.cnt_closed * 1.00 > pop_cnt*.35);


				insert into prtl.cache_qry_param_poc3ab
					
					select ck.[int_param_key]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
								   ,q.age_grouping_cd
								   ,q.[cd_race_census]
								   ,q.cd_cnty
								   ,@qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,cd_cnty from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;
			end -- inner insert loop
	
update statistics prtl.cache_poc3ab_aggr
											



			

			


						--			SELECT  
						--		poc3ab.qry_type as   "qry_type_poc1"
						--		, poc3ab.date_type
						--		, poc3ab.start_date  as "Month"
						--		, poc3ab.cd_sib_age_grp as  "Age_Grouping_Cd"
						--		, ref_age.tx_sib_age_grp as "Age Grouping"
						--		, poc3ab.cd_race_census  as "Ethnicity_Cd"
						--		, ref_eth.tx_race_census as "Race/Ethnicity" 
		 			--			, poc3ab.cd_office_collapse as "Office_Cd"
						--		, ref_ofc.tx_office as Office

						--		, poc3ab.bin_ihs_svc_cd
						--		, ref_ihs.bin_ihs_svc_tx as [In-Home Service Desc]
						--		, poc3ab.cd_reporter_type
						--		, ref_rpt.tx_reporter_type as [Reporter Desc]
						--		, poc3ab.cd_access_type
						--		, ref_acc.tx_access_type as [Access type desc]
						--		, poc3ab.cd_allegation
						--		, ref_alg.tx_allegation as [Allegation]
						--		, poc3ab.cd_finding
						--		, ref_fnd.tx_finding as [Finding]
						--		, case when (cnt_start_date) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_start_date) 
						--			end  as   "Total In Care First Day"
						--		, case when (cnt_opened) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_opened) 
						--			end as "Number of Entries"
						--		,  case when ( --  first day + entered care < exited care
						--			(case when (cnt_start_date) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_start_date) 
						--			end)
						--			+
						--			(case when (cnt_opened) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_opened) 
						--			end)) >= -- exited care
						--				(case when (cnt_closed) > 0 /* jitter all above 0 */ 
						--					then 
						--						case when (round(cnt_closed + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--						then 1
						--						else round(cnt_closed + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--						end
						--					else cnt_closed
						--				end)
                    
						--			then -- use exits as they are
						--			(case when (cnt_closed) > 0 /* jitter all above 0 */ 
						--					then 
						--						case when (round(cnt_closed + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--						then 1
						--						else round(cnt_closed + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--						end
						--					else cnt_closed
						--				end)
						--			else -- use first day plus entered
						--			(case when (cnt_start_date) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_start_date + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_start_date) 
						--			end)
						--			+
						--			(case when (cnt_opened) > 0 /* jitter all above 0 */ 
						--				then 
						--					case when (round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0) ) <1
						--					then 1
						--					else round(cnt_opened + 2 * sqrt(-2 * log(poc3ab.x1)) * cos(2*pi()*poc3ab.x2),0)
						--					end
						--				else (cnt_opened) 
						--			end)
						--		end as "Number of Exits"
						--FROM prtl.cache_poc3ab_aggr poc3ab  
						-- join (select distinct int_param_key from #prmlocdem ) prm on prm.int_param_key=poc3ab.int_param_key
						--join (select distinct bin_ihs_svc_cd from #ihs) ihs on ihs.bin_ihs_svc_cd=poc3ab.bin_ihs_svc_cd
						--join (select distinct cd_reporter_type from #rpt) rpt on rpt.cd_reporter_type=poc3ab.cd_reporter_type
						--join (select distinct cd_access_type from #access_type) acc on acc.cd_access_type=poc3ab.cd_access_type
						--join (select distinct cd_allegation from #algtn) alg on alg.cd_allegation=poc3ab.cd_allegation
						--join (select distinct cd_finding from #find) fnd on fnd.cd_finding=poc3ab.cd_finding
						--join (select distinct cd_subctgry_poc_frc from #srvc) srv on srv.cd_subctgry_poc_frc=poc3ab.cd_service_type
						--join (select distinct cd_budget_poc_frc from #budg) bud on bud.cd_budget_poc_frc=poc3ab.cd_budget_type
						--join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=poc3ab.cd_sib_age_grp
						--join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc3ab.cd_race_census
						--join ref_lookup_office_collapse ref_ofc on ref_ofc.cd_office=poc3ab.cd_office_collapse
						--join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc3ab.bin_ihs_svc_cd
						--join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc3ab.cd_reporter_type
						--join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc3ab.cd_access_type
						--join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc3ab.cd_allegation
						--join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc3ab.cd_finding
      --      where poc3ab.start_date   between @mindate and @maxdate;
			



 
 

