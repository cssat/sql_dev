
CREATE PROCEDURE [prtl].[sp_cache_pbcs3_insert_only](
   @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @cd_county varchar(1000)
,  @bin_ihs_svc_cd varchar(30) 
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30) 
, @filter_service_category  varchar(100)
, @filter_service_budget varchar(100))
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
       select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any ,@mindate=min_date_any,@maxdate=max_date_any
	   FROM ref_lookup_max_date where procedure_name='sp_ihs_safety';
   	   

   
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
			create table #algtn(cd_allegation  int,match_code decimal(18,0) ,primary key(cd_allegation,match_code));
			create index idx_algtn on #algtn(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..#find') is not null drop table #find
			create table #find(cd_finding int,match_code decimal(18,0) ,primary key(cd_finding,match_code));
			create index idx_finding on #find(match_code)

	
		-- service type flags	
			if object_ID('tempDB..#srvc') is not null drop table #srvc
			create table #srvc(cd_subctgry_poc_frc int, match_code decimal(18,0) ,primary key(cd_subctgry_poc_frc,match_code));
			create index idx_srvc on #srvc(match_code)
			-- budget type flags

			if object_ID('tempDB..#budg') is not null drop table #budg
				create table #budg(cd_budget_poc_frc int,match_code decimal(9,0),primary key(cd_budget_poc_frc,match_code))
				create index idx_budg on #budg(match_code)

				----------------------------------------------  AGE

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


		-----------------------------------  services ---------------------------------------
	--  prm_srvc		 @filter_service_category
		
	insert into #srvc(cd_subctgry_poc_frc,match_code)
	select srvc.cd_subctgry_poc_frc,srvc.match_code
	from prm_srvc srvc				
	join dbo.fn_ReturnStrTableFromList(@filter_service_category,0) sel
	on cast(sel.arrValue as int)=srvc.cd_subctgry_poc_frc

					

	update statistics #srvc					

	-----------------------------------  budget ---------------------------------------

	--   @filter_service_budget;
	insert into #budg(cd_budget_poc_frc,match_code)
	select cd_budget_poc_frc,match_code
	from prm_budg bud
	join dbo.fn_ReturnStrTableFromList(@filter_service_budget,0) sel
	on cast(sel.arrValue as int)=bud.cd_budget_poc_frc		



	update statistics #budg

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
		select top 1 qry_id from prtl.cache_pbcs3_params
		where cd_sib_age_grp=left(@age_grouping_cd,20)
		and cd_race_census=left(@race_cd,30) 
		and cd_county=	left(@cd_county,250)   
		and cd_reporter_type=left(@cd_reporter_type,100)
		and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		and filter_srvc_type=left(@filter_service_category,100)
		and filter_budget=left(@filter_service_budget,100)
		order by qry_ID desc
		);  
		

			if @qry_Id is null
		begin


			INSERT INTO [prtl].[cache_pbcs3_params]
					(qry_id
					, cd_sib_age_grp
					,[cd_race_census]
					,cd_county
					,bin_ihs_svc_cd
					,[cd_reporter_type]
					,[filter_access_type]
					,[filter_allegation]
					,[filter_finding]
					,[filter_srvc_type]
					,[filter_budget]
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_pbcs3_params]),1)
					,@age_grouping_cd
					,@race_cd
					,@cd_county
					,@bin_ihs_svc_cd
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@filter_service_category
					,@filter_service_budget
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()

					select @qry_id =qry_id from @tblqryid;
			end
		else
			begin

					update prtl.cache_pbcs3_params
					set cnt_qry=cnt_qry + 1,last_run_date=getdate()
					where @qry_id=qry_id	
			end;
							 		
			-- see if results are in cache as a subset of previously run query
			-- if so get that qry_id
			if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;

		   select (cast((int_param_key  * power(10.0,10)) as decimal(22,0))
			+ cast((rpt.cd_reporter_type  * power(10.0,8)) as decimal(22,0))
			+ cast((ihs.bin_ihs_svc_cd * power(10.0, 7)) as decimal(22,0))
			+  cast((acc.cd_access_type  * power(10.0,6)) as decimal(22,0))
			+  cast((alg.cd_allegation  * power(10.0,5)) as decimal(22,0))
			+  cast((fnd.cd_finding  * power(10.0,4)) as decimal(22,0)) 
			+  cast((cd_subctgry_poc_frc * power(10.0,2))as decimal(22,0))  +  [cd_budget_poc_frc] ) as int_hash_key
					 ,int_param_key
					 ,cd_reporter_type
					 , bin_ihs_svc_cd
					 ,cd_access_type
					 ,cd_allegation
					 ,cd_finding
					 , cd_subctgry_poc_frc
					 , cd_budget_poc_frc
					 ,0 as in_cache
					 ,@qry_id as qry_id
				into #cachekeys
				from (select distinct int_param_key from #prmlocdem) prm
				cross join (select distinct cd_reporter_type from #rpt) rpt
				cross join (select distinct bin_ihs_svc_cd from #ihs) ihs
				cross join (select distinct cd_access_type from #access_type) acc
				cross join (select distinct cd_allegation from #algtn) alg
				cross join (select distinct cd_finding from #find) fnd
				cross join (select distinct cd_subctgry_poc_frc from #srvc) srvc
				cross join (select distinct cd_budget_poc_frc from #budg) budg;


			update cache
			set in_cache=1,qry_id=pbcs3.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_pbcs3] pbcs3
			on pbcs3.int_hash_key=cache.int_hash_key

			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,cd_budget_poc_frc,cd_subctgry_poc_frc,in_cache);                   

			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;

	if @var_row_cnt_param <> @var_row_cnt_cache
	begin

		If object_id('tempdb..#total') is not null drop table #total
		select s3.[cohort_begin_date]
      ,s3.[date_type]
      ,s3.[qry_type]
	, mtch.age_grouping_cd 
	, mtch.cd_race_census
	, mtch.cd_cnty
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
	, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
      ,sum([cnt_case]) as total_cases
  into #total
  FROM [prtl].[prtl_pbcs3] s3
  	join #prmlocdem mtch on mtch.int_match_param_key=s3.int_match_param_key 
		and  mtch.cd_race_census in (select distinct cd_race from #eth)
		join #ihs ihs on ihs.match_code=s3.bin_ihs_svc_cd
	join #rpt rpt on rpt.match_code=s3.cd_reporter
	join #access_type acc on acc.match_code=s3.filter_access_type
	join #algtn alg on alg.match_code=s3.filter_allegation
	join #find fnd on fnd.match_code=s3.filter_finding
	join #srvc srv on srv.match_code=s3.filter_service_type
	join #budg bud on bud.match_code=s3.filter_budget_type
	group by s3.[cohort_begin_date]
      ,s3.[date_type]
      ,s3.[qry_type]
	, mtch.age_grouping_cd 
	, mtch.cd_race_census
	, mtch.cd_cnty
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
	,srv.cd_subctgry_poc_frc
	,bud.cd_budget_poc_frc

		If object_id('tempdb..#mytemp') is not null drop table #mytemp
	SELECT       
	  prtl_pbcs3.qry_type
	, prtl_pbcs3.date_type
	, prtl_pbcs3.cohort_begin_date
	, mtch.int_param_key
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
	, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
	, mtch.age_grouping_cd 
	, mtch.cd_race_census
	, mtch.cd_cnty
    , cal.mnth [Month]
    , sum(IIF(s3_total.total_cases > 0 and  prtl_pbcs3.min_placed_within_month <=cal.mnth,([cnt_case] ),0))/(s3_total.total_cases * 1.00) * 100   [Placed]
	, 100.00 - sum(IIF(s3_total.total_cases > 0 and  prtl_pbcs3.min_placed_within_month <=cal.mnth,([cnt_case] ),0))/(s3_total.total_cases * 1.00) * 100 [Not Placed]
	, @minmonthstart as minmonthstart
	, @maxmonthstart as maxmonthstart
	, @x1 as x1
	, @x2   as x2
	, getdate() as insert_date
	, @qry_id as qry_id
	, year(prtl_pbcs3.cohort_begin_date) as cohort_year
	, che.int_hash_key
into #mytemp
  FROM [prtl].[prtl_pbcs3]
  	join #prmlocdem mtch on mtch.int_match_param_key=[prtl_pbcs3].int_match_param_key 
		and  mtch.cd_race_census in (select distinct cd_race from #eth)
	join #ihs ihs on ihs.match_code=prtl_pbcs3.bin_ihs_svc_cd
	join #rpt rpt on rpt.match_code=[prtl_pbcs3].cd_reporter
	join #access_type acc on acc.match_code=[prtl_pbcs3].filter_access_type
	join #algtn alg on alg.match_code=[prtl_pbcs3].filter_allegation
	join #find fnd on fnd.match_code=[prtl_pbcs3].filter_finding
	join #srvc srv on srv.match_code=prtl_pbcs3.filter_service_type
	join #budg bud on bud.match_code=prtl_pbcs3.filter_budget_type
	join #cachekeys che on che.int_param_key = mtch.int_param_key
				and che.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
				and che.cd_reporter_type=rpt.cd_reporter_type
				and che.cd_allegation=alg.cd_allegation
				and che.cd_finding=fnd.cd_finding
				and che.cd_access_type=acc.cd_access_type
				and che.cd_budget_poc_frc=bud.cd_budget_poc_frc
				and che.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
				and che.in_cache=0
   join (select number * 3 as mnth from numbers where number between 1 and 16) cal 
	on cal.mnth between 3 and 48
 join  #total s3_total 
on  s3_total.cohort_begin_date =[prtl_pbcs3].cohort_begin_date
	and s3_total.[date_type] =[prtl_pbcs3].[date_type]
	and s3_total.qry_type =[prtl_pbcs3].qry_type
	and s3_total.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
	and s3_total.age_grouping_cd =mtch.age_grouping_cd
	and s3_total.cd_race_census =mtch.cd_race_census
	and s3_total.cd_cnty =mtch.cd_cnty
	and s3_total.cd_reporter_type =rpt.cd_reporter_type
	and s3_total.cd_access_type=acc.cd_access_type
	and s3_total.cd_allegation=alg.cd_allegation
	and s3_total.cd_finding=fnd.cd_finding
	and s3_total.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
	and s3_total.cd_budget_poc_frc=bud.cd_budget_poc_frc
	
group by [prtl_pbcs3].[cohort_begin_date]
      ,[prtl_pbcs3].[date_type]
      ,[prtl_pbcs3].[qry_type]
	    , mtch.int_param_key
	, mtch.age_grouping_cd 
	, mtch.cd_race_census
	, mtch.cd_cnty
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
		, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
	  , cal.mnth 
	  , che.int_hash_key
	  ,s3_total.total_cases
order by [prtl_pbcs3].[cohort_begin_date]
      ,[prtl_pbcs3].[date_type]
      ,[prtl_pbcs3].[qry_type]
	, mtch.age_grouping_cd 
	, mtch.cd_race_census
	, mtch.cd_cnty
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
		, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
	  , cal.mnth 

INSERT INTO [prtl].[cache_pbcs3_aggr]
				   ([qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[int_param_key]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,[cd_access_type]
				   ,[cd_allegation]
				   ,[cd_finding]
				   ,[cd_service_type]
				   ,[cd_budget_type]
				   ,[cd_sib_age_grp]
				   ,[cd_race_census]
				   ,cd_county
				   ,[month]
				   ,[placed]
				   ,[not_placed]
				   ,[min_start_date]
				   ,[max_start_date]
				   ,[x1]
				   ,[x2]
				   ,[insert_date]
				   ,[qry_id]
				   ,[start_year]
				   ,[int_hash_key])
	select * from #mytemp;
	drop table #mytemp;


insert into prtl.cache_qry_param_pbcs3
					select ck.[int_param_key]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
								   ,[cd_subctgry_poc_frc]
								   ,[cd_budget_poc_frc]
								   ,q.age_grouping_cd
								   ,q.[cd_race_census]
								   ,q.cd_cnty
								   ,@qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,cd_cnty from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;

end -- not in cache
