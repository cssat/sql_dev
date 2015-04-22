
CREATE PROCEDURE [prtl].[sp_ia_safety](
   @date varchar(3000)
,  @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @cd_county varchar(1000)
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30) )
as
 set nocount on

 

    declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;
	declare @tblqryid table(qry_id int);


    declare @x1 float;
    declare @x2 float;

	declare @var_row_cnt_param int;
	declare @var_row_cnt_cache int;
    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();



	select  @mindate=min_date_any,@maxdate=max_date_any ,@minmonthstart=min_date_any,@maxmonthstart=max_date_any
	from  ref_lookup_max_date where procedure_name='sp_ia_safety'
   

   
			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
	     
			if OBJECT_ID('tempDB..#cnty') is not null drop table #cnty;
			create table #cnty(cd_cnty int,match_code int );
			create index idx_cnty_match_code on #cnty(match_code);
  
  			if OBJECT_ID('tempDB..#rpt') is not null drop table #rpt;
			create table #rpt(cd_reporter_type int,match_code int  ,primary key(cd_reporter_type,match_code));
			create index idx_reporter_match_code on #rpt(match_code)

			if OBJECT_ID('tempDB..#acc') is not null drop table #acc;
			create table #acc(cd_access_type int,match_code int  );
			create index idx_cd_access_type on #acc(cd_access_type,match_code)

			-- allegation tables
			if OBJECT_ID('tempDB..#alg') is not null drop table #alg;
			create table #alg(cd_allegation  int,match_code int ,primary key(cd_allegation,match_code));
			create index idx_algtn on #alg(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..#fnd') is not null drop table #fnd
			create table #fnd(cd_finding int,match_code int,primary key(cd_finding,match_code));
			create index idx_finding on #fnd(match_code)

		

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
	join dbo.fn_ReturnStrTableFromList(@cd_reporter_type,0) sel
	on cast(sel.arrValue as int)=rpt.cd_reporter_type

			
					
	update statistics #rpt		
		-----------------------------------   access_type --------------------------------------
	insert into #acc(cd_access_type,match_code)
	select  acc.cd_access_type,acc.match_code
	from prm_acc acc			
	join dbo.fn_ReturnStrTableFromList(@filter_access_type,0) sel
	on cast(sel.arrValue as int)=acc.cd_access_type


	update statistics #acc		;
	----------------------------------   ALLEGATIONS ---------------------------------------
	--  @filter_allegation	;
	insert into #alg(cd_allegation,match_code)
	select alg.cd_allegation,alg.match_code
	from prm_alg alg
	join dbo.fn_ReturnStrTableFromList(@filter_allegation,0) sel
	on cast(sel.arrValue as int)=alg.cd_allegation

	update statistics #alg
	------------------------------------  FINDINGS --------------------------------------
	--  	prm_fnd   @filter_finding
	
	insert into #fnd(cd_finding,match_code)
	select fnd.cd_finding,fnd.match_code
	from prm_fnd fnd
	join dbo.fn_ReturnStrTableFromList(@filter_finding,0) sel
	on cast(sel.arrValue as int)= fnd.cd_finding
				
	update statistics #fnd			

					

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
		select top 1 qry_id from prtl.cache_pbcs2_params
		where age_grouping_cd=left(@age_grouping_cd,20)
		and cd_race_census=left(@race_cd,30) 
		and cd_county=	left(@cd_county,250)   
		and cd_reporter_type=left(@cd_reporter_type,100)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		order by qry_ID desc
		);  


		if @qry_Id is null
			begin



			INSERT INTO [prtl].[cache_pbcs2_params]
					(qry_id
					, [age_grouping_cd]
					,[cd_race_census]
					,cd_county
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
						from prtl.[cache_pbcs2_params]),1)
					,@age_grouping_cd
					,@race_cd
					,@cd_county
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate();

					select @qry_id=qry_id from @tblqryid;
			end
		else
			begin
				update [prtl].[cache_pbcs2_params]
				set cnt_qry=cnt_qry + 1
				where qry_id= @qry_id;
			end



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
					,RAND(cast(NEWID() as varbinary))  x1 
					,RAND(cast(NEWID() as varbinary)) x2
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct cd_access_type from #acc) acc
				cross join (select distinct cd_allegation from #alg) alg
				cross join (select distinct cd_finding from #fnd) fnd


			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,in_cache);                   


			update cache
			set in_cache=1,qry_id=pbcs2.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_pbcs2] pbcs2
			on pbcs2.[int_all_param_key]=cache.int_hash_key


			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;

	if @var_row_cnt_param <> @var_row_cnt_cache
			begin



			if object_ID('tempDB..#families') is not null drop table #families
			select prtl_pbcs2.cohort_begin_date
				,prtl_pbcs2.qry_type
				,mtch.int_param_key
				,rpt.cd_reporter_type
				,acc.cd_access_type
				,alg.cd_allegation
				,fnd.cd_finding
				,sum(cnt_case) as total_families 
			into #families
			from prtl.prtl_pbcs2 
			join #prmlocdem mtch on mtch.int_match_param_key=prtl_pbcs2.int_match_param_key 
					and  mtch.cd_race_census in (select distinct cd_race from #eth)
				join #rpt rpt on rpt.match_code=prtl_pbcs2.cd_reporter_type
				join #acc acc on acc.match_code=prtl_pbcs2.filter_access_type
				join #alg alg on alg.match_code=prtl_pbcs2.filter_allegation
				join #fnd fnd on fnd.match_code=prtl_pbcs2.filter_finding
			where cohortrefcount=1
			group by cohort_begin_date,prtl_pbcs2.qry_type,mtch.int_param_key,rpt.cd_reporter_type,acc.cd_access_type
						,alg.cd_allegation,fnd.cd_finding


				if object_ID('tempDB..#mytemp') is not null drop table #mytemp;

						SELECT    s2.qry_type
								, s2.date_type 
								, s2.cohort_begin_date
								, mtch.int_param_key
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, mtch.age_grouping_cd 
								, mtch.cd_race_census
								, mtch.cd_cnty
								,n.mnth as [Months]
								,sum(IIF( q.total_families > 0 and n.mnth is not null, cnt_case , 0 ))
												/(q.total_families * 1.0000 ) * 100 [rate]
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								,ck.x1  
								, ck.x2
								, getdate() as insert_date
								, cast((mtch.int_param_key  * power(10.0,5)) as decimal(12,0))
									+ cast((rpt.cd_reporter_type  * power(10.0,3)) as decimal(12,0))
									+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(12,0))
									+  cast((alg.cd_allegation  * power(10.0,1)) as decimal(12,0))
									+ fnd.cd_finding as s2_int_hash_key
								,ck.qry_id
								,year(s2.cohort_begin_date) as cohort_year
							into #mytemp
							FROM prtl.prtl_pbcs2  S2
									join #prmlocdem mtch on mtch.int_match_param_key=s2.int_match_param_key 
									and  mtch.cd_race_census in (select distinct cd_race from #eth)
								join #rpt rpt on rpt.match_code=s2.cd_reporter_type
								join #acc acc on acc.match_code=s2.filter_access_type
								join #alg alg on alg.match_code=s2.filter_allegation
								join #fnd fnd on fnd.match_code=s2.filter_finding
								join #cachekeys ck on ck.int_hash_key=cast((mtch.int_param_key  * power(10.0,5)) as decimal(12,0))
									+ cast((rpt.cd_reporter_type  * power(10.0,3)) as decimal(12,0))
									+  cast((acc.cd_access_type  * power(10.0,2)) as decimal(12,0))
									+  cast((alg.cd_allegation  * power(10.0,1)) as decimal(12,0))
									+ fnd.cd_finding and ck.in_cache=0
								left join (select distinct number * 3 as mnth from dbo.numbers where number between 1 and 16 ) n on n.mnth>= [nxt_ref_within_min_month]
								join #families q 
									on q.cohort_begin_date=s2.cohort_begin_date
									and q.int_param_key=mtch.int_param_key
									and q.cd_access_type=acc.cd_access_type
									and q.cd_allegation=alg.cd_allegation
									and q.cd_finding=fnd.cd_finding
									and q.cd_reporter_type=rpt.cd_reporter_type
									and q.qry_type=s2.qry_type
						where s2.cohortrefcount=1  and s2.nxt_ref_within_min_month between 3 and 48
						and s2.cohort_begin_date between @mindate and @maxdate
						group by s2.qry_type
								, s2.date_type 
								, s2.cohort_begin_date
								, mtch.int_param_key
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, mtch.age_grouping_cd 
								, mtch.cd_race_census
								, mtch.cd_cnty
								,n.mnth ,q.total_families
								,ck.x1,ck.x2,ck.qry_id
						order by s2.qry_type
								, s2.date_type 
								, s2.cohort_begin_date
								, mtch.int_param_key
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, mtch.age_grouping_cd 
								, mtch.cd_race_census
								, mtch.cd_cnty
								,n.mnth 

									insert into prtl.cache_pbcs2_aggr 
									([qry_type]
									   ,[date_type]
									   ,[start_date]
									   ,[int_param_key]
									   ,[cd_reporter_type]
									   ,[cd_access_type]
									   ,[cd_allegation]
									   ,[cd_finding]
									   ,[cd_sib_age_grp]
									   ,[cd_race]
									   ,cd_county
									   ,[month]
									   ,[among_first_cmpt_rereferred]
									   ,[min_start_date]
									   ,[max_start_date]
									   ,[x1]
									   ,[x2]
									   ,[insert_date]
									   ,[int_hash_key]
									   ,[qry_id]
									   ,[start_year])
									select * from #mytemp;

						update statistics prtl.cache_pbcs2_aggr;

						insert into prtl.cache_qry_param_pbcs2
						([int_param_key]
						,[cd_sib_age_grp]
						,[cd_race]
						,cd_county
						,[cd_reporter_type]
						,[cd_access_type]
						,[cd_allegation]
						,[cd_finding]
						,[qry_id]
						,[int_all_param_key])

						select 
						ck.[int_param_key]
						,age_grouping_cd
						,cd_race_census
						,cd_cnty
						,[cd_reporter_type]
						,[cd_access_type]
						,[cd_allegation]
						,[cd_finding]
						,ck.qry_id
						,ck.int_hash_key
						from #cachekeys ck
						join (select distinct int_param_key
											, age_grouping_cd 
											, cd_race_census
											, cd_cnty
											from #prmlocdem) q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;


						update statistics prtl.cache_qry_param_pbcs2;

			end -- not in cache			
						


	SELECT  	 pbcs2.month as "Months"
							 ,pbcs2.qry_type   
								, pbcs2.start_year  as "Year"
								, pbcs2.cd_sib_age_grp as  "age_grouping_cd"
								, ref_age.tx_sib_age_grp as "Age Grouping"
								, pbcs2.cd_race  as "ethnicity_cd"
								, ref_eth.tx_race_census "Race/Ethnicity" 
								, pbcs2.cd_county as "county_cd"
								, ref_cnty.county_desc as County
								, pbcs2.cd_reporter_type
								, ref_rpt.tx_reporter_type as "Reporter Desc"
								, pbcs2.cd_access_type
								, ref_acc.tx_access_type as "Access type desc"
								, pbcs2.cd_allegation
								, ref_alg.tx_allegation as "Allegation"
								, pbcs2.cd_finding
								, ref_fnd.tx_finding "Finding"								
								, among_first_cmpt_rereferred as "Among first referrals, percent that are re-referred"
        from cache_pbcs2_aggr pbcs2
		 	join #cachekeys ck on ck.int_hash_key=pbcs2.int_hash_key
							and pbcs2.qry_id=ck.qry_id
			join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=pbcs2.cd_race
			join ref_filter_allegation ref_alg on ref_alg.cd_allegation=pbcs2.cd_allegation
			join ref_filter_finding ref_fnd on ref_fnd.cd_finding=pbcs2.cd_finding
            join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=pbcs2.cd_sib_age_grp
			join ref_lookup_county ref_cnty on ref_cnty.county_cd=pbcs2.cd_county
			join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcs2.cd_reporter_type
			join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcs2.cd_access_type
			join ref_last_dw_transfer dw on 1=1
           where dateadd(mm,12+pbcs2.[month],start_date) <= dw.cutoff_date
 						order by pbcs2.qry_type   
-- 								, pbcs2.date_type
								, pbcs2.start_year
								, pbcs2.cd_sib_age_grp
								, pbcs2.cd_race
								, pbcs2.cd_county 
								, pbcs2.cd_access_type
								, pbcs2.cd_reporter_type
								, pbcs2.cd_allegation
								, pbcs2.cd_finding
								, pbcs2.month;