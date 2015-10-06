


CREATE PROCEDURE [prtl].[sp_ooh_reentry](
   @date varchar(3000)
,  @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @gender_cd varchar(10)
,  @init_cd_plcm_setng varchar(30)
,  @long_cd_plcm_setng varchar(30) 
,  @county_cd varchar(200) 
,  @bin_los_cd varchar(30) 
,  @bin_placement_cd varchar(30) 
,  @bin_ihs_svc_cd varchar(30) 
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30)
, @filter_service_category  varchar(100)
, @filter_service_budget varchar(100)
, @bin_dep_cd varchar(20)
,@fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
)
as
 set nocount on
 /**  for qa only
 declare  @date varchar(3000)='2000-01-01,2013-01-01'
declare  @age_grouping_cd varchar(30)='0'
declare  @race_cd varchar(30)='0'
declare  @gender_cd varchar(10)='0'
declare  @init_cd_plcm_setng varchar(30)='0'
declare  @long_cd_plcm_setng varchar(30)= '0'
declare  @county_cd varchar(200)= '0'
declare  @bin_los_cd varchar(30)= '0'
declare  @bin_placement_cd varchar(30)= '0'
declare  @bin_ihs_svc_cd varchar(30)= '0'
declare  @cd_reporter_type varchar(100)= '0'
declare  @filter_access_type varchar(30)= '0'
declare  @filter_allegation  varchar(30)= '0'
declare @filter_finding varchar(30)= '0'
declare @filter_service_category  varchar(100)= '0'
declare @filter_service_budget varchar(100)= '0'
declare @bin_dep_cd varchar(20)= '0'
 	**/
	

    declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;
	declare @minfilterdate datetime;

	declare @tblqryid table(qry_id int);



	    

    -----------------------------------  set dates  -------------------------------------  		

    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_yr ,@mindate=min_date_any,@maxdate=max_date_yr
	FROM ref_lookup_max_date where id=9;
	
   
			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
			if OBJECT_ID('tempDB..#gdr') is not null drop table #gdr;
			create table #gdr(pk_gndr int,match_code int);
			create index idx_gdr_match_code on #gdr(match_code);
    

			if OBJECT_ID('tempDB..#fpl') is not null drop table #fpl;
			create table  #fpl(cd_plcm_setng int,match_code int );
			create index idx_fpl_match_code on #fpl(match_code);
    
    
			if OBJECT_ID('tempDB..#lpl') is not null drop table #lpl;
			create table  #lpl(cd_plcm_setng int,match_code int );
			create index idx_lpl_match_code on #lpl(match_code);
     
     
			if OBJECT_ID('tempDB..#cnty') is not null drop table #cnty;
			create table #cnty(cd_cnty int,match_code int );
			create index idx_cnty_match_code on #cnty(match_code);
     


			--- new filters
			if OBJECT_ID('tempDB..#los') is not null drop table #los;
			create table #los(bin_los_cd int,match_code int ,primary key(bin_los_cd,match_code));
			create index idx_los_match_code on #los(match_code)
			create index idx_los_match_code2 on #los(bin_los_cd)
    
			if OBJECT_ID('tempDB..#nbrplc') is not null drop table #nbrplc;
			create table #nbrplc(bin_placement_cd int,match_code int ,primary key(bin_placement_cd,match_code));
			create index idx_nbrplcm_match_code on #nbrplc(match_code)

			if OBJECT_ID('tempDB..#ihs') is not null drop table #ihs;
			create table #ihs(bin_ihs_svc_cd int,match_code int  ,primary key(bin_ihs_svc_cd,match_code));
			create index idx_ihs_match_code on #ihs(match_code)
    
			if OBJECT_ID('tempDB..#rpt') is not null drop table #rpt;
			create table #rpt(cd_reporter_type int,match_code int  ,primary key(cd_reporter_type,match_code));
			create index idx_reporter_match_code on #rpt(match_code)

			if OBJECT_ID('tempDB..#access_type') is not null drop table #access_type;
			create table #access_type(cd_access_type int,filter_access_type decimal(18,0),match_code int  );
			create index idx_cd_access_type on #access_type(cd_access_type,match_code)


	

			-- allegation tables
			if OBJECT_ID('tempDB..#algtn') is not null drop table #algtn;
			create table #algtn(cd_allegation  int,filter_allegation decimal(18,0),match_code decimal(18,0) ,primary key(cd_allegation,match_code));
			create index idx_algtn on #algtn(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..#find') is not null drop table #find
			create table #find(cd_finding int,filter_finding  decimal(18,0),match_code decimal(18,0) ,primary key(cd_finding,match_code));
			create index idx_finding on #find(match_code)

			-- service type flags	
			if object_ID('tempDB..#srvc') is not null drop table #srvc
			create table #srvc(cd_subctgry_poc_frc int, filter_srvc_type decimal(18,0),match_code decimal(18,0) ,primary key(cd_subctgry_poc_frc,match_code));
			create index idx_srvc on #srvc(match_code)
			-- budget type flags

			if object_ID('tempDB..#budg') is not null drop table #budg
				create table #budg(cd_budget_poc_frc int,filter_budget decimal(18,0),match_code decimal(18,0),primary key(cd_budget_poc_frc,match_code))
				create index idx_budg on #budg(match_code)


  			if object_ID('tempDB..#dep') is not null drop table #dep
				create table #dep(bin_dep_cd int,match_code decimal(18,0),primary key(bin_dep_cd,match_code))
				create index idx_dep on #dep(match_code)

	

				

		------------------------------------------------  AGE

		insert into #age(age_grouping_cd,match_code)
		select age_grouping_cd,match_code
		 from prm_age_cdc_census_mix 
		 join [dbo].[fn_ReturnStrTableFromList](@age_grouping_cd,0) 
			on cast(arrValue as int)=age_grouping_cd;

		update statistics #age;

		------------- race -----------------------------------------------------------------------------

		insert into #eth(cd_race,cd_origin,match_code)

		select eth.cd_race,eth.cd_origin,eth.match_code
		from prm_eth_census eth
		join [dbo].[fn_ReturnStrTableFromList](@race_cd,0) 
		on cast(arrValue as int)=eth.cd_race

		update statistics #eth

		---------------------------------------  GENDER ---------------------------------------  
		
		insert into #gdr(PK_GNDR,match_code)
		select pk_gndr,match_code
		from prm_gndr gdr
		join dbo.fn_ReturnStrTableFromList(@gender_cd,0)
		on cast(arrValue as int)=gdr.pk_gndr

		update statistics #gdr

		----------------------------------  FIRST PLACEMENT ------------------------------------------------------------

		insert into #fpl(cd_plcm_setng,match_code)
		select fpl.init_cd_plcm_setng,fpl.match_code
		from prm_fpl  fpl
		join dbo.fn_ReturnStrTableFromList(@init_cd_plcm_setng,0) sel on cast(sel.arrValue as int)=fpl.init_cd_plcm_setng

		update statistics #fpl

		----------------------------------  LONGEST PLACEMENT ------------------------------------------------------------
			insert into #lpl(cd_plcm_setng,match_code) 
		select lpl.long_cd_plcm_setng,lpl.match_code  
		from prm_lpl  lpl
		join dbo.fn_ReturnStrTableFromList(@long_cd_plcm_setng,0) sel on cast(sel.arrValue as int)=lpl.long_cd_plcm_setng


		update statistics #lpl

		---------------------------------------  County -------------------------
    
			insert into #cnty(cd_cnty,match_code)
			select  cnty.cd_cnty,cnty.match_code
			from prm_cnty cnty
			join dbo.fn_ReturnStrTableFromList(@County_Cd,0) sel on cast(sel.arrValue as int)=cnty.cd_cnty

			
		update statistics #cnty

		--------------------------------------------  LOS CODE --------------------------------------------------
			insert into #los(bin_los_cd ,match_code)
			select los.bin_los_cd,los.match_code from [dbo].[fn_ReturnStrTableFromList] (@bin_los_cd,0)
			join [prm_los_max_bin_los_cd] los on los.bin_los_cd=cast(arrValue as int);

			

			update statistics #los				
		-------------------------------------- PLACEMENT CODE ------------------------------
	
		insert into #nbrplc(bin_placement_cd,match_code)
		select plc.bin_placement_cd,plc.match_code
		from prm_plc plc
		join dbo.fn_ReturnStrTableFromList(@bin_placement_cd,0) sel
		on cast(sel.arrValue as int)=plc.bin_placement_cd

		update statistics #nbrplc
		-------------------------------------- IHS SRVC ------------------------------
		insert into #ihs(bin_ihs_svc_cd,match_code)
		select ihs.bin_ihs_svc_cd,ihs.match_code
		from prm_ihs ihs
		join dbo.fn_ReturnStrTableFromList(@bin_ihs_svc_cd,0) sel
		on cast(sel.arrValue as int)=ihs.bin_ihs_svc_cd

		update statistics #ihs
		------------------------------------  REPORTER FILTER ------------------------------

		insert into #rpt(cd_reporter_type,match_code)
		select rpt.cd_reporter_type,rpt.match_code
		from prm_rpt rpt
		join dbo.fn_ReturnStrTableFromList(@cd_reporter_type,0) sel
		on cast(sel.arrValue as int)=rpt.cd_reporter_type

			
					
				update statistics #rpt		
		-----------------------------------   access_type --------------------------------------
			insert into #access_type(cd_access_type,filter_access_type,match_code)
			select  acc.cd_access_type,acc.match_code,acc.match_code
			from prm_acc acc			
			join dbo.fn_ReturnStrTableFromList(@filter_access_type,0) sel
			on cast(sel.arrValue as int)=acc.cd_access_type


			update statistics #access_type		;
		----------------------------------   ALLEGATIONS ---------------------------------------
			insert into #algtn(cd_allegation,filter_allegation,match_code)
			select alg.cd_allegation,alg.match_code,alg.match_code
			from prm_alg alg
			join dbo.fn_ReturnStrTableFromList(@filter_allegation,0) sel
			on cast(sel.arrValue as int)=alg.cd_allegation

			update statistics #algtn
		------------------------------------  FINDINGS --------------------------------------
	
			insert into #find(cd_finding,filter_finding,match_code)
			select fnd.cd_finding,fnd.match_code,fnd.match_code
			from prm_fnd fnd
			join dbo.fn_ReturnStrTableFromList(@filter_finding,0) sel
			on cast(sel.arrValue as int)= fnd.cd_finding
				
			update statistics #find					

		-----------------------------------  services ---------------------------------------
		
			insert into #srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
			select srvc.cd_subctgry_poc_frc,srvc.match_code,srvc.match_code
			from prm_srvc srvc				
			join dbo.fn_ReturnStrTableFromList(@filter_service_category,0) sel
			on cast(sel.arrValue as int)=srvc.cd_subctgry_poc_frc

					

				update statistics #srvc					

		-----------------------------------  budget ---------------------------------------

			insert into #budg(cd_budget_poc_frc,filter_budget,match_code)
			select cd_budget_poc_frc,match_code,match_code
			from prm_budg bud
			join dbo.fn_ReturnStrTableFromList(@filter_service_budget,0) sel
			on cast(sel.arrValue as int)=bud.cd_budget_poc_frc		



				update statistics #budg

		-----------------------------------  dependency ---------------------------------------
			insert into #dep(bin_dep_cd ,match_code)
			select dep.bin_dep_cd,dep.match_code from [dbo].[fn_ReturnStrTableFromList] (@bin_dep_cd,0)
			join prm_dep dep on dep.bin_dep_cd=cast(arrValue as int);

			update statistics #dep;


select @minfilterdate = max(a.db_min_filter_date)
from (
	select max(d.min_filter_date) as 'db_min_filter_date'
	from ref_filter_dependency d
	inner join #dep td on td.bin_dep_cd = d.bin_dep_cd

	union

	select max(a.min_filter_date) as 'db_min_filter_date'
	from ref_filter_allegation a
	inner join #algtn at on at.cd_allegation = a.cd_allegation

	union

	select max(f.min_filter_date) as 'db_min_filter_date'
	from ref_filter_finding f
	inner join #find ft on ft.cd_finding = f.cd_finding

	union

    select max(e.min_filter_date) as 'db_min_filter_date'
    from ref_filter_access_type e
    inner join #access_type et on et.cd_access_type = e.cd_access_type
    
    union

	select cast('2000-01-01' as datetime) as 'db_min_filter_date'
) as a;


				---  load the demographic ,placement,location parameters --
 				if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
								,age_grouping_cd int not null
								,pk_gndr int not null
								,cd_race_census int not null
								,init_cd_plcm_setng int  not null
								,long_cd_plcm_setng int  not null
								,county_cd int not null
								,int_match_param_key int not null
								,match_age_grouping_cd int not null
								,match_pk_gdnr int not null
								,match_cd_race_census int not null
								,match_init_cd_plcm_setng int not null
								,match_long_cd_plcm_setng int not null
								,match_county_cd int not null
								,match_cd_hispanic_latino_origin int not null
								--,ooh_filter_in_cache_table tinyint not null default 0
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(
							int_param_key
							,age_grouping_cd
							,cd_race_census
							,pk_gndr
							,init_cd_plcm_setng
							,long_cd_plcm_setng
							,county_cd
							,int_match_param_key
							,match_age_grouping_cd
							,match_cd_race_census
							,match_cd_hispanic_latino_origin
							,match_pk_gdnr
							,match_init_cd_plcm_setng
							,match_long_cd_plcm_setng
							,match_county_cd)

					select  distinct

								 cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(age.age_grouping_cd,0)) + 
											(power(10.0,5) * coalesce(eth.cd_race,7)) +
												(power(10.0,4) * coalesce(gdr.pk_gndr,5)) + 
														(power(10.0,3) * fpl.cd_plcm_setng) +
															(power(10.0,2) * lpl.cd_plcm_setng) + 
																(power(10.0,0) * cnty.cd_cnty )
																as decimal(9,0)) as int_param_key
								, age.age_grouping_cd 
								, eth.cd_race as cd_race_census
								, gdr.pk_gndr
								, fpl.cd_plcm_setng as init_cd_plcm_setng
								, lpl.cd_plcm_setng as longest_cd_plcm_setng
								, cnty.cd_cnty as county_cd
								, cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(age.match_code,0)) + 
											(power(10.0,6) * coalesce(eth.match_code,7)) +
												(power(10.0,5) * coalesce(eth.cd_origin,5)) + 
													(power(10.0,4) * coalesce(gdr.match_code,3)) + 
														(power(10.0,3) * fpl.match_code) +
															(power(10.0,2) * lpl.match_code) + 
																(power(10.0,0) * (iif(coalesce(cnty.match_code,-99) 
																		not between 1 and 39 , 99 , cnty.match_code)))
																as decimal(9,0)) as int_match_param_key
								, age.match_code as match_age_grouping_cd 
								, eth.match_code as match_cd_race_census
								, eth.cd_origin as match_census_hispanic_latino_origin_cd
								, gdr.match_code as match_pk_gndr
								, fpl.match_code as match_init_cd_plcm_setng
								, lpl.match_code as match_longest_cd_plcm_setng
								, cnty.match_code as match_county_cd
					from #age age 
					cross join #eth eth
					cross join #gdr gdr
					cross join #fpl fpl
					cross join #lpl lpl
					cross join #cnty cnty ;
				
	   

	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,age_grouping_cd
						,cd_race_census
						,pk_gndr
						,init_cd_plcm_setng
						,long_cd_plcm_setng
						,county_cd)

					create index idx_int_match_cd_race_census on #prmlocdem(
						cd_race_census
						)

					create index idx_age_grouping_cd on #prmlocdem(
						age_grouping_cd
						)
 
					update statistics #prmlocdem



				set @qry_id=(
				select top 1 qry_id from prtl.cache_pbcp5_params
				where age_grouping_cd=left(@age_grouping_cd,20)
				and cd_race_census=left(@race_cd,30) 
				and pk_gndr=left(@gender_cd,10) 
				and init_cd_plcm_setng=left(@init_cd_plcm_setng,50) 
				and long_cd_plcm_setng=left(@long_cd_plcm_setng,50) 
				and county_cd=	left(@County_Cd,200)   
				and bin_dep_cd=left(@bin_dep_cd,20)
				and bin_los_cd=left(@bin_los_cd,30)
				and bin_placement_cd=left(@bin_placement_cd,30)
				and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
				and cd_reporter_type=left(@cd_reporter_type,100)
				and filter_access_type=left(@filter_access_type,30)
				and filter_allegation=left(@filter_allegation,30)
				and filter_finding=left(@filter_finding,30)
				and filter_srvc_type=left(@filter_service_category,50)
				and filter_budget=left(@filter_service_budget,50)
				order by qry_ID asc
				);  

	--  select @qry_id,@minmonthstart,@maxmonthstart
	


		if @qry_Id is null
		begin
		INSERT INTO [prtl].[cache_pbcp5_params]
					(qry_id
					, [age_grouping_cd]
					,[cd_race_census]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,[filter_access_type]
					,[filter_allegation]
					,[filter_finding]
					,[filter_srvc_type]
					,[filter_budget]
					,bin_dep_cd
					, min_start_date
					, max_start_date
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_pbcp5_params]),1)
					,@age_grouping_cd
					,@race_cd
					,@gender_cd
					,@init_cd_plcm_setng
					,@long_cd_plcm_setng
					,@county_cd
					,@bin_los_cd
					,@bin_placement_cd
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@filter_service_category
					,@filter_service_budget
					,@bin_dep_cd
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()
		
					select @qry_id=qry_id from @tblqryid;
				end -- if @qry_Id is null
		else -- if @qry_Id is null
			begin
						update prtl.cache_pbcp5_params
									set cnt_qry=cnt_qry + 1,last_run_date=getdate()
									where qry_id	=@qry_id			
			end
			-- see if results are in cache as a subset of previously run query


		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;

		   select	(int_param_key	* power(10.0,13)) + 
					(bin_dep_cd	* power(10.0,12)) +
					(bin_los_cd	* power(10.0,11)) +
					(bin_placement_cd	* power(10.0,10)) +
					(bin_ihs_svc_cd	* power(10.0,9)) +
					(cd_reporter_type	* power(10.0,7)) +
					(cd_access_type	* power(10.0,6)) +
					(cd_allegation	* power(10.0,5)) +
					(cd_finding	* power(10.0,4)) +
					(cd_subctgry_poc_frc	* power(10.0,2)) +
					(cd_budget_poc_frc	* power(10.0,0)) as int_hash_key
					 ,int_param_key
					 ,bin_dep_cd
					 ,bin_los_cd
					 ,bin_placement_cd
					 ,bin_ihs_svc_cd
					 ,cd_reporter_type
					 ,cd_access_type
					 ,cd_allegation
					 ,cd_finding
					 ,cd_subctgry_poc_frc
					 ,cd_budget_poc_frc
					 ,0 as in_cache
					 ,@qry_id as qry_id
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct bin_dep_cd from #dep) dep
				cross join (select distinct bin_los_cd from #los) los
				cross join (select distinct bin_placement_cd from #nbrplc) plc
				cross join (select distinct bin_ihs_svc_cd from #ihs) ihs
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd
				cross join (select distinct cd_subctgry_poc_frc from #srvc) srvc
				cross join (select distinct cd_budget_poc_frc from #budg) budg

			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,cd_budget_poc_frc,cd_subctgry_poc_frc,in_cache);                   
			
			update cache
			set in_cache=1,qry_id=pbcp5.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_pbcp5] pbcp5
			on pbcp5.int_hash_key=cache.int_hash_key



			if NOT (select count(*) from #cachekeys )=(select sum(in_cache) from #cachekeys)
			begin
						---  print 'qry_id is '  + str(@qry_id) 
								if OBJECT_ID('tempDB..#total') is not null drop table #total;
								select  
												prtl_pbcp5.cohort_exit_year
												,prtl_pbcp5.date_type
												,prtl_pbcp5.qry_type
												,prtl_pbcp5.cd_discharge_type
												,dep.bin_dep_cd
												,mtch.int_param_key
												,los.bin_los_cd
												,plc.bin_placement_cd
												,ihs.bin_ihs_svc_cd
												,rpt.cd_reporter_type
												,acc.cd_access_type
												,alg.cd_allegation
												,fnd.cd_finding
												,srv.cd_subctgry_poc_frc
												,bud.cd_budget_poc_frc
												,cast(sum(cohort_count) * 1.0000 as decimal(9,4))  as tot_episodes
										into #total
										from prtl.prtl_pbcp5 
										join #prmlocdem mtch on mtch.int_match_param_key=prtl_pbcp5.int_match_param_key 
										join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
										join #los los on los.match_code=prtl_pbcp5.max_bin_los_cd
										join #nbrplc plc on plc.match_code=prtl_pbcp5.bin_placement_cd
										join #ihs ihs on ihs.match_code=prtl_pbcp5.bin_ihs_svc_cd
										join #rpt rpt on rpt.match_code=prtl_pbcp5.cd_reporter_type
										join #access_type acc on acc.match_code=prtl_pbcp5.filter_access_type
										join #algtn alg on alg.match_code=prtl_pbcp5.filter_allegation
										join #find fnd on fnd.match_code=prtl_pbcp5.filter_finding
										join #srvc srv on srv.match_code=prtl_pbcp5.filter_service_category
										join #budg bud on bud.match_code=prtl_pbcp5.filter_service_budget
										join #dep dep on dep.match_code=prtl_pbcp5.bin_dep_cd
										group by 	prtl_pbcp5.cohort_exit_year
												,prtl_pbcp5.date_type
												,prtl_pbcp5.qry_type
												,dep.bin_dep_cd
												,mtch.int_param_key
												,los.bin_los_cd
												,plc.bin_placement_cd
												,ihs.bin_ihs_svc_cd
												,rpt.cd_reporter_type
												,acc.cd_access_type
												,alg.cd_allegation
												,fnd.cd_finding
												,srv.cd_subctgry_poc_frc
												,bud.cd_budget_poc_frc													
												,prtl_pbcp5.cd_discharge_type;

				if object_Id('tempDB..#mytemp') is not null drop table #mytemp;
						SELECT    prtl_pbcp5.qry_type
								, prtl_pbcp5.date_type 
								, prtl_pbcp5.[cohort_exit_year]
								, prtl_pbcp5.cd_discharge_type
								, mtch.int_param_key
								, dep.bin_dep_cd
								, los.bin_los_cd
								, plc.bin_placement_cd
								, ihs.bin_ihs_svc_cd
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, srv.cd_subctgry_poc_frc
								, bud.cd_budget_poc_frc
								, mtch.age_grouping_cd 
								, mtch.cd_race_census
								, mtch.pk_gndr
								, mtch.init_cd_plcm_setng
								, mtch.long_cd_plcm_setng
								, mtch.county_cd
								, mnth as reentry_within_month
								, sum(prtl_pbcp5.discharge_count)/(tot_cohort.tot_episodes) * 100 as reentry_rate
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								, rand(convert(varbinary, newid())) [x1]
								, rand(convert(varbinary, newid())) [x2]
								, getdate() as insert_date
								,che.qry_id as qry_id
								,year(prtl_pbcp5.cohort_exit_year) as exit_year
								,int_hash_key
								, sum(prtl_pbcp5.discharge_count) as reentry_cnt
								, tot_cohort.tot_episodes
							into #mytemp
							FROM prtl.prtl_pbcp5  
								join #prmlocdem mtch on mtch.int_match_param_key=prtl_pbcp5.int_match_param_key 
								join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
								join #los los on prtl_pbcp5.max_bin_los_cd=los.match_code
								join #nbrplc plc on plc.match_code=prtl_pbcp5.bin_placement_cd
								join #ihs ihs on ihs.match_code=prtl_pbcp5.bin_ihs_svc_cd
								join #rpt rpt on rpt.match_code=prtl_pbcp5.cd_reporter_type
								join #access_type acc on acc.match_code=prtl_pbcp5.filter_access_type
								join #algtn alg on alg.match_code=prtl_pbcp5.filter_allegation
								join #find fnd on fnd.match_code=prtl_pbcp5.filter_finding
								join #srvc srv on srv.match_code=prtl_pbcp5.filter_service_category
								join #budg bud on bud.match_code=prtl_pbcp5.filter_service_budget
								join #dep dep on dep.match_code=prtl_pbcp5.bin_dep_cd
								join #total   tot_cohort on tot_cohort.cohort_exit_year=prtl_pbcp5.cohort_exit_year
										and tot_cohort.qry_type=prtl_pbcp5.qry_type
										and tot_cohort.date_type=prtl_pbcp5.date_type
										and tot_cohort.cd_discharge_type=prtl_pbcp5.cd_discharge_type
										and tot_cohort.bin_dep_cd=dep.bin_dep_cd
										and tot_cohort.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
										and tot_cohort.bin_los_cd=los.bin_los_cd
										and tot_cohort.bin_placement_cd=plc.bin_placement_cd
										and tot_cohort.cd_access_type=acc.cd_access_type
										and tot_cohort.cd_allegation=alg.cd_allegation
										and tot_cohort.cd_finding=fnd.cd_finding
										and tot_cohort.cd_reporter_type=rpt.cd_reporter_type
										and tot_cohort.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
										and tot_cohort.cd_budget_poc_frc=bud.cd_budget_poc_frc
										and tot_cohort.int_param_key=mtch.int_param_key
							 join #cachekeys che on che.int_param_key = mtch.int_param_key
													and che.bin_dep_cd=dep.bin_dep_cd
													and che.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
													and che.bin_los_cd=los.bin_los_cd
													and che.bin_placement_cd=plc.bin_placement_cd
													and che.cd_reporter_type=rpt.cd_reporter_type
													and che.cd_allegation=alg.cd_allegation
													and che.cd_finding=fnd.cd_finding
													and che.cd_access_type=acc.cd_access_type
													and che.cd_budget_poc_frc=bud.cd_budget_poc_frc
													and che.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
													and che.in_cache=0
							group by  prtl_pbcp5.qry_type
									,prtl_pbcp5.date_type 
									,prtl_pbcp5.cohort_exit_year
									, prtl_pbcp5.cd_discharge_type
									,year(prtl_pbcp5.cohort_exit_year)
									,mtch.int_param_key
									,mtch.age_grouping_cd 
									,mtch.pk_gndr
									,mtch.cd_race_census
									,mtch.init_cd_plcm_setng
									,mtch.long_cd_plcm_setng
									,mtch.county_cd
									, dep.bin_dep_cd
									, los.bin_los_cd
									, plc.bin_placement_cd
									, ihs.bin_ihs_svc_cd
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									, fnd.cd_finding
									, srv.cd_subctgry_poc_frc
									, bud.cd_budget_poc_frc 
									, tot_cohort.tot_episodes
									, che.int_hash_key
									,che.qry_id
									, mnth 
							order by  prtl_pbcp5.qry_type
									,prtl_pbcp5.date_type 
									,prtl_pbcp5.cohort_exit_year
									, prtl_pbcp5.cd_discharge_type
									,year(prtl_pbcp5.cohort_exit_year)
									,mtch.int_param_key
									,mtch.age_grouping_cd 
									,mtch.pk_gndr
									,mtch.cd_race_census
									,mtch.init_cd_plcm_setng
									,mtch.long_cd_plcm_setng
									,mtch.county_cd
									, dep.bin_dep_cd
									, los.bin_los_cd
									, plc.bin_placement_cd
									, ihs.bin_ihs_svc_cd
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									, fnd.cd_finding
									, srv.cd_subctgry_poc_frc
									, bud.cd_budget_poc_frc 
									, mnth 
						
						
						
						
						
						insert into prtl.cache_pbcp5_aggr( 
								[qry_type]
								,[date_type]
								,[cohort_exit_year]
								 ,cd_discharge_type
								,[int_param_key]
								,[bin_dep_cd]
								,[bin_los_cd]
								,[bin_placement_cd]
								,[bin_ihs_svc_cd]
								,[cd_reporter_type]
								,[cd_access_type]
								,[cd_allegation]
								,[cd_finding]
								,[cd_subctgry_poc_frc]
								,[cd_budget_poc_frc]
								,[age_grouping_cd]
								,[cd_race]
								,[pk_gndr]
								,[init_cd_plcm_setng]
								,[long_cd_plcm_setng]
								,[county_cd]
								,reentry_within_month
								, reentry_rate
								,[min_start_date]
								,[max_start_date]
								,[x1]
								,[x2]
								,[insert_date]
								,qry_id
								,exit_year
								,int_all_param_key
								,reentry_count
								,total_count)
							select * from #mytemp;

							drop table #mytemp;


						--	commit tran t1;
						--	set @exit_year=@exit_year + 1;
						--end -- insert loop

						update statistics prtl.cache_pbcp5_aggr

						INSERT INTO [prtl].[cache_qry_param_pbcp5]
								   ([int_param_key]
								   ,bin_dep_cd
								   ,[bin_los_cd]
								   ,[bin_placement_cd]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
								   ,[cd_subctgry_poc_frc]
								   ,[cd_budget_poc_frc]
								   ,[age_grouping_cd]
								   ,[cd_race]
								   ,[pk_gndr]
								   ,[init_cd_plcm_setng]
								   ,[long_cd_plcm_setng]
								   ,[county_cd]
								   ,[qry_id]
								   ,[int_hash_key])
						select ck.[int_param_key]
									,bin_dep_cd
								   ,[bin_los_cd]
								   ,[bin_placement_cd]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
								   ,[cd_subctgry_poc_frc]
								   ,[cd_budget_poc_frc]
								   ,[age_grouping_cd]
								   ,[cd_race_census]
								   ,[pk_gndr]
								   ,[init_cd_plcm_setng]
								   ,[long_cd_plcm_setng]
								   ,[county_cd]
								   ,ck.qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;




						
	
						update statistics prtl.cache_qry_param_pbcp5;

						
					  end -- not in cache
						
			if @fl_return_results=1	
				
				     select    					  
                  pbcp5.cohort_exit_year as "Cohort Entry Date"
                            , qry_type "qry_type_poc1_first_unique"
                            , pbcp5.date_type
                            , pbcp5.age_grouping_cd
                            , ref_age.age_grouping  "Age Grouping"
                            , pbcp5.cd_race as ethnicity_cd
                            , ref_eth.tx_race_census   "Race/Ethnicity" 
                            , pbcp5.pk_gndr as gender_cd
                            , ref_gdr.tx_gndr  "Gender" 
                            , pbcp5.init_cd_plcm_setng  
                            , ref_fpl.tx_plcm_setng  "Initial Placement"
                            , pbcp5.long_cd_plcm_setng  
                            , ref_lpl.tx_plcm_setng   "Longest Placement"
                            , pbcp5.county_cd
                            , ref_cnty.county_desc as "County"
                            , pbcp5.bin_dep_cd as  "dependency_cd"
                            , ref_dep.bin_dep_desc as "Dependency"
                            , pbcp5.bin_los_cd
                            , ref_los.bin_los_desc as "Length of Service Desc"                               
                            , pbcp5.bin_placement_cd
                            , ref_plc.bin_placement_desc  "Placement Count Desc"
                            , pbcp5.bin_ihs_svc_cd
                            , ref_ihs.bin_ihs_svc_tx "In-Home Service Desc"
                            , pbcp5.cd_reporter_type
                            , ref_rpt.tx_reporter_type as "Reporter Desc"
                            , pbcp5.cd_access_type
                            , ref_acc.tx_access_type as "Access type desc"
                            , pbcp5.cd_allegation
                            , ref_alg.tx_allegation "Allegation"  
                            , pbcp5.cd_finding
                            , ref_fnd.tx_finding   "Finding"
                            , pbcp5.cd_subctgry_poc_frc as "service_type_cd"
                            , ref_srv.tx_subctgry_poc_frc as "Service Type"
                            , pbcp5.cd_budget_poc_frc   "budget_cd"
                            , ref_bud.tx_budget_poc_frc  "Budget"
                , pbcp5.cd_discharge_type
                            , toe.discharge_type as "Discharge Type"
                , reentry_within_month as "Month"
                , reentry_rate as "Reentry Percent"
            from prtl.cache_pbcp5_aggr pbcp5 
            join #cachekeys ck on ck.int_hash_key=pbcp5.int_all_param_key
                and ck.qry_id=pbcp5.qry_id
			join ref_last_dw_transfer on 1=1
            join [ref_lookup_cd_discharge_type_exits] toe on toe.cd_discharge_type=pbcp5.cd_discharge_type
 						join vw_ref_dependency_lag ref_dep on ref_dep.bin_dep_cd=pbcp5.bin_dep_cd 
						and ref_dep.date_type=pbcp5.date_type 
									and pbcp5.cohort_exit_year between @minfilterdate and cohort_max_filter_date
						join ref_filter_los ref_los on ref_los.bin_los_cd=pbcp5.bin_los_cd
						and  dateadd(dd,abs(ref_los.lag) ,dateadd(mm,9,dateadd(dd,-1,dateadd(yy,1,pbcp5.cohort_exit_year))))<= cutoff_date			
			join [dbo].[ref_age_cdc_census_mix]  ref_age on ref_age.age_grouping_cd=pbcp5.age_grouping_cd
			join ref_lookup_gender ref_gdr on ref_gdr.[pk_gndr]=pbcp5.pk_gndr
			join ref_lookup_ethnicity_census ref_eth on ref_eth.[cd_race_census] = pbcp5.cd_race
			join [dbo].[ref_lookup_plcmnt]  ref_fpl on ref_fpl.[cd_plcm_setng] = pbcp5.init_cd_plcm_setng
			join [dbo].[ref_lookup_plcmnt]  ref_lpl on ref_lpl.[cd_plcm_setng] = pbcp5.long_cd_plcm_setng
            join ref_lookup_county ref_cnty on ref_cnty.county_cd=pbcp5.county_cd
			join [dbo].[ref_filter_nbr_placement] ref_plc on ref_plc.[bin_placement_cd]=pbcp5.[bin_placement_cd]
            join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcp5.cd_reporter_type
			join ref_filter_ihs_services ref_ihs on ref_ihs.[bin_ihs_svc_cd]=pbcp5.bin_ihs_svc_cd
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcp5.cd_access_type
			join ref_filter_allegation ref_alg on ref_alg.cd_allegation=pbcp5.cd_allegation
			join ref_filter_finding ref_fnd on ref_fnd.cd_finding=pbcp5.cd_finding
            join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=pbcp5.cd_subctgry_poc_frc
            join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=pbcp5.cd_budget_poc_frc
			where dateadd(mm,( 12 + pbcp5.reentry_within_month) ,pbcp5.cohort_exit_year) <= cutoff_date
            order by 
                pbcp5.bin_dep_cd asc
                ,qry_type
                ,pbcp5.date_type
                ,cohort_exit_year asc
                ,age_grouping_cd asc
                    ,gender_cd asc
                    ,ethnicity_cd asc
                    ,init_cd_plcm_setng asc
                    ,long_cd_plcm_setng asc
                    ,county_cd asc
                    , pbcp5.bin_los_cd asc
                    , pbcp5.bin_placement_cd asc
                    , pbcp5.bin_ihs_svc_cd asc
                    , pbcp5.cd_reporter_type
                    , pbcp5.cd_access_type
                    , pbcp5.cd_allegation
                    , pbcp5.cd_finding
                    , pbcp5.cd_subctgry_poc_frc
                    , pbcp5.cd_budget_poc_frc
            ,pbcp5.reentry_within_month asc
            ,pbcp5.cd_discharge_type asc;
				

