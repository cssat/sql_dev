
CREATE PROCEDURE [prtl].[sp_ooh_wb_siblings](
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
,@bin_dep_cd varchar(20)
,@fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
)
as
 set nocount on
 declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
    declare @maxmonthstart datetime;
    declare @minmonthstart datetime;
	declare @minfilterdate datetime;
	declare @tblqryid table(qry_id int);





    -----------------------------------  set dates  -------------------------------------  		

    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any
				  ,@mindate=min_date_any ,@maxdate=max_date_any FROM ref_lookup_max_date where id=13;

	
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

			-- dependency tables
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


			-- print 'qry_id is ' + str(@qry_id)

				---  load the demographic ,placement,location parameters --
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
				select top 1 qry_id from prtl.cache_pbcw4_params
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
				order by qry_ID desc
				);  

	--  select @qry_id,@minmonthstart,@maxmonthstart
	


		if @qry_Id is null
		begin


			INSERT INTO [prtl].[cache_pbcw4_params]
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
					, bin_dep_cd
					, min_start_date
					, max_start_date
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_pbcw4_params]),1)
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
			
		end -- if @qry_Id is null
		else -- if @qry_Id is null
			begin
						update prtl.cache_pbcw4_params
									set cnt_qry=cnt_qry + 1,last_run_date=getdate()
									where @qry_id=qry_id				
			end
	
	
				-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;
		   select	([int_param_key] * power(10.0,9)) +
					([bin_dep_cd] * power(10.0,8)) +
					([bin_los_cd] * power(10.0,7)) +
					([bin_placement_cd] * power(10.0,6)) +
					([bin_ihs_svc_cd] * power(10.0,5)) +
					([cd_reporter_type] * power(10.0,3)) + 
					([cd_access_type] * power(10.0,2)) +
					([cd_allegation] * 10.0) +
					[cd_finding] as [int_hash_key]
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
					 ,q.qry_id as qry_id
				into #cachekeys
				from (select @qry_id qry_id) q  
				cross join (select distinct int_param_key from #prmlocdem) prm
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
			set in_cache=1,qry_id=pbcw4.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_pbcw4] pbcw4
			on pbcw4.int_hash_key=cache.int_hash_key



			if NOT (select count(*) from #cachekeys )=(select sum(in_cache) from #cachekeys)
			begin
						---  print 'qry_id is '  + str(@qry_id) 
													

INSERT INTO [prtl].[cache_pbcw4_aggr]
		([qry_type]
           ,[date_type]
           ,[cohort_entry_date]
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
           ,[kincare]
           ,bin_sibling_group_size
           ,[all_together]
           ,[some_together]
           ,[none_together]
           ,[min_start_date]
           ,[max_start_date]
           ,[x1]
           ,[x2]
           ,[insert_date]
           ,[qry_id]
           ,[cohort_begin_year]
           ,[int_hash_key]
		   	,cnt_cohort)

		SELECT    prtl_pbcw4.qry_type
				, prtl_pbcw4.date_type 
				, prtl_pbcw4.start_date
				, che.int_param_key
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
				, kin.kincare
				, sib.bin_sibling_group_size
				, round(((sum(all_sib_together)/(sum(cnt_child)* 1.0000)) * 100),2) as All_Together
				, round(((sum(some_sib_together)/(sum(cnt_child)* 1.0000)) * 100),2) as Some_Together
				, round(((sum(no_sib_together)/(sum(cnt_child)* 1.0000)) * 100),2) as None_Together
				, @minmonthstart as minmonthstart
				, @maxmonthstart as maxmonthstart
				, rand(convert(varbinary, newid())) [x1]
				, rand(convert(varbinary, newid())) [x2]
				, getdate() as insert_date
				, che.qry_id
				, year(prtl_pbcw4.start_date)
				, che.int_hash_key
				, sum(cnt_child)
			FROM prtl.ooh_point_in_time_measures prtl_pbcw4
			join #prmlocdem mtch on mtch.int_match_param_key=prtl_pbcw4.int_match_param_key_mix
			join #los los on los.match_code=prtl_pbcw4.max_bin_los_cd
			join #nbrplc plc on plc.match_code=prtl_pbcw4.bin_placement_cd
			join #ihs ihs on ihs.match_code=prtl_pbcw4.bin_ihs_svc_cd
			join #rpt rpt on rpt.match_code=prtl_pbcw4.cd_reporter_type
			join #access_type acc on acc.match_code=prtl_pbcw4.filter_access_type
			join #algtn alg on alg.match_code=prtl_pbcw4.filter_allegation
			join #find fnd on fnd.match_code=prtl_pbcw4.filter_finding
			join #dep dep on dep.match_code=prtl_pbcw4.bin_dep_cd
			join prm_kin kin on kin.match_code=prtl_pbcw4.kincare
			join prm_sib  sib on sib.match_code=prtl_pbcw4.bin_sibling_group_size
			join #cachekeys che on che.int_hash_key=((mtch.int_param_key * power(10.0,9)) +
				(dep.[bin_dep_cd] * power(10.0,8)) +
				(los.[bin_los_cd] * power(10.0,7)) +
				(plc.[bin_placement_cd] * power(10.0,6)) +
				(ihs.[bin_ihs_svc_cd] * power(10.0,5)) +
				(rpt.[cd_reporter_type] * power(10.0,3)) +
				(acc.[cd_access_type] * power(10.0,2)) +
				(alg.[cd_allegation] * 10.0) +
				fnd.[cd_finding])
				and che.in_cache=0
			where [fl_w4]=1 
			group by kin.kincare
				, prtl_pbcw4.qry_type
				, prtl_pbcw4.date_type 
				, prtl_pbcw4.start_date
				, year(prtl_pbcw4.start_date)
				, che.int_hash_key
				, che.int_param_key
				, che.qry_id
				, sib.bin_sibling_group_size
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
					

		
		
						update statistics prtl.cache_pbcw4_aggr

						INSERT INTO [prtl].[cache_qry_param_pbcw4]
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
								   ,q.cd_race_census
								   ,q.[pk_gndr]
								   ,q.[init_cd_plcm_setng]
								   ,q.[long_cd_plcm_setng]
								   ,q.county_cd
								   ,@qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;




						
	
						update statistics prtl.cache_qry_param_pbcw4;

						
					  end -- if @qry_id is null

		if @fl_return_results=1
					   select
									 pbcw4.cohort_entry_date  "Cohort Entry Date"
									, qry_type "qry_type_poc1_first_unique"
									, date_type
									, pbcw4.age_grouping_cd
									, ref_age.age_grouping  "age_grouping"
									, pbcw4.cd_race  ethnicity_cd
									, ref_eth.tx_race_census "Race/Ethnicity" 
									, pbcw4.pk_gndr as gender_cd
									, ref_gdr.tx_gndr "Gender" 
									, pbcw4.init_cd_plcm_setng
									, ref_fpl.tx_plcm_setng  "Initial Placement"
									, pbcw4.long_cd_plcm_setng  
									, ref_lpl.tx_plcm_setng  "Longest Placement"
									, pbcw4.county_cd
									, ref_cnty.county_cd as "County"
									, pbcw4.bin_dep_cd as  "dependency_cd"
									, ref_dep.bin_dep_desc as "Dependency"
									, pbcw4.bin_los_cd
									, ref_los.bin_los_desc as "Length of Service Desc"
									, pbcw4.bin_placement_cd
									, ref_plc.bin_placement_desc "Placement Count Desc"
									, pbcw4.bin_ihs_svc_cd
									, ref_ihs.bin_ihs_svc_tx "In-Home Service Desc"
									, pbcw4.cd_reporter_type
									, ref_rpt.tx_reporter_type as "Reporter Desc"
									, pbcw4.cd_access_type
									, ref_acc.tx_access_type as "Access type desc"
									, pbcw4.cd_allegation
									, ref_alg.tx_allegation "Allegation" 
									, pbcw4.cd_finding
									, ref_fnd.tx_finding "Finding"
									, ref_kin.placement_type  "Placement Type"  
									, pbcw4.bin_sibling_group_size
									, ref_sib.nbr_sibling_desc "Sibling Group Size"
									, all_together  as All_Together
									, some_together as Some_Together
									, none_together as None_Together
									, cnt_cohort
			--						, round(cnt_cohort + 2 * sqrt(-2 * log(pbcw4.x1)) 
			--										* cos(2*pi()*pbcw4.x2),0) as "Number in Cohort"
            FROM prtl.cache_pbcw4_aggr  pbcw4
            join #cachekeys ck on ck.qry_id=pbcw4.qry_id and ck.int_hash_key=pbcw4.int_hash_key
            join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=pbcw4.bin_dep_cd
				and pbcw4.cohort_entry_date >=@minfilterdate
			join ref_age_cdc_census_mix ref_age on ref_age.age_grouping_cd=pbcw4.age_grouping_cd
			join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=pbcw4.cd_race
			join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=pbcw4.pk_gndr
            join ref_filter_los ref_los on ref_los.bin_los_cd=pbcw4.bin_los_cd
			join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=pbcw4.bin_placement_cd
            join ref_lookup_plcmnt ref_fpl on ref_fpl.cd_plcm_setng=pbcw4.init_cd_plcm_setng
            join ref_lookup_plcmnt ref_lpl on ref_lpl.cd_plcm_setng=pbcw4.long_cd_plcm_setng
            join ref_lookup_county ref_cnty on ref_cnty.county_cd=pbcw4.county_cd
            join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcw4.cd_reporter_type
			join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=pbcw4.bin_ihs_svc_cd
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcw4.cd_access_type
			join ref_filter_allegation ref_alg on ref_alg.cd_allegation=pbcw4.cd_allegation
			join ref_filter_finding ref_fnd on ref_fnd.cd_finding=pbcw4.cd_finding
            join [ref_bin_sibling_group_size] ref_sib on ref_sib.bin_sibling_group_size=pbcw4.bin_sibling_group_size
			join prtl_ref_kincare ref_kin on ref_kin.kincare=pbcw4.kincare
  order by pbcw4.kincare asc,
                pbcw4.bin_dep_cd asc
                ,qry_type
                ,date_type
                ,Cohort_Entry_date asc
                ,age_grouping_cd asc
                    ,gender_cd asc
                    ,ethnicity_cd asc
                    ,init_cd_plcm_setng asc
                    ,long_cd_plcm_setng asc
                    ,county_cd asc
                    , pbcw4.bin_los_cd asc
                    , pbcw4.bin_placement_cd asc
                    , pbcw4.bin_ihs_svc_cd asc
                    , pbcw4.cd_reporter_type
                    , pbcw4.cd_access_type
                    , pbcw4.cd_allegation
                    , pbcw4.cd_finding
                    , pbcw4.bin_sibling_group_size;  
				