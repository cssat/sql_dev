﻿--/****** Object:  StoredProcedure [prtl].[sp_ooh_pit_counts]    Script Date: 6/19/2014 2:24:18 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


CREATE PROCEDURE [prtl].[sp_ooh_pit_counts](
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
-- declare  @date varchar(3000)
--declare @age_grouping_cd varchar(30)
--declare @race_cd varchar(30)
--declare @gender_cd varchar(10)
--declare @init_cd_plcm_setng varchar(30)
--declare @long_cd_plcm_setng varchar(30) 
--declare @county_cd varchar(200) 
--declare @bin_los_cd varchar(30) 
--declare @bin_placement_cd varchar(30) 
--declare @bin_ihs_svc_cd varchar(30) 
--declare @cd_reporter_type varchar(100) 
--declare @filter_access_type varchar(30) 
--declare @filter_allegation  varchar(30)
--declare @filter_finding varchar(30)
--declare @filter_service_category  varchar(100)
--declare @filter_service_budget varchar(100)
--declare @bin_dep_cd varchar(20)
--declare @fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
--set @date = '2000-01-01,2014-04-01'
--set @age_grouping_cd='1'
--set @race_cd='8'
--set @gender_cd='0'
--set @init_cd_plcm_setng='0'
--set @long_cd_plcm_setng='0'
--set @county_cd='0'
--set @bin_los_cd='0'
--set @bin_placement_cd='0'
--set @bin_ihs_svc_cd='0'
--set @cd_reporter_type='0'
--set @filter_access_type='0'
--set @filter_allegation='0'
--set @filter_finding='0'
--set  @filter_service_category='0'
--set @filter_service_budget= '0'
--set @bin_dep_cd='0'
--set @fl_return_results=0

   declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
		declare @tblqryid table(qry_id int)
	declare @var_row_cnt_param int;
	declare @var_row_cnt_cache int;
	declare @minfilterdate datetime;
    declare @x1 float;
    declare @x2 float;

    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();


			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
			if OBJECT_ID('tempDB..#gdr') is not null drop table #gdr;
			create table #gdr(pk_gndr int,match_code int);
			create index idx_gdr_match_code on #gdr(match_code);
    
			--alter table #gdr add primary key(match_code);
			--create index idx_gndr_match on #gdr(pk_gndr,match_code,cd_gndr);
			if OBJECT_ID('tempDB..#fpl') is not null drop table #fpl;
			create table  #fpl(cd_plcm_setng int,match_code int );
			--alter table #fpl add primary key(match_code);
			--create index idx_fpl_match on #fpl(cd_plcm_setng,tx_plcm_setng);
			create index idx_fpl_match_code on #fpl(match_code);
    
    
			if OBJECT_ID('tempDB..#lpl') is not null drop table #lpl;
			create table  #lpl(cd_plcm_setng int,match_code int );
			--alter table #lpl add primary key (match_code);
			--create index idx_lpl_match on #lpl(cd_plcm_setng,tx_plcm_setng);
			create index idx_lpl_match_code on #lpl(match_code);
     
     
			if OBJECT_ID('tempDB..#cnty') is not null drop table #cnty;
			create table #cnty(cd_cnty int,match_code int );
			--alter table #cnty add primary key(match_code);
			--create index #cnty on idx_cnty_match(cd_cnty,tx_cnty);
    
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
    --  @filter_allegation	;
			insert into #algtn(cd_allegation,filter_allegation,match_code)
			select alg.cd_allegation,alg.match_code,alg.match_code
			from prm_alg alg
			join dbo.fn_ReturnStrTableFromList(@filter_allegation,0) sel
			on cast(sel.arrValue as int)=alg.cd_allegation

			update statistics #algtn
		------------------------------------  FINDINGS --------------------------------------
	--  	prm_fnd   @filter_finding
	
			insert into #find(cd_finding,filter_finding,match_code)
			select fnd.cd_finding,fnd.match_code,fnd.match_code
			from prm_fnd fnd
			join dbo.fn_ReturnStrTableFromList(@filter_finding,0) sel
			on cast(sel.arrValue as int)= fnd.cd_finding
				
			update statistics #find					

		-----------------------------------  services ---------------------------------------
		--  prm_srvc		 @filter_service_category
		
			insert into #srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
			select srvc.cd_subctgry_poc_frc,srvc.match_code,srvc.match_code
			from prm_srvc srvc				
			join dbo.fn_ReturnStrTableFromList(@filter_service_category,0) sel
			on cast(sel.arrValue as int)=srvc.cd_subctgry_poc_frc

					

				update statistics #srvc					

		-----------------------------------  budget ---------------------------------------

	--   @filter_service_budget;
			insert into #budg(cd_budget_poc_frc,filter_budget,match_code)
			select cd_budget_poc_frc,match_code,match_code
			from prm_budg bud
			join dbo.fn_ReturnStrTableFromList(@filter_service_budget,0) sel
			on cast(sel.arrValue as int)=bud.cd_budget_poc_frc		



				update statistics #budg

-- dependency
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
	
 				if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
									,int_match_param_key int not null
					 
								,age_grouping_cd int not null
								,pk_gndr int not null
								,cd_race_census int not null
							--	,cd_hispanic_latino_origin int not null
								,init_cd_plcm_setng int  not null
								,long_cd_plcm_setng int  not null
								,county_cd int not null
								,match_age_grouping_cd int not null
								,match_pk_gdnr int not null
								,match_cd_race_census int not null
								,match_cd_hispanic_latino_origin int not null
								,match_init_cd_plcm_setng int not null
								,match_long_cd_plcm_setng int not null
								,match_county_cd int not null
								--,ooh_filter_in_cache_table tinyint not null default 0
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(int_param_key
									,int_match_param_key
									,age_grouping_cd
									,pk_gndr
									,cd_race_census
									,init_cd_plcm_setng
									,long_cd_plcm_setng
									,county_cd
									,match_age_grouping_cd
									,match_pk_gdnr
									,match_cd_race_census
									,match_cd_hispanic_latino_origin
									,match_init_cd_plcm_setng
									,match_long_cd_plcm_setng
									,match_county_cd)

					select  

								 cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(age.age_grouping_cd,0)) + 
											(power(10.0,5) * coalesce(eth.cd_race,7)) +
												(power(10.0,4) * coalesce(gdr.pk_gndr,5)) + 
														(power(10.0,3) * fpl.cd_plcm_setng) +
															(power(10.0,2) * lpl.cd_plcm_setng) + 
																(power(10.0,0) * cnty.cd_cnty )
																as decimal(9,0)) as int_param_key
								, cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(age.match_code,0)) + 
											(power(10.0,6) * coalesce(eth.match_code,7)) +
												(power(10.0,5) * coalesce(eth.cd_origin,5)) + 
													(power(10.0,4) * coalesce(gdr.match_code,3)) + 
														(power(10.0,3) * fpl.match_code) +
															(power(10.0,2) * lpl.match_code) + 
																(power(10.0,0) * (case when coalesce(cnty.match_code,-99) 
																		not between 1 and 39 then 99 else cnty.match_code end))
																as decimal(9,0)) as int_match_param_key
								, age.age_grouping_cd 
								, gdr.pk_gndr
								, eth.cd_race as cd_race_census
								, fpl.cd_plcm_setng as init_cd_plcm_setng
								, lpl.cd_plcm_setng as longest_cd_plcm_setng
								, cnty.cd_cnty as county_cd
								, age.match_code as match_age_grouping_cd 
								, gdr.match_code as match_pk_gndr
								, eth.match_code as match_cd_race_census
								, eth.cd_origin as match_census_hispanic_latino_origin_cd
								, fpl.match_code as match_init_cd_plcm_setng
								, lpl.match_code as match_longest_cd_plcm_setng
								, cnty.match_code as match_county_cd
					from #age age 
					cross join #eth eth
					cross join #gdr gdr
					cross join #fpl fpl
					cross join #lpl lpl
					cross join #cnty cnty 

	   
	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,age_grouping_cd
						,pk_gndr
						,cd_race_census
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

    -----------------------------------  set dates  -------------------------------------  		
    select @mindate=min_date_any ,@maxdate=max_date_any 
	FROM ref_lookup_max_date where id=19;

	
		set @qry_id=(
		select top 1 qry_id from prtl.cache_poc1ab_params
		where age_grouping_cd=left(@age_grouping_cd,20)
		and cd_race_census=left(@race_cd,30) 
		and pk_gndr=left(@gender_cd,10) 
		and init_cd_plcm_setng=left(@init_cd_plcm_setng,50) 
		and long_cd_plcm_setng=left(@long_cd_plcm_setng,50) 
		and county_cd=	left(@County_Cd,200)   
		and bin_los_cd=left(@bin_los_cd,30)
		and bin_placement_cd=left(@bin_placement_cd,30)
		and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
		and cd_reporter_type=left(@cd_reporter_type,100)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		and filter_srvc_type=left(@filter_service_category,100)
		and filter_budget=left(@filter_service_budget,100)
		and bin_dep_cd=left(@bin_dep_cd,20)
		order by qry_ID asc	);  


		if @qry_Id is null
		begin


			INSERT INTO [prtl].[cache_poc1ab_params]
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
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_poc1ab_params]),1)
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
					,@mindate
					,@maxdate
					,1
					,getdate()

					select @qry_id=qry_id from @tblqryid;
			end 
			else
				begin
						update prtl.cache_poc1ab_params
						set cnt_qry=cnt_qry + 1,last_run_date=getdate()
						where @qry_id=qry_id				
				end
			
					-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;
		   select	([int_param_key] * power(10.0,13)) +
					([bin_dep_cd] * power(10.0,12)) +
					([bin_los_cd] * power(10.0,11)) +
					([bin_placement_cd] * power(10.0,10)) +
					([bin_ihs_svc_cd] * power(10.0,9)) +
					([cd_reporter_type] * power(10.0,7)) + 
					([cd_access_type] * power(10.0,6)) +
					([cd_allegation] * power(10.0,5)) +
					([cd_finding] * power(10.0,4)) + 
					([cd_subctgry_poc_frc] * power(10.0,2)) + 
					[cd_budget_poc_frc] as [int_hash_key]
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
					 ,q.qry_id as qry_id
					,RAND(cast(NEWID() as varbinary))  x1 
					,RAND(cast(NEWID() as varbinary)) x2
				into #cachekeys
				from (select @qry_id  qry_id) q  
				cross join (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct bin_los_cd from #los) los 
				cross join (select distinct bin_placement_cd from #nbrplc) plc
				cross join (select distinct bin_ihs_svc_cd from #ihs) ihs
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd
				cross join (select distinct cd_subctgry_poc_frc from #srvc) srv
				cross join (select distinct cd_budget_poc_frc from #budg) bud
				cross join (select distinct bin_dep_cd from #dep) dep



			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,cd_budget_poc_frc,cd_subctgry_poc_frc,in_cache);                   

				
			update cache
			set in_cache=1,qry_id=poc1ab.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_poc1ab] poc1ab
			on poc1ab.int_hash_key=cache.int_hash_key

	
			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;
		
	if @var_row_cnt_param <> @var_row_cnt_cache
			begin


			
				insert into prtl.cache_poc1ab_aggr( 
								[qry_type]
								,[date_type]
								,[start_date]
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
								,[cnt_start_date]
								,[min_start_date]
								,[max_start_date]
								,[x1]
								,[x2]
								,[insert_date]
								,int_hash_key
								,qry_id
								,start_year
								,fl_include_perCapita)
					SELECT    poc1ab.qry_type
								, poc1ab.date_type 
								, poc1ab.[start_date]
								, che.int_param_key  
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
								, cnty.cd_cnty
								, isnull(sum(poc1ab.cnt_child_unique),0) as cnt_start_date
								, @mindate as minmonthstart
								, @maxdate as maxmonthstart
								, che.x1
								, che.x2
								, getdate() as insert_date
								, che.int_hash_key 
								, che.qry_id 
								, year(poc1ab.[start_date])
								, 1
							FROM prtl.ooh_point_in_time_measures  poc1ab
							join #prmlocdem mtch on mtch.int_match_param_key=poc1ab.int_match_param_key_mix
							join #cnty cnty on cnty.match_code=poc1ab.county_cd
							join #los los on los.match_code=poc1ab.max_bin_los_cd
							join #nbrplc plc on plc.match_code=poc1ab.bin_placement_cd
							join #ihs ihs on ihs.match_code=poc1ab.bin_ihs_svc_cd
							join #rpt rpt on rpt.match_code=poc1ab.cd_reporter_type
							join #access_type acc on acc.match_code=poc1ab.filter_access_type
							join #algtn alg on alg.match_code=poc1ab.filter_allegation
							join #find fnd on fnd.match_code=poc1ab.filter_finding
							join #srvc srv on srv.match_code=poc1ab.filter_service_category
							join #budg bud on bud.match_code=poc1ab.filter_service_budget
							join #dep dep on dep.match_code=poc1ab.bin_dep_cd
							join #cachekeys che on che.int_hash_key=((mtch.int_param_key * power(10.0,13))+
								(dep.[bin_dep_cd] * power(10.0,12))  +
								(los.[bin_los_cd] * power(10.0,11) ) +
								(plc.[bin_placement_cd] * power(10.0,10) ) +
								(ihs.[bin_ihs_svc_cd] * power(10.0,9) ) +
								(rpt.[cd_reporter_type] * power(10.0,7) ) + 
								(acc.[cd_access_type] * power(10.0,6)) +
								(alg.[cd_allegation] * power(10.0,5)) +
								(fnd.[cd_finding] * power(10.0,4)) + 
								(srv.[cd_subctgry_poc_frc] * power(10.0,2))  + 
								bud.[cd_budget_poc_frc])
								and che.in_cache=0
							where fl_poc1ab=1 
						group by  poc1ab.qry_type
									,poc1ab.date_type 
									,poc1ab.[start_date]
									,year(poc1ab.[start_date])
									,che.int_hash_key
									,che.int_param_key
									,che.qry_id
									,che.x1
									,che.x2
									, dep.bin_dep_cd
									, los.bin_los_cd
									, plc.bin_placement_cd
									, ihs.bin_ihs_svc_cd
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									,  fnd.cd_finding
									, srv.cd_subctgry_poc_frc
									, bud.cd_budget_poc_frc
									, mtch.age_grouping_cd 
									, mtch.cd_race_census
									, mtch.pk_gndr
									, mtch.init_cd_plcm_setng
									, mtch.long_cd_plcm_setng
									, cnty.cd_cnty


		update cache_poc1ab_aggr
		set cache_poc1ab_aggr.fl_include_perCapita=0
		-- select pop_cnt, cache_poc1ab_aggr.*
		from prtl.cache_poc1ab_aggr,prm_ooh_census_population   
		where exists(select * from #cachekeys ck where cache_poc1ab_aggr.qry_id=ck.qry_id)
		and prm_ooh_census_population.measurement_year=start_year
		and prm_ooh_census_population.county_cd=cache_poc1ab_aggr.county_cd 
		and prm_ooh_census_population.pk_gndr=cache_poc1ab_aggr.pk_gndr
		and prm_ooh_census_population.cd_race=cache_poc1ab_aggr.cd_race
		and prm_ooh_census_population.age_grouping_cd=cache_poc1ab_aggr.age_grouping_cd
		and  (cache_poc1ab_aggr.cnt_start_date *1.00 >   pop_cnt * .35  	);

	
		
	
						update statistics prtl.cache_poc1ab_aggr
						insert into prtl.cache_qry_param_poc1ab
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
								   ,q.[age_grouping_cd]
								   ,q.[cd_race_census]
								   ,q.[pk_gndr]
								   ,q.[init_cd_plcm_setng]
								   ,q.[long_cd_plcm_setng]
								   ,q.[county_cd]
								   ,qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from #prmlocdem) q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;
	

						update statistics prtl.cache_qry_param_poc1ab;
	end

		if @fl_return_results=1
						SELECT  
								poc1ab.qry_type as   "qry_type_poc1"
								, poc1ab.date_type
								, poc1ab.start_date  as "Month"
								, poc1ab.age_grouping_cd as  "Age_Grouping_Cd"
								, ref_age.age_grouping as "Age Grouping"
								, poc1ab.pk_gndr  as "Gender_Cd"
								, ref_gdr.tx_gndr as "Gender" 
								, poc1ab.cd_race  as "Ethnicity_Cd"
								, ref_eth.tx_race_census as "Race/Ethnicity" 
								, poc1ab.init_cd_plcm_setng as "InitPlacementCd"
								, ref_fpl.tx_plcm_setng as  "First Placement Setting"
								, poc1ab.long_cd_plcm_setng as "LongPlacementCd"
								, ref_lpl.tx_plcm_setng as "Longest Placement Setting" 
								, poc1ab.county_cd as "Removal_County_Cd"
								, ref_cnty.county_desc as "County"
								, poc1ab.bin_dep_cd as [Dependency Cd]
								, ref_dep.bin_dep_desc as [Dependency]
								, poc1ab.bin_los_cd 
								, ref_los.bin_los_desc as [Length of Service Desc]
								, poc1ab.bin_placement_cd
								, ref_plc.bin_placement_desc as [Placement Count Desc]
								, poc1ab.bin_ihs_svc_cd
								, ref_ihs.bin_ihs_svc_tx as [In-Home Service Desc]
								, poc1ab.cd_reporter_type
								, ref_rpt.tx_reporter_type as [Reporter Desc]
								, poc1ab.cd_access_type
								, ref_acc.tx_access_type as [Access type desc]
								, poc1ab.cd_allegation
								, ref_alg.tx_allegation as [Allegation]
								, poc1ab.cd_finding
								, ref_fnd.tx_finding as [Finding]
								, poc1ab.cd_subctgry_poc_frc as [Service Type Cd]
								, ref_srv.tx_subctgry_poc_frc as [Service Type]
								, poc1ab.cd_budget_poc_frc as [Budget Cd]
								, ref_bud.tx_budget_poc_frc as [Budget]
								, case when (cnt_start_date) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
											then 1
											else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
											end
										else (cnt_start_date) 
									end  as   "Total In Care First Day"
							
						FROM prtl.cache_poc1ab_aggr poc1ab  
						 join #cachekeys ck on poc1ab.qry_id=ck.qry_id and poc1ab.int_hash_key=ck.int_hash_key
						join ref_age_groupings_census ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
						join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc1ab.cd_race
						join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc1ab.pk_gndr
						join ref_lookup_plcmnt ref_fpl on ref_fpl.cd_plcm_setng=poc1ab.init_cd_plcm_setng
						join ref_lookup_plcmnt ref_lpl on ref_lpl.cd_plcm_setng=poc1ab.long_cd_plcm_setng
						join ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
						join vw_ref_dependency_lag ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
							and poc1ab.date_type=ref_dep.date_type
							and poc1ab.start_date between @minfilterdate and cohort_max_filter_date
						join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
						join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=poc1ab.bin_placement_cd
						join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
						join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
						join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
						join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
						join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
            where poc1ab.start_date   between @mindate and @maxdate
			order by poc1ab.qry_type 
								, poc1ab.date_type
								, poc1ab.start_date
								, poc1ab.age_grouping_cd
								, poc1ab.pk_gndr
								, poc1ab.cd_race  
								, poc1ab.init_cd_plcm_setng 
								, poc1ab.long_cd_plcm_setng
								, poc1ab.county_cd 
								, poc1ab.bin_dep_cd 
								, poc1ab.bin_los_cd 
								, poc1ab.bin_placement_cd
								, poc1ab.bin_ihs_svc_cd
								, poc1ab.cd_reporter_type
								, poc1ab.cd_access_type
								, poc1ab.cd_allegation
								, poc1ab.cd_finding
								, poc1ab.cd_subctgry_poc_frc 
								, poc1ab.cd_budget_poc_frc 
								;

	

