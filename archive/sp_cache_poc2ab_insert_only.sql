USE [CA_ODS]
GO

ALTER PROCEDURE [prtl].[sp_cache_poc2ab_counts](
   @date varchar(3000)
,  @age_grouping_cd varchar(30)
,  @race_cd varchar(30)
,  @gender_cd varchar(10)
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
	--set @gender_cd='0'
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
    
			if OBJECT_ID('tempDB..#gdr') is not null drop table #gdr;
			create table #gdr(pk_gndr int,gender_desc  varchar(200),match_code int);
			create index idx_gdr_match_code on #gdr(match_code);
    

     
     
			if OBJECT_ID('tempDB..#ofc') is not null drop table #ofc;
			create table #ofc(cd_office int,tx_office varchar(200),match_code int );
			--alter table #cnty add primary key(match_code);
			--create index #cnty on idx_cnty_match(cd_cnty,tx_cnty);
    
				create index idx_ofc_match_code on #ofc(match_code);
     


			--- new filters
		
   
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
		set @strValues=@age_grouping_cd;
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

		---------------------------------------  GENDER ---------------------------------------  
		delete from #tmpValues;
		set @intincAll=null;
		set @strValues=@gender_cd;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into #tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
			end;

		if @strValues <> ''  
				INSERT Into #tmpValues(strVal) values (@strValues);


		insert into #gdr(PK_GNDR,gender_desc,match_code)
		select distinct ref_lookup_gender.PK_GNDR,ref_lookup_gender.tx_gndr,ref_lookup_gender.PK_GNDR
					from ref_lookup_gender
					join #tmpValues on cast(strVal as int)=ref_lookup_gender.PK_GNDR
					where ref_lookup_gender.PK_GNDR > 0;

		set @intincAll = (select top 1 cast(strVal as int) from #tmpValues where strVal='0');


		if @intincAll = 0 
		begin
			insert into #gdr(PK_GNDR,gender_desc,match_code)

			select  distinct coalesce(qAll.pk_gndr,0)
				,qAll.tx_gndr
				,ref_lookup_gender.PK_GNDR
			from ref_lookup_gender
			left join ref_lookup_gender qAll on qAll.pk_gndr=0
				where  ref_lookup_gender.PK_GNDR >0;
    
		end ;
		update statistics #gdr

	
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

					



    
        


			-- print 'qry_id is ' + str(@qry_id)

				---  load the demographic ,placement,location parameters --
 				if object_ID('tempDB..#prmlocdem') is not null drop table #prmlocdem
		
					create table #prmlocdem(int_param_key int not null
									,int_match_param_key int not null
					 
								,cd_sib_age_grp int not null
								,pk_gndr int not null
								,cd_race_census int not null
							--	,cd_hispanic_latino_origin int not null
								,cd_office int not null
								,match_cd_sib_age_grp int not null
								,match_pk_gndr int not null
								,match_cd_race_census int not null
								,match_cd_hispanic_latino_origin int not null
								,match_cd_office int not null
								--,ooh_filter_in_cache_table tinyint not null default 0
								,primary key (int_param_key,int_match_param_key));

					insert  into #prmlocdem(int_param_key,int_match_param_key,cd_sib_age_grp
							,pk_gndr
							,cd_race_census
							,cd_office							
							,match_cd_sib_age_grp
							,match_pk_gndr
							,match_cd_race_census
							,match_cd_hispanic_latino_origin
							,match_cd_office)

					select distinct
						int_param_key 
						,int_match_param_key
						,prm.cd_sib_age_grp
						,prm.pk_gndr
						,prm.cd_race_census
						,prm.cd_office
						,prm.match_cd_sib_age_grp
						,prm.match_pk_gndr
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
					join #gdr gdr on gdr.pk_gndr=prm.pk_gndr
							and gdr.match_code=prm.match_pk_gndr
					join #ofc ofc on ofc.cd_office=prm.cd_office
							and ofc.match_code=prm.match_cd_office
					where prm.fl_in_tbl_intakes = 1;
	   
	
					create index idx_int_match_param_key_demog_fields on #prmlocdem(
						int_match_param_key
						,cd_sib_age_grp
						,pk_gndr
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
		select top 1 qry_id from prtl.cache_poc2ab_params
		where age_grouping_cd=left(@age_grouping_cd,20)
		and cd_race_census=left(@race_cd,30) 
		and pk_gndr=left(@gender_cd,10) 
		and cd_office=	left(@cd_office,250)   
		and cd_reporter_type=left(@cd_reporter_type,100)
		and filter_access_type=left(@filter_access_type,30)
		and filter_allegation=left(@filter_allegation,30)
		and filter_finding=left(@filter_finding,30)
		and min_start_date<=@minmonthstart
		and max_start_date >=@maxmonthstart
		order by qry_ID desc
		);  


		if @qry_Id is null
		begin

			INSERT INTO [prtl].[cache_poc2ab_params]
					(qry_id
					, [age_grouping_cd]
					,[cd_race_census]
					,[pk_gndr]
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
					,@gender_cd
					,@cd_office
					,@cd_reporter_type
					,@filter_access_type
					,@filter_allegation
					,@filter_finding
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()
		
			
			-- see if results are in cache as a subset of previously run query
			-- if so get that qry_id
			select top 1 @qry_id=qry.qry_id
				from (
					select qry_ID,count(distinct param_pos) as match_cnt
					from (
						select qry_id,param_pos
						,count(distinct param_value) as cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #age age on age.age_grouping_cd=param_value and param_pos=1
						join (select count(distinct age_grouping_cd) 
									as cnt_sel from #age)
								 q on 1=1
								group by qry_id,param_pos,q.cnt_sel
						having count(distinct age_grouping_cd)  = cnt_sel 
					union
	
						select qry_id,param_pos
						,count(distinct param_value)as  cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #eth eth on eth.cd_race=param_value and param_pos=2
						join (select count(distinct cd_race) 
								as cnt_sel from #eth) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel
					union
						select qry_id,param_pos
						,count(distinct param_value) as cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #gdr gdr on gdr.pk_gndr=param_value and param_pos=3
						join (select count(distinct pk_gndr) 
								as cnt_sel from #gdr) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel
					union
						select qry_id,param_pos
						,count(distinct param_value) as cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #ofc ofc on ofc.cd_office=param_value and param_pos=4
						join (select count(distinct cd_office) 
								as cnt_sel from #ofc) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel
					union						
						select qry_id,param_pos
						,count(distinct param_value) as  cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #rpt prm on prm.cd_reporter_type=param_value and param_pos=5
						join (select count(distinct cd_reporter_type) 
								as cnt_sel from #rpt) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel
					union
						select qry_id,param_pos
						,count(distinct param_value) as  cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #access_type prm on prm.cd_access_type=param_value and param_pos=6
						join (select count(distinct cd_access_type) 
								as cnt_sel from #access_type) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel
					union
						select qry_id,param_pos
						,count(distinct param_value) as  cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #algtn prm on prm.cd_allegation=param_value and param_pos=7
						join (select count(distinct cd_allegation) 
								as cnt_sel from #algtn) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel	
					union
						select qry_id,param_pos,count(distinct param_value) as  cnt_val
						,q.cnt_sel
						from prtl.cache_qry_param_poc2ab
						join #find prm on prm.cd_finding=param_value and param_pos=8
						join (select count(distinct cd_finding) 
								as cnt_sel from #find) q on 1=1
						group by qry_id,param_pos,q.cnt_sel
						having count(distinct param_value) = cnt_sel	
					) q
					group by qry_id
					--order by count(distinct param_pos) desc,qry_id asc
				) qry
			where qry.match_cnt=8

					-- qry_id is still null
			if @qry_id is  null 
				begin

						---  print 'qry_id is '  + str(@qry_id) 
													
					select @qry_id=max(qry_id) 
					from prtl.cache_poc2ab_params
					where age_grouping_cd=left(@age_grouping_cd,20)
					and cd_race_census=left(@race_cd,30) 
					and pk_gndr=left(@gender_cd,10) 
					and cd_office=	left(@cd_office,250)   
					and cd_reporter_type=left(@cd_reporter_type,100)
					and filter_access_type=left(@filter_access_type,30)
					and filter_allegation=left(@filter_allegation,30)
					and filter_finding=left(@filter_finding,30)
					and min_start_date<=@minmonthstart
					and max_start_date >=@maxmonthstart;
								 
					declare @start_year int
					declare @start_year_stop int 
					set @start_year = year(@minmonthstart)
					set @start_year_stop = (select year(cutoff_date) from ref_Last_DW_Transfer);

					while @start_year <= @start_year_stop
					begin
						begin tran t1
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
								,[pk_gndr]
								,cd_office
								,[cnt_start_date]
								,[cnt_entries]
								,[cnt_exits]
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
								, mtch.pk_gndr
								, mtch.cd_office
								, isnull(sum(prtl_poc2ab.cnt_start_date),0) as cnt_start_date
								, isnull(sum(prtl_poc2ab.cnt_entries),0) as cnt_entries
								, isnull(sum(prtl_poc2ab.cnt_exits),0) as cnt_exits
								--, '2000-01-01' as minmonthstart
								--, '2013-07-01' as maxmonthstart
								--, null as x1
								--, null   as x2
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								, @x1 as x1  
								, @x2   as x2
								, getdate() as insert_date
								, cast(cast(int_param_key as char(8))
								--+ cast(bin_dep_cd  as char(1))
								+ case when rpt.cd_reporter_type between 0 and 9 then '0' + cast(rpt.cd_reporter_type as char(1)) else cast(rpt.cd_reporter_type as char(2)) end
								+  cast(acc.cd_access_type as char(1))
								+ cast(alg.cd_allegation as char(1))
								+ cast(fnd.cd_finding as char(1))
								 as decimal(21,0))
								,@qry_id
								,prtl_poc2ab.[start_year]
							FROM prtl.prtl_poc2ab  
								join #prmlocdem mtch on mtch.int_match_param_key=prtl_poc2ab.int_match_param_key 
								join (select distinct cd_race from #eth ) rc on rc.cd_race=mtch.cd_race_census 
								join #rpt rpt on rpt.match_code=prtl_poc2ab.cd_reporter_type
								join #access_type acc on acc.match_code=prtl_poc2ab.fl_cps_invs
								join #algtn alg on alg.match_code=prtl_poc2ab.filter_allegation
								join #find fnd on fnd.match_code=prtl_poc2ab.filter_finding
							where prtl_poc2ab.[start_year] = @start_year 
								and NOT EXISTS(select 1 
												from prtl.cache_poc2ab_aggr che
												where che.start_date=prtl_poc2ab.start_date
													and che.int_param_key = mtch.int_param_key
													and che.cd_reporter_type=rpt.cd_reporter_type
													and che.cd_allegation=alg.cd_allegation
													and che.cd_finding=fnd.cd_finding
													and che.cd_access_type=acc.cd_access_type
											)
							group by  prtl_poc2ab.qry_type
									,prtl_poc2ab.date_type 
									,prtl_poc2ab.[start_date]
									,prtl_poc2ab.[start_year]
									,mtch.int_param_key
									,mtch.cd_sib_age_grp 
									,mtch.pk_gndr
									,mtch.cd_race_census
									,mtch.cd_office
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									, fnd.cd_finding
								commit tran t1;
							set @start_year=@start_year + 1;
						end -- insert loop

						update statistics prtl.cache_poc2ab_aggr
		
						insert into prtl.cache_qry_param_poc2ab
						(qry_id,param_value,param_name,param_pos)
						select distinct @qry_id,age_grouping_cd,'cd_sib_age_grp',1 from #age
						union 
						select distinct  @qry_id,cd_race,'cd_race',2 from #eth
						union 
						select distinct @qry_id,pk_gndr,'pk_gndr',3 from #gdr
						union
						select distinct @qry_id,cd_office,'county_cd',4 from #ofc
						union
						select distinct @qry_id,cd_reporter_type,'cd_reporter_type',5 from #rpt
						union
						select distinct @qry_id,cd_access_type,'cd_access_type',6 from #access_type
						union
						select distinct @qry_id,cd_allegation,'cd_allegation',7 from #algtn
						union
						select distinct @qry_id,cd_finding,'cd_finding',8 from #find
						
	
						update statistics prtl.cache_qry_param_poc2ab;

						end -- if @qry_id is still null
					  end -- if @qry_id is null
					else  If @qry_id is not null
						begin
									update prtl.cache_poc2ab_params
									set cnt_qry=cnt_qry + 1,last_run_date=getdate()
									where @qry_id=qry_id
							

											
					end



						SELECT  
								poc2ab.qry_type as   "qry_type_poc2"
								, poc2ab.date_type
								, poc2ab.start_date  as "Month"
								, poc2ab.cd_sib_age_grp as  "Age_Grouping_Cd"
								, ref_age.tx_sib_age_grp as "Age Grouping"
								, poc2ab.pk_gndr  as "Gender_Cd"
								, ref_gdr.tx_gndr as "Gender" 
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
								, case when (cnt_entries) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_entries) 
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
									(case when (cnt_entries) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_entries) 
									end)) >= -- exited care
										(case when (cnt_exits) > 0 /* jitter all above 0 */ 
											then 
												case when (round(cnt_exits + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
												then 1
												else round(cnt_exits + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
												end
											else cnt_exits
										end)
                    
									then -- use exits as they are
									(case when (cnt_exits) > 0 /* jitter all above 0 */ 
											then 
												case when (round(cnt_exits + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
												then 1
												else round(cnt_exits + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
												end
											else cnt_exits
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
									(case when (cnt_entries) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0) ) <1
											then 1
											else round(cnt_entries + 2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2),0)
											end
										else (cnt_entries) 
									end)
								end as "Case Closures"
						FROM prtl.cache_poc2ab_aggr poc2ab  
						 join (select distinct int_param_key from #prmlocdem ) prm on prm.int_param_key=poc2ab.int_param_key
						join (select distinct cd_reporter_type from #rpt) rpt on rpt.cd_reporter_type=poc2ab.cd_reporter_type
						join (select distinct cd_access_type from #access_type) acc on acc.cd_access_type=poc2ab.cd_access_type
						join (select distinct cd_allegation from #algtn) alg on alg.cd_allegation=poc2ab.cd_allegation
						join (select distinct cd_finding from #find) fnd on fnd.cd_finding=poc2ab.cd_finding
						join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=poc2ab.cd_sib_age_grp
						join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc2ab.cd_race
						join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc2ab.pk_gndr
						join ref_lookup_office_collapse ref_ofc on ref_ofc.cd_office=poc2ab.cd_office
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc2ab.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc2ab.cd_access_type
						join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc2ab.cd_allegation
						join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc2ab.cd_finding
            where poc2ab.start_date   between @mindate and @maxdate
			order by date_type,qry_type,start_date;
						

			






 
 
