

CREATE PROCEDURE [prtl].[sp_ooh_flow_exits](
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
, @bin_dep_cd varchar(20)
,@fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
 )
as
 set nocount on

 declare @qry_id bigint;
    declare @mindate datetime
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;
	declare @var_row_cnt_param int;
	declare @var_row_cnt_cache int;
	declare @minfilterdate datetime;

	declare @tblqryid table(qry_id int);

	if object_ID('tempDB..#dsch') is not null drop table #dsch;
	create table #dsch(cd_discharge_type int ,match_code int)
	insert into #dsch(cd_discharge_type,match_code)
	select cd_discharge_type,match_code from prm_dsch_exits;	


    -----------------------------------  set dates  -------------------------------------  		
    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any ,@mindate=min_date_any,@maxdate=max_date_any
	  FROM ref_lookup_max_date where id=19;

	
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

	-- dependency tables
	if object_ID('tempDB..#dep') is not null drop table #dep
	create table #dep(bin_dep_cd int,match_code decimal(18,0),primary key(bin_dep_cd,match_code))
	create index idx_dep on #dep(match_code)
	------------------------------------------------  AGE

	insert into #age(age_grouping_cd,match_code)
	select age_grouping_cd,match_code
	from prm_age_census 
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

		set @qry_id=(
		select top 1 qry_id from prtl.cache_poc1ab_exits_params
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
		and bin_dep_cd=left(@bin_dep_cd,20)
		order by qry_ID desc
		);  


		if @qry_Id is null
		begin


			INSERT INTO [prtl].[cache_poc1ab_exits_params]
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
					,bin_dep_cd
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_poc1ab_exits_params]),1)
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
					,@bin_dep_cd
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()

					select @qry_id=qry_id from @tblqryid;
				
			end 
			else
				begin
						update prtl.cache_poc1ab_exits_params
						set cnt_qry=cnt_qry + 1,last_run_date=getdate()
						where @qry_id=qry_id				
				end
			
					-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;

		   select	([int_param_key] * power(10.0,9) ) +
					([bin_dep_cd] * power(10.0,8) ) +
					([bin_los_cd] * power(10.0,7) ) +
					([bin_placement_cd] * power(10.0,6) ) +
					([bin_ihs_svc_cd] * power(10.0,5) ) +
					([cd_reporter_type] * power(10.0,3) ) + 
					([cd_access_type] * power(10.0,2)) +
					([cd_allegation] * 10.0) +
					[cd_finding] as int_hash_key
					 ,int_param_key
					 ,bin_dep_cd
					 ,bin_los_cd
					 ,bin_placement_cd
					 ,bin_ihs_svc_cd
					 ,cd_reporter_type
					 ,cd_access_type
					 ,cd_allegation
					 ,cd_finding
					 ,0 as in_cache
					 ,@qry_id as qry_id
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct bin_los_cd from #los) los
				cross join (select distinct bin_placement_cd from #nbrplc) plc
				cross join (select distinct bin_ihs_svc_cd from #ihs) ihs
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd
				cross join (select distinct bin_dep_cd from #dep )dep

			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,in_cache);

				
			update cache
			set in_cache=1,qry_id=poc1ab_exits.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_poc1ab_exits] poc1ab_exits
			on poc1ab_exits.int_hash_key=cache.int_hash_key

	
			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;

	if @var_row_cnt_param <> @var_row_cnt_cache
			begin

							insert into prtl.cache_poc1ab_exits_aggr( 
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
								,[age_grouping_cd]
								,[cd_race]
								,[pk_gndr]
								,[init_cd_plcm_setng]
								,[long_cd_plcm_setng]
								,[county_cd]
								,int_hash_key
								,[min_start_date]
								,[max_start_date]
								,[x1]
								,[x2]
								,[insert_date]
								,cd_discharge_type
								,[cnt_exits]
								,qry_id
								,start_year
								,fl_include_perCapita)

						SELECT    prtl_poc1ab_exits.qry_type
								, prtl_poc1ab_exits.date_type 
								, prtl_poc1ab_exits.[start_date]
								, mtch.int_param_key
								, dep.bin_dep_cd
								, los.bin_los_cd
								, plc.bin_placement_cd
								, ihs.bin_ihs_svc_cd
								, rpt.cd_reporter_type
								, acc.cd_access_type
								, alg.cd_allegation
								, fnd.cd_finding
								, mtch.age_grouping_cd 
								, mtch.cd_race_census
								, mtch.pk_gndr
								, mtch.init_cd_plcm_setng
								, mtch.long_cd_plcm_setng
								, mtch.county_cd
								, che.int_hash_key
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								, rand(convert(varbinary, newid())) [x1]
								, rand(convert(varbinary, newid())) [x2]
								, getdate() as insert_date
								, dsch.cd_discharge_type
								, isnull(sum(prtl_poc1ab_exits.cnt_exits),0) as cnt_exits
								,che.qry_id
								,prtl_poc1ab_exits.[start_year]
								,1
							FROM prtl.prtl_poc1ab_exits  
							   join #dsch dsch on dsch.match_code=prtl_poc1ab_exits.cd_discharge_type
								join #prmlocdem mtch on mtch.int_match_param_key=prtl_poc1ab_exits.int_match_param_key 
								join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
								join #los los on prtl_poc1ab_exits.max_bin_los_cd=los.match_code
								join #nbrplc plc on plc.match_code=prtl_poc1ab_exits.bin_placement_cd
								join #ihs ihs on ihs.match_code=prtl_poc1ab_exits.bin_ihs_svc_cd
								join #rpt rpt on rpt.match_code=prtl_poc1ab_exits.cd_reporter_type
								join #access_type acc on acc.match_code=prtl_poc1ab_exits.filter_access_type
								join #algtn alg on alg.match_code=prtl_poc1ab_exits.filter_allegation
								join #find fnd on fnd.match_code=prtl_poc1ab_exits.filter_finding
								join #dep dep on prtl_poc1ab_exits.bin_dep_cd=dep.match_code
								join #cachekeys che on che.int_hash_key = ((mtch.int_param_key * power(10.0,9)) + 
										(dep.bin_dep_cd * power(10.0,8)) + 
										(los.bin_los_cd * power(10.0,7)) + 
										(plc.bin_placement_cd * power(10.0,6) ) +
										(ihs.bin_ihs_svc_cd * power(10.0,5) ) +
										(rpt.cd_reporter_type * power(10.0,3) ) + 
										(acc.cd_access_type * power(10.0,2)) +
										(alg.cd_allegation * 10.0) +
										fnd.cd_finding)	
										and che.in_cache=0
							group by  prtl_poc1ab_exits.qry_type
									,prtl_poc1ab_exits.date_type 
									,prtl_poc1ab_exits.[start_date]
									,prtl_poc1ab_exits.[start_year]
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
									, dsch.cd_discharge_type
									, che.int_hash_key
									, che.qry_id

						update cache_poc1ab_exits_aggr
						set fl_include_perCapita=0
						from  prtl.cache_poc1ab_exits_aggr  
						, dbo.ref_lookup_census_population  
						where ref_lookup_census_population.measurement_year=start_year
						and ref_lookup_census_population.county_cd=cache_poc1ab_exits_aggr.county_cd and ref_lookup_census_population.pk_gndr=cache_poc1ab_exits_aggr.pk_gndr
						and ref_lookup_census_population.cd_race=cache_poc1ab_exits_aggr.cd_race
						and ref_lookup_census_population.age_grouping_cd=cache_poc1ab_exits_aggr.age_grouping_cd
						and  (cache_poc1ab_exits_aggr.cnt_exits  > pop_cnt * .35   
--							or  cache_poc1ab_exits_aggr.cnt_exits > pop_cnt * .35  
--							or  cache_poc1ab_exits_aggr.cnt_exits > pop_cnt * .35 
							);

						update statistics prtl.cache_poc1ab_exits_aggr
						insert into prtl.cache_qry_param_poc1ab_exits
									   ([int_param_key]
									   ,bin_dep_cd
								   ,[bin_los_cd]
								   ,[bin_placement_cd]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
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
								   ,q.[age_grouping_cd]
								   ,q.[cd_race_census]
								   ,q.[pk_gndr]
								   ,q.[init_cd_plcm_setng]
								   ,q.[long_cd_plcm_setng]
								   ,q.[county_cd]
								   ,@qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;
	
						update statistics prtl.cache_qry_param_poc1ab_exits;
	end
	IF @fl_return_results=1
	 select            
                poc1ab.qry_type   "qry_type_poc1_first_unique"
                , poc1ab.date_type
                , poc1ab.start_date  as "Month"
                , poc1ab.age_grouping_cd  
                , ref_age.age_grouping [Age Grouping]
                , poc1ab.pk_gndr  as "gender_cd"
                , ref_gdr.tx_gndr  "Gender" 
                , poc1ab.cd_race  as "ethnicity_cd"
                , ref_eth.tx_race_census [Race/Ethnicity]
                , poc1ab.init_cd_plcm_setng  
                , ref_fpl.tx_plcm_setng  "Initial Placement"
                , poc1ab.long_cd_plcm_setng  
                , ref_lpl.tx_plcm_setng  "Longest Placement"
                , poc1ab.county_cd
                , ref_cnty.county_desc as "County"
                , poc1ab.bin_dep_cd as  "dependency_cd"
                , ref_dep.bin_dep_desc as "Dependency"
                , poc1ab.bin_los_cd
                , ref_los.bin_los_desc as "Length of Service Desc"                                
                , poc1ab.bin_placement_cd
                , ref_plc.bin_placement_desc "Placement Count Desc"
                , poc1ab.bin_ihs_svc_cd
                , ref_ihs.bin_ihs_svc_tx  [In-Home Service Desc]
                , poc1ab.cd_reporter_type
                , ref_rpt.tx_reporter_type as "Reporter Desc"
                , poc1ab.cd_access_type
                , ref_acc.tx_access_type as "Access type desc"
                , poc1ab.cd_allegation
                , ref_alg.tx_allegation [Allegation]
                , poc1ab.cd_finding
                , ref_fnd.tx_finding [Finding]
                , poc1ab.cd_discharge_type 
                , dsch.discharge_type as "Outcome"
                 ,  case when (cnt_exits) > 0 /* jitter all above 0 */ 
                        then 
                            case when (round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) 
                            * cos(2*pi()*poc1ab.x2),0) ) <1
                            then 1
                            else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                            end
                        else (cnt_exits) 
                    end as "Number of Exits"  
        from cache_poc1ab_exits_aggr poc1ab
        join #cachekeys ck on ck.qry_id=poc1ab.qry_id
        and ck.int_hash_key=poc1ab.int_hash_key
			join ref_age_census_child_group  ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
            join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
                        and poc1ab.start_date >= @minfilterdate
            join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
			join ref_lookup_gender ref_gdr on ref_gdr.[pk_gndr]=poc1ab.pk_gndr
			join ref_lookup_ethnicity_census ref_eth on ref_eth.[cd_race_census] = poc1ab.cd_race
			join [dbo].[ref_lookup_plcmnt]  ref_fpl on ref_fpl.[cd_plcm_setng] = poc1ab.init_cd_plcm_setng
			join [dbo].[ref_lookup_plcmnt]  ref_lpl on ref_lpl.[cd_plcm_setng] = poc1ab.long_cd_plcm_setng
			join [dbo].[ref_filter_nbr_placement] ref_plc on ref_plc.[bin_placement_cd]=poc1ab.[bin_placement_cd]
            join ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
             join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
			 join ref_filter_ihs_services ref_ihs on ref_ihs.[bin_ihs_svc_cd]=poc1ab.bin_ihs_svc_cd
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
			join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
			join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
        join ref_lookup_cd_discharge_type_exits dsch on dsch.cd_discharge_type=poc1ab.cd_discharge_type
        order by  poc1ab.bin_dep_cd 
                            ,poc1ab.qry_type
                            , poc1ab.date_type
                            , poc1ab.start_date 
                            , poc1ab.age_grouping_cd 
                            , poc1ab.pk_gndr 
                            , poc1ab.cd_race 
                            , poc1ab.init_cd_plcm_setng 
                            , poc1ab.long_cd_plcm_setng 
                            , poc1ab.county_cd 
                            , poc1ab.bin_los_cd 
                            , poc1ab.bin_placement_cd
                            , poc1ab.bin_ihs_svc_cd
                            , poc1ab.cd_reporter_type
                            , poc1ab.cd_access_type
                            , poc1ab.cd_allegation
                            , poc1ab.cd_finding
                            , poc1ab.cd_discharge_type;  
  
		