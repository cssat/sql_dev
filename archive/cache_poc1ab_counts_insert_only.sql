--USE [CA_ODS]
--GO


--ALTER PROCEDURE [prtl].[cache_poc1ab_counts_insert_only](
--   @date varchar(3000)
--,  @age_grouping_cd varchar(30)
--,  @race_cd varchar(30)
--,  @gender_cd varchar(10)
--,  @init_cd_plcm_setng varchar(30)
--,  @long_cd_plcm_setng varchar(30) 
--,  @county_cd varchar(200) 
--,  @bin_los_cd varchar(30) 
--,  @bin_placement_cd varchar(30) 
--,  @bin_ihs_svc_cd varchar(30) 
--,  @cd_reporter_type varchar(100) 
--,  @filter_access_type varchar(30) 
--,  @filter_allegation  varchar(30)
--, @filter_finding varchar(30)
--, @filter_service_category  varchar(100)
--, @filter_service_budget varchar(100)
-- )
--as
-- set nocount on



	declare @date varchar(3000)
	declare @age_grouping_cd varchar(30)
	declare @race_cd varchar(30)
	declare @gender_cd varchar(10)
	declare @init_cd_plcm_setng varchar(30)
	declare @long_cd_plcm_setng varchar(30)
	declare @Removal_Reason_Cd int 
	declare @County_Cd  varchar(200)
	declare @custody varchar(10) 
	declare @bin_los_cd varchar(30) 
	declare @bin_placement_cd varchar(30) 
	declare @bin_ihs_svc_cd varchar(30) 
	declare  @cd_reporter_type varchar(100) 
	declare  @filter_access_type varchar(30) 
	declare  @filter_allegation  varchar(100)
	declare @filter_finding varchar(100)
	declare  @filter_service_category  varchar(100)
	declare  @filter_service_budget varchar(100)
	



	set @date='1/1/2000,07/31/2013'
	set @age_grouping_cd='0'
	--set @age_grouping_cd='1,2,3,4'
	--set @race_cd='0'
	set @race_cd='0'
	set @gender_cd='0'
	set @init_cd_plcm_setng='0'
	set @long_cd_plcm_setng='0'
	set @County_Cd='17,27'
	--set @County_Cd='17,27,29'
	set @bin_los_cd='0'
	set @bin_placement_cd='0'
	set @bin_ihs_svc_cd='0'
	set @cd_reporter_type='0'
	set @filter_access_type='0'
	set @filter_allegation='0'
	set @filter_finding='0'
	set @filter_service_category='0'
	set @filter_service_budget='0'
	
	
	

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
    declare @row_cnt_param int;
    declare @row_cnt_cache int;
    declare @x1 float;
    declare @x2 float;
    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();


	
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
    select @minmonthstart=min_date_any ,@maxmonthstart='2013-07-01'   FROM ref_lookup_max_date where id=19;
    select @mindate=min(match_date),@maxdate=max(match_date)  from ##dt;

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


 
     --create index idx_cust on ##cust(match_code,custody_desc);
    if OBJECT_ID('tempDB..##tmpValues') is not null drop table ##tmpValues;
    create table ##tmpValues (strVal varchar(10));
	

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
select distinct ref_age_groupings_census.age_grouping_cd
,ref_age_groupings_census.age_grouping
,ref_age_groupings_census.age_grouping_cd
from ref_age_groupings_census
join ##tmpValues on cast(strVal as int)=ref_age_groupings_census.age_grouping_cd
where ref_age_groupings_census.age_grouping_cd <>0 ;


set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');


if @intincAll = 0 
begin
    insert into ##age(age_grouping_cd,age_grouping,match_code)
    select distinct coalesce(qAll.Age_Grouping_Cd,0)
		,qAll.age_grouping
		,ref_age_groupings_census.age_grouping_CD
    from ref_age_groupings_census
    left join ref_age_groupings_census qAll on qAll.age_grouping_cd=0
    where  ref_age_groupings_census.age_grouping_cd between 1 and 4;
       
 
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
                    select  distinct cast(strVal as int),cast(strVal as int),cast(strVal as int)
					from  ##tmpValues 
					where cast(strVal as int)=1;
                    


    set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
	if @intincAll = 0
			insert into ##access_type(cd_access_type,filter_access_type ,match_code)
                    select  distinct 0,0,0
					union
					select distinct 0,0,1;

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
	select cd_allegation,cd_allegation ,filter_allegation
	From ref_match_allegation
	join ##tmpValues on cast(strVal as int)=ref_match_allegation.cd_allegation
	where ref_match_allegation.cd_allegation <> 0




    
					
    set @intincAll = (select top 1 cast(strVal as int) from ##tmpValues where strVal='0');
  
	if @intincAll = 0
			insert into ##algtn(cd_allegation,filter_allegation,match_code)
                    select  distinct 0,0,filter_allegation
					from ref_match_allegation
					where cd_allegation <> 0
					union
					select distinct 0,0,10000;
					
					
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
                    select  distinct 0,0,mf.filter_finding
					from ref_match_finding mf
					where mf.cd_finding <> 0
					union
					select distinct 0,0,10000;
					

				
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
             select  distinct 0,0,sub.filter_srvc_type
					from  ref_match_srvc_type_category sub
					where sub.cd_subctgry_poc_fr <> 0
					union
					select 0,0,10000000000000000;
					

					

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
             select  distinct 0,0,sub.filter_service_budget
					from  ref_match_srvc_type_budget sub
					where  sub.cd_budget_poc_frc <> 0
					union select 0,0,10000000;
					



		update statistics ##budg



    
        
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
		and filter_srvc_type=left(@filter_service_category,30)
		and filter_budget=left(@filter_service_budget,50)
        and min_start_date<=@minmonthstart
        and max_start_date >=@maxmonthstart
       order by qry_ID desc
	    );  

	-- print 'qry_id is ' + str(@qry_id)

		---  load the demographic ,placement,location parameters --
 		if object_ID('tempDB..##prmlocdem') is not null drop table ##prmlocdem
		
			create table ##prmlocdem(int_param_key int not null
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
						,match_init_cd_plcm_setng int not null
						,match_long_cd_plcm_setng int not null
						,match_county_cd int not null
						,match_cd_hispanic_latino_origin int not null
						--,ooh_filter_in_cache_table tinyint not null default 0
						,primary key (int_param_key,int_match_param_key));

			insert  into ##prmlocdem(int_param_key,int_match_param_key,age_grouping_cd,pk_gndr,cd_race_census
			--,cd_hispanic_latino_origin
					,init_cd_plcm_setng,long_cd_plcm_setng,county_cd
					,match_age_grouping_cd
					,match_pk_gdnr
					,match_cd_race_census
					,match_cd_hispanic_latino_origin
					,match_init_cd_plcm_setng
					,match_long_cd_plcm_setng
					,match_county_cd)

			select distinct
				int_param_key 
				,int_match_param_key
				,ooh.age_grouping_cd
				,ooh.pk_gndr
				,ooh.cd_race_census
				--,ooh.cd_hispanic_latino_origin
				,ooh.init_cd_plcm_setng
				,ooh.long_cd_plcm_setng
				,ooh.county_cd
				,ooh.match_age_grouping_cd
				,ooh.match_pk_gndr
				,ooh.match_cd_race_census
				,ooh.match_cd_hispanic_latino_origin
				,ooh.match_init_cd_plcm_setng
				,ooh.match_long_cd_plcm_setng
				,ooh.match_county_cd
				--,0 as ooh_filter_in_cache_table
			from  dbo.ref_match_ooh_parameters ooh
			join ##eth eth on eth.match_code=ooh.match_cd_race_census
				and eth.cd_origin=ooh.match_cd_hispanic_latino_origin
				and eth.cd_race=ooh.cd_race_census
			join ##age age on  age.age_grouping_cd=ooh.age_grouping_cd
				and age.match_code=ooh.match_age_grouping_cd
			join ##gdr gdr on gdr.pk_gndr=ooh.pk_gndr
					and gdr.match_code=ooh.match_pk_gndr
			join ##fpl fpl on fpl.cd_plcm_setng=ooh.init_cd_plcm_setng
					and fpl.match_code=ooh.match_init_cd_plcm_setng
			join ##lpl lpl on lpl.cd_plcm_setng=ooh.long_cd_plcm_setng
					and lpl.match_code=ooh.match_long_cd_plcm_setng
			join ##cnty cnty on cnty.cd_cnty=ooh.county_cd
					and cnty.match_code=ooh.match_county_cd
					and ooh.match_county_cd not in (40,999)
			where ooh.fl_in_tbl_child_episodes = 1
	   
	
			create index idx_int_match_param_key_demog_fields on ##prmlocdem(
				int_match_param_key
				,age_grouping_cd
				,pk_gndr
				,cd_race_census
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
						   ,[min_start_date]
						   ,[max_start_date]
						   ,[cnt_qry]
						   ,[last_run_date])
					 select 
							isnull((select max(qry_id)+1 from prtl.cache_poc1ab_params),1)
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
					   ,custody_id
					   ,[age_grouping_cd]
					   ,[cd_race]
					   ,[pk_gndr]
					   ,[init_cd_plcm_setng]
					   ,[long_cd_plcm_setng]
					   ,[county_cd]
					   ,[cnt_start_date]
					   ,[cnt_entries]
					   ,[cnt_exits]
					   ,[min_start_date]
					   ,[max_start_date]
					   ,[x1]
					   ,[x2]
					   ,[insert_date]
					   ,int_all_param_key)

				SELECT    prtl_poc1ab.qry_type
						, prtl_poc1ab.date_type 
						, prtl_poc1ab.[start_date]
						, mtch.int_param_key
						, prtl_poc1ab.bin_dep_cd
						, los.bin_los_cd
						, plc.bin_placement_cd
						, ihs.bin_ihs_svc_cd
						, rpt.cd_reporter_type
						, acc.cd_access_type
						, alg.cd_allegation
						, fnd.cd_finding
						, srv.cd_subctgry_poc_frc
						, bud.cd_budget_poc_frc
						, prtl_poc1ab.custody_id
						, mtch.age_grouping_cd 
						, mtch.cd_race_census
						, mtch.pk_gndr
						, mtch.init_cd_plcm_setng
						, mtch.long_cd_plcm_setng
						, mtch.county_cd
						, isnull(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
						, isnull(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
						, isnull(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
						--, '2000-01-01' as minmonthstart
						--, '2013-07-01' as maxmonthstart
						--, null as x1
						--, null   as x2
						, @minmonthstart as minmonthstart
						, @maxmonthstart as maxmonthstart
						, @x1 as x1
						, @x2   as x2
						, getdate() as insert_date
						, cast(cast(int_param_key as char(9))

						--+ cast(bin_dep_cd  as char(1))
						+ cast(los.bin_los_cd as char(1))
						+ cast(plc.bin_placement_cd as char(1))
						+ cast(ihs.bin_ihs_svc_cd as char(1))
						+ case when rpt.cd_reporter_type between 0 and 9 then '0' + cast(rpt.cd_reporter_type as char(1)) else cast(rpt.cd_reporter_type as char(2)) end
						+  cast(acc.cd_access_type as char(1))
						+ cast(alg.cd_allegation as char(1))
						+ cast(fnd.cd_finding as char(1))
						+ case when srv.cd_subctgry_poc_frc between 0 and 9 then '0' + cast(srv.cd_subctgry_poc_frc as char(1)) else cast(srv.cd_subctgry_poc_frc as char(2)) end
						+ case when bud.cd_budget_poc_frc between 0 and 9 then '0' + cast(bud.cd_budget_poc_frc as char(1)) else cast(bud.cd_budget_poc_frc as char(2)) end as decimal(21,0))

				   FROM prtl.prtl_poc1ab  
						join ##prmlocdem mtch on mtch.int_match_param_key=prtl_poc1ab.int_match_param_key 
						--join dbo.ref_lookup_gender gdr on mtch.pk_gndr=gdr.pk_gndr
						--join dbo.ref_age_groupings_census age on age.age_grouping_cd=mtch.age_grouping_cd
						join (select distinct cd_race from ##eth ) rc on rc.cd_race=mtch.cd_race_census 
						--join dbo.ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=rc.cd_race 
						--join dbo.ref_lookup_plcmnt fpl on fpl.cd_plcm_setng=mtch.init_cd_plcm_setng
						--join dbo.ref_lookup_plcmnt lpl on lpl.cd_plcm_setng = mtch.long_cd_plcm_setng
						--join dbo.ref_lookup_county cnty on cnty.county_cd=mtch.county_cd
						join ##los los on prtl_poc1ab.max_bin_los_cd >=los.match_code
						--join ref_filter_los ref_los on ref_los.bin_los_cd=los.bin_los_cd
						join ##nbrplc plc on plc.match_code=prtl_poc1ab.bin_placement_cd
						--join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=plc.bin_placement_cd
						join ##ihs ihs on ihs.match_code=prtl_poc1ab.bin_ihs_svc_cd
						--join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
						join ##rpt rpt on rpt.match_code=prtl_poc1ab.cd_reporter_type
						-- join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=rpt.cd_reporter_type
						join ##access_type acc on acc.match_code=prtl_poc1ab.fl_cps_invs
						--join ref_filter_access_type ref_acc on ref_acc.cd_access_type=cps.cd_access_type
						join ##algtn alg on alg.match_code=prtl_poc1ab.filter_allegation
						--join dbo.ref_filter_allegation ref_alg on ref_alg.cd_allegation=alg.cd_allegation
						join ##find fnd on fnd.match_code=prtl_poc1ab.filter_finding
						--join dbo.ref_filter_finding ref_fnd on ref_fnd.cd_finding=fnd.cd_finding
						join ##srvc srv on srv.match_code=prtl_poc1ab.filter_service_category
						--  join dbo.ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
						join ##budg bud on bud.match_code=prtl_poc1ab.filter_service_budget
						--join dbo.ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=bud.cd_budget_poc_frc
						--  join ref_filter_dependency dep on dep.bin_dep_cd=prtl_poc1ab.bin_dep_cd
					--left join prtl.cache_poc1ab_aggr che 
					--on che.int_param_key=mtch.int_param_key
					--	and che.bin_dep_cd in (0,1,2,3)
					--	and che.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
					--	and che.bin_los_cd=los.bin_los_cd
					--	and che.bin_placement_cd=plc.bin_placement_cd
					--	and che.cd_reporter_type=rpt.cd_reporter_type
					--	and che.cd_allegation=alg.cd_allegation
					--	and che.cd_finding=fnd.cd_finding
					--	and che.cd_access_type=acc.cd_access_type
					--	and che.cd_budget_poc_frc=bud.cd_budget_poc_frc
					--	and che.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc
					where prtl_poc1ab.[start_date] >='2000-01-01' --@minmonthstart
						and NOT EXISTS(select 1 
										from prtl.cache_poc1ab_aggr che
										where che.int_param_key = mtch.int_param_key
											and che.bin_ihs_svc_cd=ihs.bin_ihs_svc_cd
											and che.bin_los_cd=los.bin_los_cd
											and che.bin_placement_cd=plc.bin_placement_cd
											and che.cd_reporter_type=rpt.cd_reporter_type
											and che.cd_allegation=alg.cd_allegation
											and che.cd_finding=fnd.cd_finding
											and che.cd_access_type=acc.cd_access_type
											and che.cd_budget_poc_frc=bud.cd_budget_poc_frc
											and che.cd_subctgry_poc_frc=srv.cd_subctgry_poc_frc)
					group by  prtl_poc1ab.qry_type
							,prtl_poc1ab.date_type 
							,prtl_poc1ab.[start_date]
							,prtl_poc1ab.custody_id
							,mtch.int_param_key
							,mtch.age_grouping_cd 
							,mtch.pk_gndr
							,mtch.cd_race_census
							,mtch.init_cd_plcm_setng
							,mtch.long_cd_plcm_setng
							,mtch.county_cd
							, bin_dep_cd
							, los.bin_los_cd
							, plc.bin_placement_cd
							, ihs.bin_ihs_svc_cd
							, rpt.cd_reporter_type
							, acc.cd_access_type
							, alg.cd_allegation
							, fnd.cd_finding
							, srv.cd_subctgry_poc_frc
							, bud.cd_budget_poc_frc 
						--	,cast(cast(int_param_key as char(9))

						----+ cast(bin_dep_cd  as char(1))
						--+ cast(los.bin_los_cd as char(1))
						--+ cast(plc.bin_placement_cd as char(1))
						--+ cast(ihs.bin_ihs_svc_cd as char(1))
						--+ case when rpt.cd_reporter_type between 0 and 9 then '0' + cast(rpt.cd_reporter_type as char(1)) else cast(rpt.cd_reporter_type as char(2)) end
						--+  cast(acc.cd_access_type as char(1))
						--+ cast(alg.cd_allegation as char(1))
						--+ cast(fnd.cd_finding as char(1))
						--+ case when srv.cd_subctgry_poc_frc between 0 and 9 then '0' + cast(srv.cd_subctgry_poc_frc as char(1)) else cast(srv.cd_subctgry_poc_frc as char(2)) end
						--+ case when bud.cd_budget_poc_frc between 0 and 9 then '0' + cast(bud.cd_budget_poc_frc as char(1)) else cast(bud.cd_budget_poc_frc as char(2)) end as decimal(21,0))
	
		update statistics prtl.cache_poc1ab_aggr
		
		
			--order by prtl_poc1ab.qry_type,prtl_poc1ab.date_type,prtl_poc1ab.start_date
	end -- if @qry_id is null
	else 
		 If @qry_id is not null
			begin
				update prtl.cache_poc1ab_params
				set cnt_qry=cnt_qry + 1,last_run_date=getdate()
				where @qry_id=qry_id
			end

--select * from prtl.cache_poc1ab_aggr order by date_type,start_date,bin_dep_cd desc,qry_type asc


	--SELECT  distinct
	--		poc1ab.qry_type as   "qry_type_poc1"
	--		, poc1ab.date_type
	--		, poc1ab.start_date  as "Month"
	--		, poc1ab.age_grouping_cd as  "Age_Grouping_Cd"
	--		, ref_age.age_grouping as "Age Grouping"
	--		, poc1ab.pk_gndr  as "Gender_Cd"
	--		, ref_gdr.tx_gndr as "Gender" 
	--		, poc1ab.cd_race  as "Ethnicity_Cd"
	--		, ref_eth.tx_race_census as "Race/Ethnicity" 
	--		, poc1ab.init_cd_plcm_setng as "InitPlacementCd"
	--		, ref_fpl.cd_plcm_setng as  "First Placement Setting"
	--		, poc1ab.long_cd_plcm_setng as "LongPlacementCd"
	--		, ref_lpl.cd_plcm_setng as "Longest Placement Setting" 
	--		, poc1ab.county_cd as "Removal_County_Cd"
	--		, ref_cnty.county_desc as "County"
	--		, poc1ab.bin_dep_cd as [Dependency Cd]
	--		, ref_dep.bin_dep_desc as [Dependency]
	--		, poc1ab.bin_los_cd 
	--		, ref_los.bin_los_desc as [Length of Service Desc]
	--		, poc1ab.bin_placement_cd
	--		, ref_plc.bin_placement_desc as [Placement Count Desc]
	--		, poc1ab.bin_ihs_svc_cd
	--		, ref_ihs.bin_ihs_svc_tx as [In-Home Service Desc]
	--		, poc1ab.cd_reporter_type
	--		, ref_rpt.tx_reporter_type as [Reporter Desc]
	--		, poc1ab.cd_access_type
	--		, ref_acc.tx_access_type as [Access type desc]
	--		, poc1ab.cd_allegation
	--		, ref_alg.tx_allegation as [Allegation]
	--		, poc1ab.cd_finding
	--		, ref_fnd.tx_finding as [Finding]
	--		, poc1ab.cd_subctgry_poc_frc as [Service Type Cd]
	--		, ref_srv.tx_subctgry_poc_frc as [Service Type]
	--		, poc1ab.cd_budget_poc_frc as [Budget Cd]
	--		, ref_bud.tx_budget_poc_frc as [Budget]
	--		, case when (cnt_start_date) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_start_date) 
 --               end  as   "Total In Care First Day"
	--		, case when (cnt_entries) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_entries) 
 --               end as "Number of Entries"
	--		,  case when ( --  first day + entered care < exited care
 --               (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_start_date) 
 --               end)
 --               +
 --               (case when (cnt_entries) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_entries) 
 --               end)) >= -- exited care
 --                   (case when (cnt_exits) > 0 /* jitter all above 0 */ 
 --                       then 
 --                           case when (round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                           then 1
 --                           else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                           end
 --                       else cnt_exits
 --                   end)
                    
 --               then -- use exits as they are
 --               (case when (cnt_exits) > 0 /* jitter all above 0 */ 
 --                       then 
 --                           case when (round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                           then 1
 --                           else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                           end
 --                       else cnt_exits
 --                   end)
 --               else -- use first day plus entered
 --               (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_start_date) 
 --               end)
 --               +
 --               (case when (cnt_entries) > 0 /* jitter all above 0 */ 
 --                   then 
 --                       case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
 --                       then 1
 --                       else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
 --                       end
 --                   else (cnt_entries) 
 --               end)
 --           end as "Number of Exits"
	--FROM prtl.cache_poc1ab_aggr poc1ab  
	--join ##prmlocdem mtch on mtch.int_param_key=poc1ab.int_param_key 
	--join dbo.ref_age_groupings_census ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
	--join dbo.ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc1ab.cd_race
	--join dbo.ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc1ab.pk_gndr
	--join dbo.ref_lookup_plcmnt ref_fpl on ref_fpl.cd_plcm_setng=poc1ab.init_cd_plcm_setng
	--join dbo.ref_lookup_plcmnt ref_lpl on ref_lpl.cd_plcm_setng=poc1ab.long_cd_plcm_setng
	--join dbo.ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
	--join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
	--join ##los los on los.bin_los_cd=poc1ab.bin_los_cd
	--join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
	--join ##nbrplc plc on plc.bin_placement_cd=poc1ab.bin_placement_cd
	--join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=poc1ab.bin_placement_cd
	--join ##ihs ihs on ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
	--join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
	----join ##rpt rpt on rpt.cd_reporter_type=poc1ab.cd_reporter_type
	--join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
	----join ##access_type acc on acc.cd_access_type=poc1ab.cd_access_type
	--join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
	----join ##algtn alg on alg.cd_allegation=poc1ab.cd_allegation
	--join dbo.ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
	----join ##find fnd on fnd.cd_finding=poc1ab.cd_finding
	--join dbo.ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
	----join ##srvc srv on srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
	--join dbo.ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
	----join ##budg bud on bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
	--join dbo.ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
	----join ref_lookup_custody ref_cust on ref_cust.custody_id=poc1ab.custody_id
	--where poc1ab.[start_date] between '2000-01-01' and '2013-07-31'
	--	and poc1ab.cd_reporter_type in (select cd_reporter_type from ##rpt)
	--	and poc1ab.cd_access_type in (select cd_access_type from ##access_type)
	--	and poc1ab.cd_allegation in (select cd_allegation from ##algtn)
	--	and poc1ab.cd_finding in (select cd_finding from ##find)
	--	and poc1ab.cd_subctgry_poc_frc in (select cd_subctgry_poc_frc from ##srvc)
	--	and poc1ab.cd_budget_poc_frc in (select cd_budget_poc_frc from ##budg)


	
			

	
			

			






 
 
