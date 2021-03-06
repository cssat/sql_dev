USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[sp_cache_pbcs3]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [prtl].[sp_cache_pbcs3](
   @date varchar(3000)
,  @cd_sib_age_grp varchar(30)
,  @race_cd varchar(30)
,  @cd_office varchar(1000)
,  @bin_ihs_svc_cd varchar(30) 
,  @cd_reporter_type varchar(100) 
,  @filter_access_type varchar(30) 
,  @filter_allegation  varchar(30)
, @filter_finding varchar(30) 
, @filter_service_category  varchar(100)
, @filter_service_budget varchar(100))
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

	
	

	declare @errmsg as int
	set @errmsg=0
    declare @intFoundPos integer;

    declare @strElement varchar(3000);
    declare @strValues varchar(3000);
    declare @intVal integer;		
    declare @intincAll integer;

	--declare @ethnicity_cd varchar(30);
	--set @ethnicity_cd='0'
-- used in new filters
	declare @mysql varchar(5000)
	declare @append varchar(100)
	declare @loop int
	declare @maxloop int

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


			--create index idx_cust on #cust(match_code,custody_desc);
	if OBJECT_ID('tempDB..#tmpValues') is not null drop table #tmpValues;
	create table #tmpValues (strVal varchar(10));


    if OBJECT_ID('tempDB..#dt') is not null drop table #dt;
    create table #dt(match_date datetime  PRIMARY KEY);

    

    -----------------------------------  set dates  -------------------------------------  		
    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any   FROM ref_lookup_max_date where id=18;
   	-- dates
	set @strValues=@date;
	set 	@intFoundPos =charindex(',',@strValues,1); 
	while @intFoundPos <>0 
	begin
			set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
			SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
			insert into #tmpValues (strVal) values (@strElement);
			set @intFoundPos=charindex(',',@strValues,1);
		end ;

	if @strValues <> ''  
			INSERT Into #tmpValues(strVal) values (@strValues);
    
	insert into #dt (match_date)
	select cast(strVal as datetime) from #tmpValues;

	select  @mindate=min(dt.match_date),@maxdate=max(dt.match_date) from #dt dt;


   

   
			if OBJECT_ID('tempDB..#age') is not null drop table #age;
			create table #age(age_grouping_cd int,age_grouping varchar(200),match_code int);
			create index idx_age_match_code on #age(match_code);

    
			IF OBJECT_ID('tempDB..#eth') is not null drop table #eth;  
			CREATE TABLE #eth(cd_race int,cd_origin int,tx_race varchar(200),match_code int);
			create index idx_eth_match on  #eth(match_code,cd_origin);
    
	     
     
			if OBJECT_ID('tempDB..#ofc') is not null drop table #ofc;
			create table #ofc(cd_office int,tx_office varchar(200),match_code int );
			--alter table #cnty add primary key(match_code);
			--create index #cnty on idx_cnty_match(cd_cnty,tx_cnty);
    
				create index idx_ofc_match_code on #ofc(match_code);
     


			--- new filters
		
   
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

	

				

		------------------------------------------------  AGE

		delete from #tmpValues;
		set @strValues='';
		set @strValues=@cd_sib_age_grp;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0 
		begin
    
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into #tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
		end ;

		if @strValues <> ''  
				INSERT Into #tmpValues(strVal) values (@strValues);


		insert into #age(age_grouping_cd,age_grouping,match_code)
		select distinct ref_age_groupings_census.age_grouping_cd
		,ref_age_groupings_census.age_grouping
		,ref_age_groupings_census.age_grouping_cd
		from ref_age_groupings_census
		join #tmpValues on cast(strVal as int)=ref_age_groupings_census.age_grouping_cd
		where ref_age_groupings_census.age_grouping_cd <>0 ;


		set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');


		if @intincAll = 0 
		begin
			insert into #age(age_grouping_cd,age_grouping,match_code)
			select distinct coalesce(qAll.Age_Grouping_Cd,0)
				,qAll.age_grouping
				,ref_age_groupings_census.age_grouping_CD
			from ref_age_groupings_census
			left join ref_age_groupings_census qAll on qAll.age_grouping_cd=0
			where  ref_age_groupings_census.age_grouping_cd between 1 and 4;
       
 
		end
		update statistics #age

		------------- race -----------------------------------------------------------------------------
		delete from #tmpValues;
		set @intincAll=null;
		set @strValues=@race_cd;
			set @intFoundPos =charindex(',',@strValues,1);  
			while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);

				insert into #tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1);  
			end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);
		
  
  
			insert into #eth(cd_race,tx_race,cd_origin,match_code)
			select distinct ref_lookup_ethnicity.cd_race_census,ref_lookup_ethnicity.tx_race_census
					,xwlk.census_hispanic_latino_origin_cd
					,ref_lookup_ethnicity.cd_race_census
			from ref_lookup_ethnicity_census ref_lookup_ethnicity
			join #tmpValues on cast(strVal as int)=ref_lookup_ethnicity.CD_RACE_census
			join ref_xwalk_race_origin xwlk on xwlk.cd_race_census =ref_lookup_ethnicity.cd_race_census
			where ref_lookup_ethnicity.cd_race_census between 1 and 8
	
			
		insert into #eth(cd_race,tx_race,cd_origin,match_code)
			select distinct ref_lookup_ethnicity.cd_race_census,ref_lookup_ethnicity.tx_race_census
					,cen.census_Hispanic_Latino_Origin_cd
					,xwlk.cd_race_census
			from ref_lookup_ethnicity_census ref_lookup_ethnicity
			join #tmpValues on cast(strVal as int)=ref_lookup_ethnicity.CD_RACE_census
			join dbo.ref_lookup_hispanic_latino_census cen on cen.cd_race_census=ref_lookup_ethnicity.cd_race_census
			join ref_xwalk_race_origin xwlk on xwlk.census_hispanic_latino_origin_cd=cen.census_Hispanic_Latino_Origin_cd
			where ref_lookup_ethnicity.cd_race_census in (9,10,11,12);
			
	
	
			
			-- all; 
			if (select distinct cast(strVal as int) from #tmpValues where strVal='0')= 0
			begin
					insert into #eth(cd_race,tx_race,cd_origin,match_code)
					select distinct coalesce(qAll.cd_race_census,0),coalesce(qAll.tx_race_census,'All')
						,xwlk.census_hispanic_latino_origin_cd
						,xwlk.cd_race_census
					from ref_lookup_ethnicity_census ref_lookup_ethnicity
					join ref_xwalk_race_origin xwlk on xwlk.cd_race_census =ref_lookup_ethnicity.cd_race_census
					left join ref_lookup_ethnicity_census qAll on qAll.cd_race_census=0
					where ref_lookup_ethnicity.cd_race_census <> 0
			end

			update statistics #eth

	
		---------------------------------------  OFFICE -------------------------
    
    
			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@cd_office;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);


			insert into #ofc(cd_office ,tx_office,match_code)
							select  distinct cd_office
							,tx_office
							,cd_office
							from dbo.ref_lookup_office_collapse
							join #tmpValues on cast(strVal as int)=cd_office
							where cd_office<>0;

			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');


		if @intincAll = 0
		begin
			insert into #ofc(cd_office ,tx_office,match_code)
			select  distinct isnull(qAll.cd_office,0)
					,isnull(qAll.tx_office,'All')
					,ref.cd_office
				from dbo.ref_lookup_office_collapse ref
				left join dbo.ref_lookup_office_collapse qAll on qAll.cd_office=0
				where  ref.cd_office <> 0;



		end;
		update statistics #ofc



					-------------------------------------- IHS SRVC ------------------------------
			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@bin_ihs_svc_cd;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);


			insert into #ihs(bin_ihs_svc_cd ,match_code)
							select  distinct ihs.bin_ihs_svc_cd,ihs.bin_ihs_svc_cd
							from ref_filter_ihs_services ihs
							join #tmpValues on cast(strVal as int)=ihs.bin_ihs_svc_cd
							where ihs.bin_ihs_svc_cd<>0;

			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
	
				insert into #ihs(bin_ihs_svc_cd ,match_code)
							select  distinct 0,ihs.bin_ihs_svc_cd
							from ref_filter_ihs_services ihs
							where ihs.bin_ihs_svc_cd<>0;

		update statistics #ihs
		------------------------------------  REPORTER FILTER ------------------------------


			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@cd_reporter_type;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);


			insert into #rpt(cd_reporter_type ,match_code)
							select  distinct cd_reporter_type,cd_reporter_type
							from ref_filter_reporter_type 
							join #tmpValues on cast(strVal as int)=cd_reporter_type
							where cd_reporter_type<>0;


			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
	
				insert into #rpt(cd_reporter_type ,match_code)
							select  distinct 0,cd_reporter_type
							from ref_filter_reporter_type 
							where cd_reporter_type<>0;	
					
				update statistics #rpt		
		-----------------------------------   access_type --------------------------------------
	
			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@filter_access_type;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);


			insert into #access_type(cd_access_type,filter_access_type ,match_code)
							select  distinct cast(strVal as int),cast(strVal as int),cast(strVal as int)
							from  #tmpValues 
							where cast(strVal as int)=1;
                    


			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into #access_type(cd_access_type,filter_access_type ,match_code)
							select  distinct 0,0,0
							union
							select distinct 0,0,1;

			update statistics #access_type		
		----------------------------------   ALLEGATIONS ---------------------------------------
    
			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@filter_allegation	;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);



	
			insert into #algtn(cd_allegation,filter_allegation,match_code)
			select cd_allegation,cd_allegation ,filter_allegation
			From ref_match_allegation
			join #tmpValues on cast(strVal as int)=ref_match_allegation.cd_allegation
			where ref_match_allegation.cd_allegation <> 0




    
					
			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into #algtn(cd_allegation,filter_allegation,match_code)
							select  distinct 0,0,filter_allegation
							from ref_match_allegation
							where cd_allegation <> 0
							union
							select distinct 0,0,10000;
					
					
			update statistics #algtn
		------------------------------------  FINDINGS --------------------------------------

	
			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@filter_finding;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);




	
			insert into #find(cd_finding,filter_finding,match_code)
			select cd_finding,filter_finding,filter_finding
			from ref_match_finding mf 
			join #tmpValues t on cast(t.strVal as int)=mf.cd_finding
			where mf.cd_finding <> 0

			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into #find(cd_finding,filter_finding,match_code)
							select  distinct 0,0,mf.filter_finding
							from ref_match_finding mf
							where mf.cd_finding <> 0
							union
							select distinct 0,0,10000;
					

				
			update statistics #find					

					



    		-- service type flags	
			if object_ID('tempDB..#srvc') is not null drop table #srvc
			create table #srvc(cd_subctgry_poc_frc int, filter_srvc_type decimal(18,0),match_code decimal(18,0) ,primary key(cd_subctgry_poc_frc,match_code));
			create index idx_srvc on #srvc(match_code)
			-- budget type flags

			if object_ID('tempDB..#budg') is not null drop table #budg
				create table #budg(cd_budget_poc_frc int,filter_budget decimal(18,0),match_code decimal(18,0),primary key(cd_budget_poc_frc,match_code))
				create index idx_budg on #budg(match_code)


		delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@filter_service_category;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);



			insert into #srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
			select s.cd_subctgry_poc_fr,filter_srvc_type,filter_srvc_type
			from ref_match_srvc_type_category s 
			join #tmpValues t on cast(t.strVal as int)=s.cd_subctgry_poc_fr
			where s.cd_subctgry_poc_fr <> 0


			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into #srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
						select  distinct 0,sub.filter_srvc_type,sub.filter_srvc_type
							from  ref_match_srvc_type_category sub
							where sub.cd_subctgry_poc_fr <> 0
							union
							select 0,10000000000000000,10000000000000000;
					

					

				update statistics #srvc					

		-----------------------------------  budget ---------------------------------------

			delete from #tmpValues;
			set @intincAll=null;
			set @strValues=@filter_service_budget;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into #tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into #tmpValues(strVal) values (@strValues);




			insert into #budg(cd_budget_poc_frc,filter_budget,match_code)
				select  distinct sub.cd_budget_poc_frc,sub.filter_service_budget,sub.filter_service_budget
							from  ref_match_srvc_type_budget sub
							join #tmpValues t on cast(t.strVal as int) = sub.cd_budget_poc_frc
			where  sub.cd_budget_poc_frc <> 0

			set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into #budg(cd_budget_poc_frc,filter_budget,match_code)
						select  distinct 0,sub.filter_service_budget,sub.filter_service_budget
							from  ref_match_srvc_type_budget sub
							where  sub.cd_budget_poc_frc <> 0
							union
							select 0 ,sub.cd_multiplier,sub.cd_multiplier from [dbo].[ref_service_cd_budget_poc_frc]  sub where cd_budget_poc_frc=0
						
					

        


			-- print 'qry_id is ' + str(@qry_id)

				---  load the demographic ,placement,location parameters --
 				if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
									,int_match_param_key int not null
					 
								,cd_sib_age_grp int not null
										,cd_race_census int not null
							--	,cd_hispanic_latino_origin int not null
								,cd_office int not null
								,match_cd_sib_age_grp int not null
							
								,match_cd_race_census int not null
								,match_cd_hispanic_latino_origin int not null
								,match_cd_office int not null
								--,ooh_filter_in_cache_table tinyint not null default 0
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(int_param_key,int_match_param_key,cd_sib_age_grp
										,cd_race_census
							,cd_office							
							,match_cd_sib_age_grp
							,match_cd_race_census
							,match_cd_hispanic_latino_origin
							,match_cd_office)

					select distinct
						int_param_key 
						,int_match_param_key
						,prm.cd_sib_age_grp
						,prm.cd_race_census
						,prm.cd_office
						,prm.match_cd_sib_age_grp
						,prm.match_cd_race_census
						,prm.match_cd_hispanic_latino_origin
						,prm.match_cd_office
						--,0 as ooh_filter_in_cache_table
					from  dbo.ref_match_intake_parameters prm
					join #eth eth on eth.match_code=prm.match_cd_race_census
						and eth.cd_origin=prm.match_cd_hispanic_latino_origin
						and eth.cd_race=prm.cd_race_census
					join #age age on  age.age_grouping_cd=prm.cd_sib_age_grp
						and age.match_code=prm.match_cd_sib_age_grp
					join #ofc ofc on ofc.cd_office=prm.cd_office
							and ofc.match_code=prm.match_cd_office
					where prm.fl_in_tbl_intakes = 1;
	   
	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,cd_sib_age_grp
						,cd_race_census
						,cd_office)

					create index idx_int_match_cd_race_census on #prmlocdem(
						cd_race_census
						)

					create index idx_age_grouping_cd on #prmlocdem(
						cd_sib_age_grp
						)
 
					update statistics #prmlocdem


		set @qry_id=(
		select top 1 qry_id from prtl.cache_pbcs3_params
		where cd_sib_age_grp=left(@cd_sib_age_grp,20)
		and cd_race_census=left(@race_cd,30) 
		and cd_office=	left(@cd_office,250)   
		and cd_reporter_type=left(@cd_reporter_type,100)
		and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		and filter_srvc_type=left(@filter_service_category,100)
		and filter_budget=left(@filter_service_budget,100)
		and min_start_date<=@minmonthstart
		and max_start_date >=@maxmonthstart
		order by qry_ID desc
		);  


			if @qry_Id is null
		begin

			INSERT INTO [prtl].[cache_pbcs3_params]
					(qry_id
					, cd_sib_age_grp
					,[cd_race_census]
					,cd_office
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
				select 
					isnull((select max(qry_id)+1 from prtl.cache_pbcs3_params),1)
					,@cd_sib_age_grp
					,@race_cd
					,@cd_office
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
			end
		else
			begin

					update prtl.cache_pbcs3_params
						set cnt_qry=cnt_qry + 1,last_run_date=getdate()
						where @qry_id=qry_id	
			end;
	
							---  print 'qry_id is '  + str(@qry_id) 
			if @qry_id is null									
				select @qry_id=max(qry_id) 
				from prtl.cache_pbcs3_params
				where cd_sib_age_grp=left(@cd_sib_age_grp,20)
				and cd_race_census=left(@race_cd,30) 
				and cd_office=	left(@cd_office,250)   
				and bin_ihs_svc_cd=left(@bin_ihs_svc_cd,30)
				and cd_reporter_type=left(@cd_reporter_type,100)
				and filter_access_type=left(@filter_access_type,30)
				and filter_allegation=left(@filter_allegation,30)
				and filter_finding=left(@filter_finding,30)
				and filter_srvc_type=left(@filter_service_category,100)
				and filter_budget=left(@filter_service_budget,100)
				and min_start_date<=@minmonthstart
				and max_start_date >=@maxmonthstart;
								 
								 
								 		
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
				   ,[cd_office_collapse]
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
	, mtch.cd_sib_age_grp 
	, mtch.cd_race_census
	, mtch.cd_office
    , cal.mnth [Month]
    , sum([cnt_case])/(s3_total.total_cases * 1.00) * 100 as [Placed]
	, 100.00 - sum([cnt_case])/(s3_total.total_cases * 1.00) * 100 as [Not Placed]
	, @minmonthstart as minmonthstart
	, @maxmonthstart as maxmonthstart
	, @x1 as x1
	, @x2   as x2
	, getdate() as insert_date
	, @qry_id
	, year(prtl_pbcs3.cohort_begin_date)
	, che.int_hash_key
  FROM [prtl].[prtl_pbcs3]
  	join #prmlocdem mtch on mtch.int_match_param_key=[prtl_pbcs3].int_match_param_key 
		and  mtch.cd_race_census in (select distinct cd_race from #eth)
	join #ihs ihs on ihs.match_code=prtl_pbcs3.bin_ihs_svc_cd
	join #rpt rpt on rpt.match_code=[prtl_pbcs3].cd_reporter
	join #access_type acc on acc.match_code=[prtl_pbcs3].fl_cps_invs
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
  , (select number * 3 as mnth from numbers where number between 1 and 16) cal 
  , (select s3.[cohort_begin_date]
      ,s3.[date_type]
      ,s3.[qry_type]
	, mtch.cd_sib_age_grp 
	, mtch.cd_race_census
	, mtch.cd_office
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
	, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
      ,sum([cnt_case]) as total_cases
  FROM [prtl].[prtl_pbcs3] s3
  	join #prmlocdem mtch on mtch.int_match_param_key=s3.int_match_param_key 
		and  mtch.cd_race_census in (select distinct cd_race from #eth)
		join #ihs ihs on ihs.match_code=s3.bin_ihs_svc_cd
	join #rpt rpt on rpt.match_code=s3.cd_reporter
	join #access_type acc on acc.match_code=s3.fl_cps_invs
	join #algtn alg on alg.match_code=s3.filter_allegation
	join #find fnd on fnd.match_code=s3.filter_finding
	join #srvc srv on srv.match_code=s3.filter_service_type
	join #budg bud on bud.match_code=s3.filter_budget_type
	group by s3.[cohort_begin_date]
      ,s3.[date_type]
      ,s3.[qry_type]
	, mtch.cd_sib_age_grp 
	, mtch.cd_race_census
	, mtch.cd_office
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
	,srv.cd_subctgry_poc_frc
	,bud.cd_budget_poc_frc) s3_total 
where  s3_total.cohort_begin_date =[prtl_pbcs3].cohort_begin_date
	and s3_total.[date_type] =[prtl_pbcs3].[date_type]
	and s3_total.qry_type =[prtl_pbcs3].qry_type
	and s3_total.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
	and s3_total.cd_sib_age_grp =mtch.cd_sib_age_grp
	and s3_total.cd_race_census =mtch.cd_race_census
	and s3_total.cd_office =mtch.cd_office
	and s3_total.cd_reporter_type =rpt.cd_reporter_type
	and s3_total.cd_access_type=acc.cd_access_type
	and s3_total.cd_allegation=alg.cd_allegation
	and s3_total.cd_finding=fnd.cd_finding
	and s3_total.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
	and s3_total.cd_budget_poc_frc=bud.cd_budget_poc_frc
	and [prtl_pbcs3].min_placed_within_month <=cal.mnth
group by [prtl_pbcs3].[cohort_begin_date]
      ,[prtl_pbcs3].[date_type]
      ,[prtl_pbcs3].[qry_type]
	    , mtch.int_param_key
	, mtch.cd_sib_age_grp 
	, mtch.cd_race_census
	, mtch.cd_office
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
	, mtch.cd_sib_age_grp 
	, mtch.cd_race_census
	, mtch.cd_office
	, ihs.bin_ihs_svc_cd
	, rpt.cd_reporter_type
	, acc.cd_access_type
	, alg.cd_allegation
	, fnd.cd_finding
		, srv.cd_subctgry_poc_frc
	, bud.cd_budget_poc_frc
	  , cal.mnth 

insert into prtl.cache_qry_param_pbcs3
					
					select ck.[int_param_key]
								   ,[bin_ihs_svc_cd]
								   ,[cd_reporter_type]
								   ,[cd_access_type]
								   ,[cd_allegation]
								   ,[cd_finding]
								   ,[cd_subctgry_poc_frc]
								   ,[cd_budget_poc_frc]
								   ,q.cd_sib_age_grp
								   ,q.[cd_race_census]
								   ,q.cd_office
								   ,@qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						join (select distinct int_param_key,cd_sib_age_grp,cd_race_census,cd_office from #prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;

end -- not in cache

        SELECT  
                pbcs3.qry_type as   "qry_type_poc3"
                , pbcs3.date_type
                , pbcs3.start_date  as "Year"
                , pbcs3.cd_sib_age_grp as  "Age_Grouping_Cd"
                , ref_age.tx_sib_age_grp as "Age Grouping"
                , pbcs3.cd_race_census  as "Ethnicity_Cd"
                , ref_eth.tx_race_census as "Race/Ethnicity" 
                , pbcs3.cd_office_collapse as "Office_Cd"
                , ref_ofc.tx_office as Office
                , pbcs3.bin_ihs_svc_cd
                , ref_ihs.bin_ihs_svc_tx as "In-Home Service Desc"
                , pbcs3.cd_reporter_type
                , ref_rpt.tx_reporter_type as "Reporter Desc"
                , pbcs3.cd_access_type
                , ref_acc.tx_access_type as "Access type desc"
                , pbcs3.cd_allegation
                , ref_alg.tx_allegation as "Allegation"
                , pbcs3.cd_finding
                , ref_fnd.tx_finding as "Finding"
                , pbcs3.cd_service_type as "Service Type Cd"
                , ref_srv.tx_subctgry_poc_frc as "Service Type"
                , pbcs3.cd_budget_type as "Budget Cd"
                , ref_bud.tx_budget_poc_frc as "Budget"
                , pbcs3.[month] as "Month"
                , pbcs3.not_placed as "Not Placed"
                , pbcs3.placed as "Placed"
            FROM cache_pbcs3_aggr pbcs3  
            join #cachekeys ck on ck.int_hash_key=pbcs3.int_hash_key
                and pbcs3.qry_id=ck.qry_id
            join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=pbcs3.cd_sib_age_grp
            join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=pbcs3.cd_race_census
            join ref_lookup_office_collapse ref_ofc on ref_ofc.cd_office=pbcs3.cd_office_collapse
            join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=pbcs3.bin_ihs_svc_cd
            join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcs3.cd_reporter_type
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcs3.cd_access_type
            join ref_filter_allegation ref_alg on ref_alg.cd_allegation=pbcs3.cd_allegation
            join ref_filter_finding ref_fnd on ref_fnd.cd_finding=pbcs3.cd_finding
            join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=pbcs3.cd_service_type
            join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=pbcs3.cd_budget_type
            where  pbcs3.start_date 
            between @mindate and @maxdate
            order by pbcs3.qry_type 
                , pbcs3.date_type
                , pbcs3.start_date  
                , pbcs3.cd_sib_age_grp 
                , pbcs3.cd_race_census 
                , pbcs3.cd_office_collapse 
                  , pbcs3.bin_ihs_svc_cd
                , pbcs3.cd_reporter_type
                , pbcs3.cd_access_type
                , pbcs3.cd_allegation
                , pbcs3.cd_finding
                , pbcs3.cd_service_type 
                , pbcs3.cd_budget_type 
                , pbcs3.[month] ;
GO
