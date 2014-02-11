USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[sp_pbcp5]    Script Date: 2/11/2014 11:03:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [prtl].[sp_pbcp5](
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
 )
as

 set nocount on
 

--	declare @date varchar(3000)
--	declare @age_grouping_cd varchar(30)
--	declare @race_cd varchar(30)
--	declare @gender_cd varchar(10)
--	declare @init_cd_plcm_setng varchar(30)
--	declare @long_cd_plcm_setng varchar(30)
--	declare @Removal_Reason_Cd int 
--	declare @County_Cd  varchar(200)
--	declare @custody varchar(10) 
--	declare @bin_los_cd varchar(30) 
--	declare @bin_placement_cd varchar(30) 
--	declare @bin_ihs_svc_cd varchar(30) 
--	declare  @cd_reporter_type varchar(100) 
--	declare  @filter_access_type varchar(30) 
--	declare  @filter_allegation  varchar(100)
--	declare @filter_finding varchar(100)
--	declare  @filter_service_category  varchar(100)
--	declare  @filter_service_budget varchar(100)
	



--	set @date='1/1/2000,1/1/2012'
----	set @age_grouping_cd='1,2,3,4'
--	set @age_grouping_cd='0'
--	--  set @race_cd='1,2,3,4,5,6,8,9,10,11,12'
--	set @race_cd='0'
--	--  set @race_cd='9,11'
--	set @gender_cd='0'
--	set @init_cd_plcm_setng='0'
--	--  set @long_cd_plcm_setng='3,4,5,6,7'
--	set @long_cd_plcm_setng='0'
--	--  set @County_Cd='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39'
--	set @County_Cd='0'
--	-- set @County_Cd='17,27,29'
--	set @bin_los_cd='0'
--	set @bin_placement_cd='0'
--	set @bin_ihs_svc_cd='0'
--	set @cd_reporter_type='0'
--	set @filter_access_type='0'
--	set @filter_allegation='0'
--	set @filter_finding='0'
--	set @filter_service_category='0'
--	set @filter_service_budget='0'
	
	
	

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
	declare @qry_type int;

	declare @cache_qry_id int;
    declare @x1 float;
    declare @x2 float;
    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();



			--create index idx_cust on ##cust(match_code,custody_desc);
	if OBJECT_ID('tempDB..##tmpValues') is not null drop table ##tmpValues;
	create table ##tmpValues (strVal varchar(10));


    if OBJECT_ID('tempDB..##dt') is not null drop table ##dt;
    create table ##dt(match_date datetime  PRIMARY KEY);
    --alter table ##dt add primary key(match_date);
    
	--if @age_grouping_cd ='0'
	--	  and @race_cd ='0'
	--	  and @gender_cd ='0'
	--	  and @init_cd_plcm_setng ='0'
	--	  and @long_cd_plcm_setng ='0'
	--	  and @county_cd ='0'
	--	  and @bin_los_cd ='0'
	--	  and @bin_placement_cd ='0'
	--	  and @bin_ihs_svc_cd ='0'
	--	  and @cd_reporter_type ='0'
	--	  and @filter_access_type ='0'
	--	  and @filter_allegation  ='0'
	--	 and @filter_finding ='0'
	--	 and @filter_service_category  ='0'
	--	 and @filter_service_budget ='0'
	--begin
    -----------------------------------  set dates  -------------------------------------  		

    select @minmonthstart=min_date_any ,@maxmonthstart=max_date_any  FROM ref_lookup_max_date where id=4;


   	-- dates
	set @strValues=@date;
	set 	@intFoundPos =charindex(',',@strValues,1); 
	while @intFoundPos <>0 
	begin
			set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
			SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
			insert into ##tmpValues (strVal) values (@strElement);
			set @intFoundPos=charindex(',',@strValues,1);
		end ;

	if @strValues <> ''  
			INSERT Into ##tmpValues(strVal) values (@strValues);
    
	insert into ##dt (match_date)
	select cast(strVal as datetime) from ##tmpValues;

	select  @mindate=min(dt.match_date),@maxdate=max(dt.match_date) from ##dt dt;


   

   
			if OBJECT_ID('tempDB..##age') is not null drop table ##age;
			create table ##age(age_grouping_cd int,age_grouping varchar(200),match_code int);
			create index idx_age_match_code on ##age(match_code);

    
			IF OBJECT_ID('tempDB..##eth') is not null drop table ##eth;  
			CREATE TABLE ##eth(cd_race int,cd_origin int,tx_race varchar(200),match_code int);
			create index idx_eth_match on  ##eth(match_code,cd_origin);
    
			if OBJECT_ID('tempDB..##gdr') is not null drop table ##gdr;
			create table ##gdr(pk_gndr int,gender_desc  varchar(200),match_code int);
			create index idx_gdr_match_code on ##gdr(match_code);
    
			--alter table ##gdr add primary key(match_code);
			--create index idx_gndr_match on ##gdr(pk_gndr,match_code,cd_gndr);
			if OBJECT_ID('tempDB..##fpl') is not null drop table ##fpl;
			create table  ##fpl(cd_plcm_setng int,tx_plcm_setng  varchar(200),match_code int );
			--alter table ##fpl add primary key(match_code);
			--create index idx_fpl_match on ##fpl(cd_plcm_setng,tx_plcm_setng);
			create index idx_fpl_match_code on ##fpl(match_code);
    
    
			if OBJECT_ID('tempDB..##lpl') is not null drop table ##lpl;
			create table  ##lpl(cd_plcm_setng int,tx_plcm_setng  varchar(200),match_code int );
			--alter table ##lpl add primary key (match_code);
			--create index idx_lpl_match on ##lpl(cd_plcm_setng,tx_plcm_setng);
			create index idx_lpl_match_code on ##lpl(match_code);
     
     
			if OBJECT_ID('tempDB..##cnty') is not null drop table ##cnty;
			create table ##cnty(cd_cnty int,tx_cnty varchar(200),match_code int );
			--alter table ##cnty add primary key(match_code);
			--create index ##cnty on idx_cnty_match(cd_cnty,tx_cnty);
    
				create index idx_cnty_match_code on ##cnty(match_code);
     


			--- new filters
			if OBJECT_ID('tempDB..##los') is not null drop table ##los;
			create table ##los(bin_los_cd int,match_code int ,primary key(bin_los_cd,match_code));
			create index idx_los_match_code on ##los(match_code)
			create index idx_los_match_code2 on ##los(bin_los_cd)
    
			if OBJECT_ID('tempDB..##nbrplc') is not null drop table ##nbrplc;
			create table ##nbrplc(bin_placement_cd int,match_code int ,primary key(bin_placement_cd,match_code));
			create index idx_nbrplcm_match_code on ##nbrplc(match_code)

			if OBJECT_ID('tempDB..##ihs') is not null drop table ##ihs;
			create table ##ihs(bin_ihs_svc_cd int,match_code int  ,primary key(bin_ihs_svc_cd,match_code));
			create index idx_ihs_match_code on ##ihs(match_code)
    
			if OBJECT_ID('tempDB..##rpt') is not null drop table ##rpt;
			create table ##rpt(cd_reporter_type int,match_code int  ,primary key(cd_reporter_type,match_code));
			create index idx_reporter_match_code on ##rpt(match_code)

			if OBJECT_ID('tempDB..##access_type') is not null drop table ##access_type;
			create table ##access_type(cd_access_type int,filter_access_type decimal(18,0),match_code int  );
			create index idx_cd_access_type on ##access_type(cd_access_type,match_code)


	

			-- allegation tables
			if OBJECT_ID('tempDB..##algtn') is not null drop table ##algtn;
			create table ##algtn(cd_allegation  int,filter_allegation decimal(18,0),match_code decimal(18,0) ,primary key(cd_allegation,match_code));
			create index idx_algtn on ##algtn(match_code)

			-- finding tables
			if OBJECT_ID('tempDB..##find') is not null drop table ##find
			create table ##find(cd_finding int,filter_finding  decimal(18,0),match_code decimal(18,0) ,primary key(cd_finding,match_code));
			create index idx_finding on ##find(match_code)

			-- service type flags	
			if object_ID('tempDB..##srvc') is not null drop table ##srvc
			create table ##srvc(cd_subctgry_poc_frc int, filter_srvc_type decimal(18,0),match_code decimal(18,0) ,primary key(cd_subctgry_poc_frc,match_code));
			create index idx_srvc on ##srvc(match_code)
			-- budget type flags

			if object_ID('tempDB..##budg') is not null drop table ##budg
				create table ##budg(cd_budget_poc_frc int,filter_budget decimal(18,0),match_code decimal(18,0),primary key(cd_budget_poc_frc,match_code))
				create index idx_budg on ##budg(match_code)


 

	

				

		------------------------------------------------  AGE

		delete from ##tmpValues;
		set @strValues='';
		set @strValues=@age_grouping_cd;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0 
		begin
    
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into ##tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
		end ;

		if @strValues <> ''  
				INSERT Into ##tmpValues(strVal) values (@strValues);


		insert into ##age(age_grouping_cd,age_grouping,match_code)
		select distinct age.age_grouping_cd
		,age.age_grouping
		,age.age_grouping_cd
		from (select distinct cdc_census_mix_age_cd  age_grouping_cd,cdc_census_mix_age_tx  age_grouping from age_dim where cdc_census_mix_age_cd is not null) age
		join ##tmpValues on cast(strVal as int)=age.age_grouping_cd
		where age.age_grouping_cd <>0 ;


		set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');

		declare @agemin int
		declare @agemax int
		select @agemin=min(cdc_census_mix_age_cd),@agemax=max(cdc_census_mix_age_cd) from age_dim where cdc_census_mix_age_cd is not null;
		if @intincAll = 0 
		begin
			insert into ##age(age_grouping_cd,age_grouping,match_code)
			select distinct coalesce(qAll.Age_Grouping_Cd,0)
				,qAll.age_grouping
				,age.age_grouping_CD
			from (select distinct cdc_census_mix_age_cd  age_grouping_cd,cdc_census_mix_age_tx  age_grouping from age_dim where cdc_census_mix_age_cd is not null) age
			left join (select distinct 0  age_grouping_cd,'All ages 0-17'  age_grouping )  qAll on qAll.age_grouping_cd=0
			where  age.age_grouping_cd between @agemin and @agemax;
       
 
		end
		update statistics ##age

		------------- race -----------------------------------------------------------------------------
		delete from ##tmpValues;
		set @intincAll=null;
		set @strValues=@race_cd;
			set @intFoundPos =charindex(',',@strValues,1);  
			while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);

				insert into ##tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1);  
			end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);
		
  
  
			insert into ##eth(cd_race,tx_race,cd_origin,match_code)
			select distinct ref_lookup_ethnicity.cd_race_census,ref_lookup_ethnicity.tx_race_census
					,xwlk.census_hispanic_latino_origin_cd
					,ref_lookup_ethnicity.cd_race_census
			from ref_lookup_ethnicity_census ref_lookup_ethnicity
			join ##tmpValues on cast(strVal as int)=ref_lookup_ethnicity.CD_RACE_census
			join ref_xwalk_race_origin xwlk on xwlk.cd_race_census =ref_lookup_ethnicity.cd_race_census
			where ref_lookup_ethnicity.cd_race_census between 1 and 8
	
			
		insert into ##eth(cd_race,tx_race,cd_origin,match_code)
			select distinct ref_lookup_ethnicity.cd_race_census,ref_lookup_ethnicity.tx_race_census
					,cen.census_Hispanic_Latino_Origin_cd
					,xwlk.cd_race_census
			from ref_lookup_ethnicity_census ref_lookup_ethnicity
			join ##tmpValues on cast(strVal as int)=ref_lookup_ethnicity.CD_RACE_census
			join dbo.ref_lookup_hispanic_latino_census cen on cen.cd_race_census=ref_lookup_ethnicity.cd_race_census
			join ref_xwalk_race_origin xwlk on xwlk.census_hispanic_latino_origin_cd=cen.census_Hispanic_Latino_Origin_cd
			where ref_lookup_ethnicity.cd_race_census in (9,10,11,12);
			
	
	
			
			-- all; 
			if (select distinct cast(strVal as int) from ##tmpValues where strVal='0')= 0
			begin
					insert into ##eth(cd_race,tx_race,cd_origin,match_code)
					select distinct coalesce(qAll.cd_race_census,0),coalesce(qAll.tx_race_census,'All')
						,xwlk.census_hispanic_latino_origin_cd
						,xwlk.cd_race_census
					from ref_lookup_ethnicity_census ref_lookup_ethnicity
					join ref_xwalk_race_origin xwlk on xwlk.cd_race_census =ref_lookup_ethnicity.cd_race_census
					left join ref_lookup_ethnicity_census qAll on qAll.cd_race_census=0
					where ref_lookup_ethnicity.cd_race_census <> 0
			end

			update statistics ##eth

		---------------------------------------  GENDER ---------------------------------------  
		delete from ##tmpValues;
		set @intincAll=null;
		set @strValues=@gender_cd;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into ##tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
			end;

		if @strValues <> ''  
				INSERT Into ##tmpValues(strVal) values (@strValues);


		insert into ##gdr(PK_GNDR,gender_desc,match_code)
		select distinct ref_lookup_gender.PK_GNDR,ref_lookup_gender.tx_gndr,ref_lookup_gender.PK_GNDR
					from ref_lookup_gender
					join ##tmpValues on cast(strVal as int)=ref_lookup_gender.PK_GNDR
					where ref_lookup_gender.PK_GNDR > 0;

		set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');


		if @intincAll = 0 
		begin
			insert into ##gdr(PK_GNDR,gender_desc,match_code)

			select  distinct coalesce(qAll.pk_gndr,0)
				,qAll.tx_gndr
				,ref_lookup_gender.PK_GNDR
			from ref_lookup_gender
			left join ref_lookup_gender qAll on qAll.pk_gndr=0
				where  ref_lookup_gender.PK_GNDR >0;
    
		end ;
		update statistics ##gdr

		----------------------------------  FIRST PLACEMENT ------------------------------------------------------------
		delete from ##tmpValues;
		set @intincAll=null;
		set @strValues=@init_cd_plcm_setng;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into ##tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
			end ;

		if @strValues <> ''  
				INSERT Into ##tmpValues(strVal) values (@strValues);


		insert into ##fpl(cd_plcm_setng,tx_plcm_setng,match_code)
				select  distinct ref_lookup_placement.cd_plcm_setng
					,ref_lookup_placement.tx_plcm_setng
					,ref_lookup_placement.cd_plcm_setng
					from  dbo.ref_lookup_plcmnt ref_lookup_placement
					join ##tmpValues on cast(strVal as int)=ref_lookup_placement.cd_plcm_setng
				where ref_lookup_placement.cd_plcm_setng <> 0;

		set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');


		if @intincAll = 0 
		begin
			insert into ##fpl(cd_plcm_setng,tx_plcm_setng,match_code)
				select  distinct coalesce(qAll.cd_plcm_setng,0)
						,qAll.tx_plcm_setng
						,ref_lookup_placement.cd_plcm_setng
			from  ref_lookup_plcmnt ref_lookup_placement
			left join ref_lookup_plcmnt qAll on qAll.cd_plcm_setng=0
			where   ref_lookup_placement.cd_plcm_setng <> '0';

		end ;
		update statistics ##fpl

		----------------------------------  LONGEST PLACEMENT ------------------------------------------------------------
		delete from ##tmpValues;
		set @intincAll=null;
		set @strValues=@long_cd_plcm_setng;
		set 	@intFoundPos =charindex(',',@strValues,1); 
		while @intFoundPos <>0  
			begin
				set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
				SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
    
				insert into ##tmpValues (strVal) values (@strElement);
				set @intFoundPos=charindex(',',@strValues,1); 
			end ;

		if @strValues <> ''  
		INSERT Into ##tmpValues(strVal) values (@strValues);


		insert into ##lpl(cd_plcm_setng,tx_plcm_setng,match_code)
					select  distinct ref_lookup_placement.cd_plcm_setng
							,ref_lookup_placement.tx_plcm_setng
							,ref_lookup_placement.cd_plcm_setng
					from  ref_lookup_plcmnt ref_lookup_placement
					join ##tmpValues on cast(strVal as int)=ref_lookup_placement.cd_plcm_setng
				where ref_lookup_placement.cd_plcm_setng <> 0;

		set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');


		if @intincAll = 0 
		begin
			insert into ##lpl(cd_plcm_setng,tx_plcm_setng,match_code)
					select  distinct coalesce(qAll.cd_plcm_setng,0)
						,qAll.tx_plcm_setng
						,ref_lookup_placement.cd_plcm_setng
			from  ref_lookup_plcmnt ref_lookup_placement
			left join ref_lookup_plcmnt qAll on qAll.cd_plcm_setng=0
			where   ref_lookup_placement.cd_plcm_setng <> '0';

    
     
		end
		update statistics ##lpl

		---------------------------------------  County -------------------------
    
    
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@County_Cd;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##cnty(cd_cnty ,tx_cnty,match_code)
							select  distinct ref_lookup_county_all.County_Cd
							,ref_lookup_county_all.county_desc
							,ref_lookup_county_all.County_Cd
							from ref_lookup_county ref_lookup_county_all
							join ##tmpValues on cast(strVal as int)=ref_lookup_county_all.County_Cd
							where ref_lookup_county_all.County_Cd<>0;

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');


		if @intincAll = 0
		begin
			insert into ##cnty(cd_cnty ,tx_cnty,match_code)
			select  distinct isnull(qAll.county_cd,0)
					,qAll.county_desc
					,case when ref_lookup_county_all.County_Cd in (40,999) then -99 else ref_lookup_county_all.County_Cd end
				from ref_lookup_county ref_lookup_county_all
				left join ref_lookup_county qAll on qAll.county_cd=0
				where  ref_lookup_county_all.County_Cd <> 0;



		end;
		update statistics ##cnty

		--------------------------------------------  LOS CODE --------------------------------------------------
    
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@bin_los_cd;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##los(bin_los_cd ,match_code)
							select  distinct los.bin_los_cd,los.bin_los_cd
							from ref_filter_los los
							join ##tmpValues on cast(strVal as int)=los.bin_los_cd
							where los.bin_los_cd<>0;

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
				insert into ##los(bin_los_cd ,match_code)
							select  distinct 0,0;
		
			update statistics ##los				
		-------------------------------------- PLACEMENT CODE ------------------------------
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@bin_placement_cd;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##nbrplc(bin_placement_cd ,match_code)
							select  distinct plc.bin_placement_cd,plc.bin_placement_cd
							from ref_filter_nbr_placement plc
							join ##tmpValues on cast(strVal as int)=plc.bin_placement_cd
							where plc.bin_placement_cd<>0;

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
	
				insert into ##nbrplc(bin_placement_cd ,match_code)
							select  distinct 0,plc.bin_placement_cd
							from ref_filter_nbr_placement plc;
		update statistics ##nbrplc
		-------------------------------------- IHS SRVC ------------------------------
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@bin_ihs_svc_cd;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##ihs(bin_ihs_svc_cd ,match_code)
							select  distinct ihs.bin_ihs_svc_cd,ihs.bin_ihs_svc_cd
							from ref_filter_ihs_services ihs
							join ##tmpValues on cast(strVal as int)=ihs.bin_ihs_svc_cd
							where ihs.bin_ihs_svc_cd<>0;

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
	
				insert into ##ihs(bin_ihs_svc_cd ,match_code)
							select  distinct 0,ihs.bin_ihs_svc_cd
							from ref_filter_ihs_services ihs
							where ihs.bin_ihs_svc_cd<>0;

		update statistics ##ihs
		------------------------------------  REPORTER FILTER ------------------------------


			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@cd_reporter_type;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##rpt(cd_reporter_type ,match_code)
							select  distinct cd_reporter_type,cd_reporter_type
							from ref_filter_reporter_type 
							join ##tmpValues on cast(strVal as int)=cd_reporter_type
							where cd_reporter_type<>0;


			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
	
				insert into ##rpt(cd_reporter_type ,match_code)
							select  distinct 0,cd_reporter_type
							from ref_filter_reporter_type 
							where cd_reporter_type<>0;	
					
				update statistics ##rpt		
		-----------------------------------   access_type --------------------------------------
	
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@filter_access_type;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);


			insert into ##access_type(cd_access_type,filter_access_type ,match_code)
							select  distinct cast(strVal as int),110000,110000
							from  ##tmpValues 
							where cast(strVal as int)=1;
                    


			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into ##access_type(cd_access_type,filter_access_type ,match_code)
							select  distinct 0,100000,100000
							union
							select distinct 0,110000,110000
								union
							select distinct 0,101000,101000
								union
							select distinct 0,100100,100100
								union
							select distinct 0,100010,100010								
							union
							select distinct 0,100001,100001							

			update statistics ##access_type		
		----------------------------------   ALLEGATIONS ---------------------------------------
    
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@filter_allegation	;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);



	
			insert into ##algtn(cd_allegation,filter_allegation,match_code)
			select cd_allegation,filter_allegation ,filter_allegation
			From ref_match_allegation
			join ##tmpValues on cast(strVal as int)=ref_match_allegation.cd_allegation
			where ref_match_allegation.cd_allegation <> 0




    
					
			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into ##algtn(cd_allegation,filter_allegation,match_code)
							select  distinct 0,filter_allegation,filter_allegation
							from ref_match_allegation
							where cd_allegation <> 0
							union
							select distinct 0,10000,10000;
					
					
			update statistics ##algtn
		------------------------------------  FINDINGS --------------------------------------

	
			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@filter_finding;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);




	
			insert into ##find(cd_finding,filter_finding,match_code)
			select cd_finding,filter_finding,filter_finding
			from ref_match_finding mf 
			join ##tmpValues t on cast(t.strVal as int)=mf.cd_finding
			where mf.cd_finding <> 0

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into ##find(cd_finding,filter_finding,match_code)
							select  distinct 0,mf.filter_finding,mf.filter_finding
							from ref_match_finding mf
							where mf.cd_finding <> 0
							union
							select distinct 0,10000,10000;
					

				
			update statistics ##find					

		-----------------------------------  services ---------------------------------------

			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@filter_service_category;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);



			insert into ##srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
			select s.cd_subctgry_poc_fr,filter_srvc_type,filter_srvc_type
			from ref_match_srvc_type_category s 
			join ##tmpValues t on cast(t.strVal as int)=s.cd_subctgry_poc_fr
			where s.cd_subctgry_poc_fr <> 0


			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into ##srvc(cd_subctgry_poc_frc,filter_srvc_type,match_code)
						select  distinct 0,sub.filter_srvc_type,sub.filter_srvc_type
							from  ref_match_srvc_type_category sub
							where sub.cd_subctgry_poc_fr <> 0
							union
							select 0,10000000000000000,10000000000000000;
					

					

				update statistics ##srvc					

		-----------------------------------  budget ---------------------------------------

			delete from ##tmpValues;
			set @intincAll=null;
			set @strValues=@filter_service_budget;
			set 	@intFoundPos =charindex(',',@strValues,1); 
			while @intFoundPos <>0  
				begin
					set @strElement=SUBSTRING(@strValues, 1, @intFoundPos-1); 
					SET @strValues = RIGHT(@strValues,LEN(@strValues)-@intFoundPos);
        
					insert into ##tmpValues (strVal) values (@strElement);
					set @intFoundPos=charindex(',',@strValues,1); 
				end ;

			if @strValues <> ''  
					INSERT Into ##tmpValues(strVal) values (@strValues);




			insert into ##budg(cd_budget_poc_frc,filter_budget,match_code)
				select  distinct sub.cd_budget_poc_frc,sub.filter_service_budget,sub.filter_service_budget
							from  ref_match_srvc_type_budget sub
							join ##tmpValues t on cast(t.strVal as int) = sub.cd_budget_poc_frc
			where  sub.cd_budget_poc_frc <> 0

			set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
			if @intincAll = 0
					insert into ##budg(cd_budget_poc_frc,filter_budget,match_code)
						select  distinct 0,sub.filter_service_budget,sub.filter_service_budget
							from  ref_match_srvc_type_budget sub
							where  sub.cd_budget_poc_frc <> 0
							union select 0,10000000,10000000;
					



				update statistics ##budg

			-- print 'qry_id is ' + str(@qry_id)

				---  load the demographic ,placement,location parameters --
 				if object_ID('tempDB..##prmlocdem') is not null drop table ##prmlocdem
		
					create table ##prmlocdem(int_param_key int not null
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

					insert  into ##prmlocdem(
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

					select   Q.*
					from (select  

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
																(power(10.0,0) * (case when coalesce(cnty.match_code,-99) 
																		not between 1 and 39 then 99 else cnty.match_code end))
																as decimal(9,0)) as int_match_param_key
								, age.match_code as match_age_grouping_cd 
								, eth.match_code as match_cd_race_census
								, eth.cd_origin as match_census_hispanic_latino_origin_cd
								, gdr.match_code as match_pk_gndr
								, fpl.match_code as match_init_cd_plcm_setng
								, lpl.match_code as match_longest_cd_plcm_setng
								, cnty.match_code as match_county_cd
					from ##age age 
					cross join ##eth eth
					cross join ##gdr gdr
					cross join ##fpl fpl
					cross join ##lpl lpl
					cross join ##cnty cnty 
					) q 
	   
	   
	
					create index idx_int_match_param_key_demog_fields on ##prmlocdem(
						int_match_param_key
						,age_grouping_cd
						,cd_race_census
						,pk_gndr
						,init_cd_plcm_setng
						,long_cd_plcm_setng
						,county_cd)

					create index idx_int_match_cd_race_census on ##prmlocdem(
						cd_race_census
						)

					create index idx_age_grouping_cd on ##prmlocdem(
						age_grouping_cd
						)
 
					update statistics ##prmlocdem



				set @qry_id=(
				select top 1 qry_id from prtl.cache_pbcp5_params
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
				and filter_srvc_type=left(@filter_service_category,50)
				and filter_budget=left(@filter_service_budget,50)
				and min_start_date<=@minmonthstart
				and max_start_date >=@maxmonthstart
				order by qry_ID desc
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
					, min_start_date
					, max_start_date
					,[cnt_qry]
					,[last_run_date])
				select 
					isnull((select max(qry_id)+1 from prtl.cache_pbcp5_params),1)
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
					,@minmonthstart
					,@maxmonthstart
					,1
					,getdate()
		
			
			select @qry_id=max(qry_id) 
			from prtl.cache_pbcp5_params
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
			and min_start_date<=@minmonthstart
			and max_start_date >=@maxmonthstart;
			
		end -- if @qry_Id is null
		else -- if @qry_Id is null
			begin
						update prtl.cache_pbcp5_params
									set cnt_qry=cnt_qry + 1,last_run_date=getdate()
									where @qry_id=qry_id				
			end
			-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..##cachekeys') is not null drop table ##cachekeys;

		   select	([int_param_key] * power(10.0,12) ) +
				([bin_los_cd] * power(10.0,11) ) +
					([bin_placement_cd] * power(10.0,10) ) +
					([bin_ihs_svc_cd] * power(10.0,9) ) +
					([cd_reporter_type] * power(10.0,7) ) + 
					( [cd_access_type] * power(10.0,6)) +
					(  [cd_allegation] * power(10.0,5)) +
					(  [cd_finding] * power(10.0,4)) + 
					(  [cd_subctgry_poc_frc] * power(10.0,2))
					 + 					 [cd_budget_poc_frc] as int_hash_key
					 ,int_param_key
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
				into ##cachekeys
				from (select distinct int_param_key from ##prmlocdem) prm
				cross join (select distinct bin_los_cd from ##los) los
				cross join (select distinct bin_placement_cd from ##nbrplc) plc
				cross join (select distinct bin_ihs_svc_cd from ##ihs) ihs
				cross join (select distinct cd_reporter_type from ##rpt) rpt
				cross join (select distinct cd_access_type from ##access_type) acc
				cross join (select distinct cd_allegation from ##algtn) alg
				cross join (select distinct cd_finding from ##find) fnd
				cross join (select distinct cd_subctgry_poc_frc from ##srvc) srvc
				cross join (select distinct cd_budget_poc_frc from ##budg) budg

			create index idx_int_hash_key on ##cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on ##cachekeys(qry_id,int_hash_key);
			create index  idx_params on ##cachekeys(int_param_key,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,cd_budget_poc_frc,cd_subctgry_poc_frc,in_cache);                   
			
			update cache
			set in_cache=1
			from ##cachekeys cache
			join [prtl].[cache_qry_param_pbcp5] pbcp5
			on pbcp5.int_hash_key=cache.int_hash_key



			if NOT (select count(*) from ##cachekeys )=(select sum(in_cache) from ##cachekeys)
			begin
						---  print 'qry_id is '  + str(@qry_id) 
													
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
)

						SELECT    prtl_pbcp5.qry_type
								, prtl_pbcp5.date_type 
								, prtl_pbcp5.[cohort_exit_year]
								, prtl_pbcp5.cd_discharge_type
								, mtch.int_param_key
								, prtl_pbcp5.bin_dep_cd
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
								, n.mnth as reentry_within_month
								, sum(prtl_pbcp5.prsn_cnt)/(tot_cohort.tot_episodes) * 100 as reentry_rate
								, @minmonthstart as minmonthstart
								, @maxmonthstart as maxmonthstart
								, @x1 as x1
								, @x2   as x2
								, getdate() as insert_date
								,@qry_id
								,year(prtl_pbcp5.cohort_exit_year)
								,int_hash_key
							FROM prtl.prtl_pbcp5  
								join (select number * 3 as mnth from numbers where number between 1 and 16) n on n.mnth >=nxt_reentry_within_min_month_mult3
										and nxt_reentry_within_min_month_mult3 >=3
								join ##prmlocdem mtch on mtch.int_match_param_key=prtl_pbcp5.int_match_param_key 
								join (select distinct cd_race from ##eth ) rc on rc.cd_race=mtch.cd_race_census 
								join ##los los on prtl_pbcp5.bin_los_cd=los.match_code
								join ##nbrplc plc on plc.match_code=prtl_pbcp5.bin_placement_cd
								join ##ihs ihs on ihs.match_code=prtl_pbcp5.bin_ihs_svc_cd
								join ##rpt rpt on rpt.match_code=prtl_pbcp5.cd_reporter_type
								join ##access_type acc on acc.match_code=prtl_pbcp5.filter_access_type
								join ##algtn alg on alg.match_code=prtl_pbcp5.filter_allegation
								join ##find fnd on fnd.match_code=prtl_pbcp5.filter_finding
								join ##srvc srv on srv.match_code=prtl_pbcp5.filter_service_type
								join ##budg bud on bud.match_code=prtl_pbcp5.filter_budget_type
								join (select  
												prtl_pbcp5.cohort_exit_year
												,prtl_pbcp5.date_type
												,prtl_pbcp5.qry_type
												,prtl_pbcp5.bin_dep_cd
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
												,cast(sum(prsn_cnt) * 1.0000 as decimal(9,4))  as tot_episodes
										from prtl.prtl_pbcp5 
										join ##prmlocdem mtch on mtch.int_match_param_key=prtl_pbcp5.int_match_param_key 
										join (select distinct cd_race from ##eth ) rc on rc.cd_race=mtch.cd_race_census 
										join ##los los on los.match_code=prtl_pbcp5.bin_los_cd
										join ##nbrplc plc on plc.match_code=prtl_pbcp5.bin_placement_cd
										join ##ihs ihs on ihs.match_code=prtl_pbcp5.bin_ihs_svc_cd
										join ##rpt rpt on rpt.match_code=prtl_pbcp5.cd_reporter_type
										join ##access_type acc on acc.match_code=prtl_pbcp5.filter_access_type
										join ##algtn alg on alg.match_code=prtl_pbcp5.filter_allegation
										join ##find fnd on fnd.match_code=prtl_pbcp5.filter_finding
										join ##srvc srv on srv.match_code=prtl_pbcp5.filter_service_type
										join ##budg bud on bud.match_code=prtl_pbcp5.filter_budget_type
										group by 	prtl_pbcp5.cohort_exit_year
												,prtl_pbcp5.date_type
												,prtl_pbcp5.qry_type
												,prtl_pbcp5.bin_dep_cd
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
									)  tot_cohort on tot_cohort.cohort_exit_year=prtl_pbcp5.cohort_exit_year
										and tot_cohort.qry_type=prtl_pbcp5.qry_type
										and tot_cohort.date_type=prtl_pbcp5.date_type
										and tot_cohort.bin_dep_cd=prtl_pbcp5.bin_dep_cd
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
							 join ##cachekeys che on che.int_param_key = mtch.int_param_key
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
							where prtl_pbcp5.cohort_exit_year between @minmonthstart and @maxmonthstart --  @exit_year  and @exit_year_stop
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
									, prtl_pbcp5.bin_dep_cd
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
									, n.mnth 
							order by  prtl_pbcp5.bin_dep_cd,prtl_pbcp5.qry_type
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
										, los.bin_los_cd
									, plc.bin_placement_cd
									, ihs.bin_ihs_svc_cd
									, rpt.cd_reporter_type
									, acc.cd_access_type
									, alg.cd_allegation
									, fnd.cd_finding
									, srv.cd_subctgry_poc_frc
									, bud.cd_budget_poc_frc 
									, n.mnth 

						--	commit tran t1;
						--	set @exit_year=@exit_year + 1;
						--end -- insert loop

						update statistics prtl.cache_pbcp5_aggr

						INSERT INTO [prtl].[cache_qry_param_pbcp5]
								   ([int_param_key]
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
								   ,@qry_id
								   ,[int_hash_key]
						from ##cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from ##prmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;




						
	
						update statistics prtl.cache_qry_param_pbcp5;

						
					  end -- if @qry_id is null
					
		
								SELECT 
						  pbcp5.cohort_exit_year as "Cohort Entry Date"
						, [qry_type]
						, [date_type]
						, pbcp5.[cd_discharge_type]
						, dsch.discharge_type as "Discharge Type"
						, pbcp5.[age_grouping_cd]
						, ref_age.age_grouping as "Age Grouping"
						, pbcp5.[cd_race] as Ethnicity_Cd
						, ref_eth.tx_race_census as  "Race/Ethnicity" 
						, pbcp5.[pk_gndr] as Gender_Cd
						, ref_gdr.cd_gndr as "Gender"
						, pbcp5.[init_cd_plcm_setng] as init_plcmnt_Cd
						, ref_fpl.tx_plcm_setng as  "Initial Placement"
						, pbcp5.[long_cd_plcm_setng] as long_plcmnt_cd
						, ref_lpl.tx_plcm_setng as  "Longest Placement"
						, pbcp5.[county_cd]
						, ref_cnty.county_desc as "County"
						, pbcp5.[bin_dep_cd] as  "Dependency Cd"
						, ref_dep.bin_dep_desc as "Dependency"
						, pbcp5.[bin_los_cd]
						, ref_los.bin_los_desc as "Length of Service Desc"
						, pbcp5.[bin_placement_cd]
						, ref_plc.bin_placement_desc  as "Placement Count Desc"
						, pbcp5.[bin_ihs_svc_cd]
						, ref_ihs.bin_ihs_svc_tx as "In-Home Service Desc"
						, pbcp5.[cd_reporter_type]
						, ref_rpt.tx_reporter_type as [Reporter Desc]
						, pbcp5.[cd_access_type]
						, ref_acc.tx_access_type as [Access type desc]
						, pbcp5.[cd_allegation]
						, ref_alg.tx_allegation as "Allegation" 
						, pbcp5.[cd_finding]
						, ref_fnd.tx_finding as "Finding"
						, pbcp5.[cd_subctgry_poc_frc] as "Service Type Cd"
						, ref_srv.tx_subctgry_poc_frc as "Service Type"
						, pbcp5.[cd_budget_poc_frc]as [Budget Cd]
						, ref_bud.tx_budget_poc_frc as [Budget]
						,pbcp5.reentry_within_month as [Month]
						,pbcp5.reentry_rate as [Percent Reentry]
    					  FROM [prtl].[cache_pbcp5_aggr] pbcp5
					join (select distinct int_param_key from #prmlocdem ) prm on prm.int_param_key=pbcp5.int_param_key
					join  (select distinct bin_los_cd from #los) los on los.bin_los_cd=pbcp5.bin_los_cd
						join (select distinct bin_placement_cd from #nbrplc) plc on plc.bin_placement_cd=pbcp5.bin_placement_cd
						join (select distinct bin_ihs_svc_cd from #ihs) ihs on ihs.bin_ihs_svc_cd=pbcp5.bin_ihs_svc_cd
						join (select distinct cd_reporter_type from #rpt) rpt on rpt.cd_reporter_type=pbcp5.cd_reporter_type
						join (select distinct cd_access_type from #access_type) acc on acc.cd_access_type=pbcp5.cd_access_type
						join (select distinct cd_allegation from #algtn) alg on alg.cd_allegation=pbcp5.cd_allegation
						join (select distinct cd_finding from #find) fnd on fnd.cd_finding=pbcp5.cd_finding
						join (select distinct cd_subctgry_poc_frc from #srvc) srv on srv.cd_subctgry_poc_frc=pbcp5.cd_subctgry_poc_frc
						join (select distinct cd_budget_poc_frc from #budg) bud on bud.cd_budget_poc_frc=pbcp5.cd_budget_poc_frc
						join (select distinct cdc_census_mix_age_cd age_grouping_cd,cdc_census_mix_age_tx as age_grouping 
									from age_dim where cdc_census_mix_age_cd is not null
								union select 0,'All ages (0-17)') ref_age on ref_age.age_grouping_cd=pbcp5.age_grouping_cd
						join (select distinct cd_discharge_type,discharge_type from ref_state_discharge_xwalk) dsch on dsch.cd_discharge_type=pbcp5.cd_discharge_type
						join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=pbcp5.cd_race
						join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=pbcp5.pk_gndr
						join ref_lookup_plcmnt ref_fpl on ref_fpl.cd_plcm_setng=pbcp5.init_cd_plcm_setng
						join ref_lookup_plcmnt ref_lpl on ref_lpl.cd_plcm_setng=pbcp5.long_cd_plcm_setng
						join ref_lookup_county ref_cnty on ref_cnty.county_cd=pbcp5.county_cd
						join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=pbcp5.bin_dep_cd
						join ref_filter_los ref_los on ref_los.bin_los_cd=pbcp5.bin_los_cd
						join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=pbcp5.bin_placement_cd
						join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=pbcp5.bin_ihs_svc_cd
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcp5.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcp5.cd_access_type
						join ref_filter_allegation ref_alg on ref_alg.cd_allegation=pbcp5.cd_allegation
						join ref_filter_finding ref_fnd on ref_fnd.cd_finding=pbcp5.cd_finding
						join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=pbcp5.cd_subctgry_poc_frc
						join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=pbcp5.cd_budget_poc_frc
            where pbcp5.cohort_exit_year   between @mindate and @maxdate
			 order by qry_type
                ,date_type
                ,cohort_exit_year asc
                ,age_grouping_cd asc
                    ,pbcp5.cd_race  asc
                    ,pbcp5.pk_gndr asc
                    ,pbcp5.init_cd_plcm_setng asc
                    ,pbcp5.long_cd_plcm_setng asc
                    ,pbcp5.county_cd asc
                    ,pbcp5.bin_dep_cd asc
                    , pbcp5.bin_los_cd asc
                    , pbcp5.bin_placement_cd asc
                    , pbcp5.bin_ihs_svc_cd asc
                    , pbcp5.cd_reporter_type
                    , pbcp5.cd_access_type
                    , pbcp5.cd_allegation
                    , pbcp5.cd_finding
                    , pbcp5.cd_subctgry_poc_frc
                    , pbcp5.cd_budget_poc_frc
            ,pbcp5.cd_discharge_type asc; 
			
				

