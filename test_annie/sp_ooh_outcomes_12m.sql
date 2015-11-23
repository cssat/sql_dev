-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ooh_outcomes_12m`( p_age_grouping_cd varchar(30)
,  p_ethnicity_cd varchar(30)
,  p_gender_cd varchar(10)
,  p_init_cd_plcm_setng varchar(30)
,  p_long_cd_plcm_setng varchar(30) 
,  p_county_cd varchar(200) 
,  p_bin_los_cd varchar(30) 
,  p_bin_placement_cd varchar(30) 
,  p_bin_ihs_svc_cd varchar(30) 
,  p_cd_reporter_type varchar(100) 
,  p_filter_access_type varchar(30) 
,  p_filter_allegation  varchar(30)
, p_filter_finding varchar(30)
-- , p_filter_service_category  varchar(100)
-- , p_filter_service_budget varchar(100)
, p_bin_dep_cd varchar(20)
 )
begin

declare flg_procedure_off int;
declare p_filter_service_category varchar(100);
declare p_filter_service_budget varchar(100);

declare p_qry_id bigint;
declare p_mindate datetime;
declare p_maxdate datetime;
declare p_minmonthstart datetime;
declare p_maxmonthstart datetime;
declare var_calling_procedure int;


declare var_row_cnt_param int;
declare var_row_cnt_cache int;

declare min_filter_date datetime;

declare unq_qry_id int;
declare var_cutoff_date datetime;

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;


set var_calling_procedure=23;
set p_filter_service_category='0', p_filter_service_budget='0';

select max(a.db_min_filter_date) into min_filter_date
from (
	select max(d.min_filter_date) as 'db_min_filter_date'
	from ref_filter_dependency d
	where find_in_set(d.bin_dep_cd,p_bin_dep_cd)>0

	union

	select max(a.min_filter_date) as 'db_min_filter_date'
	from ref_filter_allegation a
	where find_in_set(a.cd_allegation,p_filter_allegation)>0

	union

	select max(f.min_filter_date) as 'db_min_filter_date'
	from ref_filter_finding f
	where find_in_set(f.cd_finding,p_filter_finding)>0

	union

    select max(e.min_filter_date) as 'db_min_filter_date'
    from ref_filter_access_type e
    where find_in_set(e.cd_access_type,p_filter_access_type)
    
    union

	select cast('2000-01-01' as datetime) as 'db_min_filter_date'
) as a;


/***  turn procedure on / off for loading data ***************************************/
set flg_procedure_off =0;

if  flg_procedure_off =0 then    
  
-- initialize variables  
    call sp_ooh_assign_desc (var_calling_procedure);

	select 
		min_date_any, max_date_any, min_date_any, max_date_any
	into p_minmonthstart , p_maxmonthstart , p_mindate , p_maxdate FROM
		ref_lookup_max_date
	where
		id = var_calling_procedure;

    
    
   
    set p_qry_id=(
            select qry_id 
            from cache_outcomes_params
            where age_grouping_cd=left(p_age_grouping_cd,20)
                and cd_race_census=left(p_ethnicity_cd,30) 
                and pk_gndr=left(p_gender_cd,10) 
                and init_cd_plcm_setng=left(p_init_cd_plcm_setng,50) 
                and long_cd_plcm_setng=left(p_long_cd_plcm_setng,50) 
                and county_cd=	left(p_County_Cd,200)   
                and bin_dep_cd=left(p_bin_dep_cd,20)
                and bin_los_cd=left(p_bin_los_cd,30)
                and bin_placement_cd=left(p_bin_placement_cd,30)
                and bin_ihs_svc_cd=left(p_bin_ihs_svc_cd,30)
                and cd_reporter_type=left(p_cd_reporter_type,100)
                and filter_access_type=left(p_filter_access_type,30)
                and filter_allegation=left(p_filter_allegation,30)
                and filter_finding=left(p_filter_finding,30)
                and filter_srvc_type=left(p_filter_service_category,50)
                and filter_budget=left(p_filter_service_budget,50)
           --     and min_start_date<=p_mindate
           --     and max_start_date >=p_maxdate
           order by qry_ID  limit 1);
           
    set @qry_ID:= coalesce(p_qry_id,(select (max(qry_ID) + 1)  from cache_outcomes_params),1);           
           
    if p_qry_id is null  then
            

            INSERT INTO cache_outcomes_params
                    (qry_id
                    , age_grouping_cd
                    ,cd_race_census
                    ,pk_gndr
                    ,init_cd_plcm_setng
                    ,long_cd_plcm_setng
                    ,county_cd
                    ,bin_los_cd
                    ,bin_placement_cd
                    ,bin_ihs_svc_cd
                    ,cd_reporter_type
                    ,filter_access_type
                    ,filter_allegation
                    ,filter_finding
                    ,filter_srvc_type
                    ,filter_budget
                    ,bin_dep_cd
                    ,min_start_date
                    ,max_start_date
                    ,cnt_qry
                    ,last_run_date)

            select 
                     @qry_ID
                    ,p_age_grouping_cd
                    ,p_ethnicity_cd
                    ,p_gender_cd
                    ,p_init_cd_plcm_setng
                    ,p_long_cd_plcm_setng
                    ,p_county_cd
                    ,p_bin_los_cd
                    ,p_bin_placement_cd
                    ,p_bin_ihs_svc_cd
                    ,p_cd_reporter_type
                    ,p_filter_access_type
                    ,p_filter_allegation
                    ,p_filter_finding
                    ,p_filter_service_category
                    ,p_filter_service_budget
                    ,p_bin_dep_cd
                    ,p_minmonthstart
                    ,p_maxmonthstart
                    ,1
                ,now();
     
  
        else --  p_qry_id is not null
            
            update cache_outcomes_params
            set cnt_qry=cnt_qry + 1,last_run_date=now()
            where qry_id=p_qry_id;
        
        end if;  -- p_qry_id is null
 
   
  call sp_ooh_create_cachekeys(p_age_grouping_cd 
        ,  p_ethnicity_cd 
        ,  p_gender_cd 
        ,  p_init_cd_plcm_setng 
        ,  p_long_cd_plcm_setng 
        ,  p_county_cd 
        ,  p_bin_los_cd 
        ,  p_bin_placement_cd 
        ,  p_bin_ihs_svc_cd 
        ,  p_cd_reporter_type 
        ,  p_filter_access_type 
        ,  p_filter_allegation  
        , p_filter_finding 
        , p_filter_service_category  
        , p_filter_service_budget
        , p_bin_dep_cd
        , var_calling_procedure
        , coalesce(p_qry_id,@qry_ID));



update cachekeys,
    cache_qry_param_outcomes 
set 
    cachekeys.in_cache = 1,
    cachekeys.qry_id = cache_qry_param_outcomes.qry_id
where
    cachekeys.int_hash_key = cache_qry_param_outcomes.int_hash_key;
        

  
select 
    sum(in_cache), count(*), count(distinct qry_id)
into var_row_cnt_cache , var_row_cnt_param , unq_qry_id from
    cachekeys;

                
                     
if  var_row_cnt_param <> var_row_cnt_cache then

        
        
        --  call load_ooh_parameters(p_date
        call sp_ooh_load_param_tbls(date_format(p_mindate,'%Y-%m-%d')
                ,  p_age_grouping_cd 
                ,  p_ethnicity_cd 
                ,  p_gender_cd 
                ,  p_init_cd_plcm_setng 
                ,  p_long_cd_plcm_setng 
                ,  p_county_cd 
                ,  p_bin_los_cd 
                ,  p_bin_placement_cd 
                ,  p_bin_ihs_svc_cd 
                ,  p_cd_reporter_type 
                ,  p_filter_access_type 
                ,  p_filter_allegation  
                , p_filter_finding 
                , p_filter_service_category  
                , p_filter_service_budget
                , p_bin_dep_cd
                , 0
                , 1
                , p_mindate
                , p_maxdate
                , var_calling_procedure);    
    
        call sp_ooh_assign_param_multiplier;
    
        drop temporary table if exists tot_episodes ; 
        
   
    set@incl='create temporary table tot_episodes engine=memory as 
        select  
            pocm.cohort_entry_date
            ,pocm.date_type
            ,pocm.qry_type';
        if trim(p_bin_dep_cd)='0' then
            set@incl=concat(@incl,', 0 as bin_dep_cd');
        else
            set@incl=concat(@incl,', dep.bin_dep_cd');
        end if;
	if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
		set@incl=concat(@incl,
			', mtch.int_param_key as int_param_key');
        else
			set@incl=concat(@incl,', ',@int_param_key,' as int_param_key');
        end if;
        if trim(p_bin_los_cd)='0' then
        set@incl=concat(@incl,', 0 as bin_los_cd');
        else
        set@incl=concat(@incl,', los.bin_los_cd');
        end if;
          if trim(p_bin_placement_cd)='0' then
        set@incl=concat(@incl,', 0 as bin_placement_cd');
        else
        set@incl=concat(@incl,', plc.bin_placement_cd');
        end if;   
        if trim(p_bin_ihs_svc_cd)='0' then
        set@incl=concat(@incl,', 0 as bin_ihs_svc_cd');
        else
        set@incl=concat(@incl,', ihs.bin_ihs_svc_cd');
        end if;
        if trim(p_cd_reporter_type)='0' then
        set@incl=concat(@incl,', 0 as cd_reporter_type');
        else
        set@incl=concat(@incl,', rpt.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)='0' then
        set@incl=concat(@incl,', 0 as cd_access_type');
        else
        set@incl=concat(@incl,', acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation)= '0' then
        set@incl=concat(@incl,', 0 as cd_allegation');
        else
        set@incl=concat(@incl,', alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding)='0' then
        set@incl=concat(@incl,', 0 as cd_finding');
        else
        set@incl=concat(@incl,', fnd.cd_finding');
        end if;	        
        if trim(p_filter_service_category) = '0'  then
        set@incl=concat(@incl,', 0 as cd_subctgry_poc_frc');
        else
        set@incl=concat(@incl,', srv.cd_subctgry_poc_frc');
        end if;	        
        if trim(p_filter_service_budget) ='0' then
        set@incl=concat(@incl,', 0 as cd_budget_poc_frc
						,cast(sum(cohort_count) * 1.0000 as decimal(9,4))  as tot_episodes');
        else
        set@incl=concat(@incl,', bud.cd_budget_poc_frc 
						,cast(sum(cohort_count) * 1.0000 as decimal(9,4))  as tot_episodes
						');
        end if;	
		set@incl=concat(@incl,',che.int_hash_key
						,che.qry_id');
		set@incl=concat(@incl,char(13),'
		from prtl_outcomes pocm');
		if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set@incl=concat(@incl,char(13),
			'join tblprmlocdem mtch 
            on mtch.int_match_param_key=pocm.int_match_param_key 
            and mtch.cd_race_census in (select cd_race from tbleth)');
		end if;
		if trim(p_bin_dep_cd)<>'0' then
			set@incl=concat(@incl,char(13),'
			join tbldep dep on pocm.bin_dep_cd=dep.match_code');
    end if;		
    if trim(p_bin_los_cd)<>'0' then
			set@incl=concat(@incl,char(13),'
			join tbllos los on pocm.max_bin_los_cd=los.match_code');
    end if;
    if trim(p_bin_placement_cd)<>'0' then
		    set@incl=concat(@incl,char(13),'
			join tblnbrplc plc on plc.match_code=pocm.bin_placement_cd');
    end if;   
    if trim(p_bin_ihs_svc_cd)<>'0' then
	        set@incl=concat(@incl,char(13),'
			join tblihs ihs on ihs.match_code=pocm.bin_ihs_svc_cd');
    end if;
    if trim(p_cd_reporter_type)<>'0' then
	        set@incl=concat(@incl,char(13),'
			join tblrpt rpt on rpt.match_code=pocm.cd_reporter_type');
    end if;					
    if trim(p_filter_access_type)<>'0' then
	        set@incl=concat(@incl,char(13),'
			join tblacc acc on acc.match_code=pocm.filter_access_type');
    end if;					

    if trim(p_filter_allegation) <> '0' then
	        set@incl=concat(@incl,char(13),'
			join tblalg alg on alg.match_code=pocm.filter_allegation');
    end if;	       
    if trim(p_filter_finding) <> '0' then
	        set@incl=concat(@incl,char(13),'
			join tblfnd fnd on fnd.match_code=pocm.filter_finding');
    end if;	        
    if trim(p_filter_service_category) <> '0' then
	        set@incl=concat(@incl,char(13),'
			join tblsrvc srv on srv.match_code=pocm.filter_service_type');
    end if;	        
    if trim(p_filter_service_budget) <> '0' then
	        set@incl=concat(@incl,char(13),'
			join tblbudg bud on bud.match_code=pocm.filter_budget_type 
			');
    end if;	
		set@incl=concat(@incl,char(13),'
				join cachekeys che on che.int_hash_key=');
    	if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set@incl=concat(@incl,'
            cast((cast(mtch.int_param_key as decimal(22,0)) *  cast(',@mult_int_param_key,' as decimal(22,0))) as decimal(22,0))');
		else
			set@incl=concat(@incl,'
            cast((cast(',@int_param_key,' as decimal(22,0))  *  cast(',@mult_int_param_key,' as decimal(22,0))) as decimal(22,0))');
		end if;
		if trim(p_bin_dep_cd)<>'0' then
			set@incl=concat(@incl,' 
            + cast((dep.bin_dep_cd * ',@mult_bin_dep_cd,' )as decimal(22,0)) ');
        end if;	
    if trim(p_bin_los_cd)<>'0' then
			set@incl=concat(@incl,' 
            + cast((los.bin_los_cd * ',@mult_bin_los_cd,' )as decimal(22,0)) ');
        end if;
        if trim(p_bin_placement_cd)<>'0' then
		    set@incl=concat(@incl,' 
            + cast((plc.bin_placement_cd * ',@mult_bin_placement_cd,' )as decimal(22,0))');
        end if;   
        if trim(p_bin_ihs_svc_cd)<>'0' then
	        set@incl=concat(@incl,' 
            + cast( (ihs.bin_ihs_svc_cd * ',@mult_bin_ihs_svc_cd,' ) as decimal(22,0))');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set@incl=concat(@incl,'
            + cast((rpt.cd_reporter_type * ',@mult_cd_reporter_type,' ) as decimal(22,0)) ');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set@incl=concat(@incl,' 
            + cast((acc.cd_access_type * ',@mult_cd_access_type,') as decimal(22,0))');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set@incl=concat(@incl,' 
            + cast( (alg.cd_allegation * ',@mult_cd_allegation,') as decimal(22,0))');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set@incl=concat(@incl,'
            + cast( (fnd.cd_finding * ',@mult_cd_finding,') as decimal(22,0))');
        end if;	        
        if trim(p_filter_service_category) <> '0' then
	        set@incl=concat(@incl,'
            + cast((srv.cd_subctgry_poc_frc * ',@mult_cd_subctgry_poc_frc,') as decimal(22,0))');
        end if;	        
        if trim(p_filter_service_budget) <> '0' then
	        set@incl=concat(@incl,'
            +  bud.cd_budget_poc_frc * ' ,  @mult_cd_budget_poc_frc);
        end if;	
	
		set@incl=concat(@incl,char(13),'and che.in_cache=0
		group by  pocm.cohort_entry_date
            , pocm.date_type
            , pocm.qry_type');
    if trim(p_bin_dep_cd) <> '0' then
            set@incl=concat(@incl,'
            , dep.bin_dep_cd');
    end if;            
		if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set@incl=concat(@incl,'
            , mtch.int_param_key');
		end if;
		if trim(p_bin_los_cd)<>'0' then
			set@incl=concat(@incl,'
            , los.bin_los_cd');
        end if;
        if trim(p_bin_placement_cd)<>'0' then
		    set@incl=concat(@incl,'
            , plc.bin_placement_cd');
        end if;   
        if trim(p_bin_ihs_svc_cd)<>'0' then
	        set@incl=concat(@incl,'
            , ihs.bin_ihs_svc_cd');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set@incl=concat(@incl,'
            , rpt.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set@incl=concat(@incl,'
            , acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set@incl=concat(@incl,'
            , alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set@incl=concat(@incl,'
            , fnd.cd_finding');
        end if;	        
        if trim(p_filter_service_category) <> '0' then
	        set@incl=concat(@incl,'
            , srv.cd_subctgry_poc_frc');
        end if;	        
        if trim(p_filter_service_budget) <> '0' then
	        set@incl=concat(@incl,'
            , bud.cd_budget_poc_frc ');
        end if;	
        set@incl=concat(@incl,',che.int_hash_key,che.qry_id;',char(13));
            
         
         drop temporary table if exists mycode_tot;
        create temporary table mycode_tot as select@incl;
        PREPARE stmt FROM@incl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
		set @incl='';
  
    alter table tot_episodes 
	add primary key (int_hash_key,cohort_entry_date,qry_type,date_type);
    
    set @incl='insert IGNORE into cache_outcomes_aggr( qry_type
                ,date_type
                ,cohort_entry_date
                 ,cd_discharge_type
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
                ,age_grouping_cd
                ,cd_race
                ,pk_gndr
                ,init_cd_plcm_setng
                ,long_cd_plcm_setng
                ,county_cd
                ,mnth
                ,rate
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year
                ,int_hash_key)   
        SELECT    outcomes.qry_type
                , outcomes.date_type 
                , outcomes.cohort_entry_date
                , outcomes.cd_discharge_type';
  if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
                set @incl=concat(@incl,'
                ,mtch.int_param_key ');
       else
            set @incl=concat(@incl,'
                , ',@int_param_key,' as int_param_key');
    end if;
     if trim(p_bin_dep_cd)='0' then
        set @incl=concat(@incl,', 0 as bin_dep_cd');
        else
        set @incl=concat(@incl,', dep.bin_dep_cd');
        end if;
        if trim(p_bin_los_cd)='0' then
        set @incl=concat(@incl,', 0 as bin_los_cd');
        else
        set @incl=concat(@incl,', los.bin_los_cd');
        end if;
          if trim(p_bin_placement_cd)='0' then
        set @incl=concat(@incl,', 0 as bin_placement_cd');
        else
        set @incl=concat(@incl,', plc.bin_placement_cd');
        end if;   
        if trim(p_bin_ihs_svc_cd)='0' then
        set @incl=concat(@incl,', 0 as bin_ihs_svc_cd');
        else
        set @incl=concat(@incl,', ihs.bin_ihs_svc_cd');
        end if;
        if trim(p_cd_reporter_type)='0' then
        set @incl=concat(@incl,', 0 as cd_reporter_type');
        else
        set @incl=concat(@incl,', rpt.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)='0' then
        set @incl=concat(@incl,', 0 as cd_access_type');
        else
        set @incl=concat(@incl,', acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation)= '0' then
        set @incl=concat(@incl,', 0 as cd_allegation');
        else
        set @incl=concat(@incl,', alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding)='0' then
        set @incl=concat(@incl,', 0 as cd_finding');
        else
        set @incl=concat(@incl,', fnd.cd_finding');
        end if;	        
        if trim(p_filter_service_category) = '0'  then
        set @incl=concat(@incl,', 0 as cd_subctgry_poc_frc');
        else
        set @incl=concat(@incl,', srv.cd_subctgry_poc_frc');
        end if;	        
        if trim(p_filter_service_budget) ='0' then
        set @incl=concat(@incl,', 0 as cd_budget_poc_frc');
        else
        set @incl=concat(@incl,', bud.cd_budget_poc_frc');
        end if;	
    if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
        set @incl=concat(@incl,' 
        , mtch.age_grouping_cd 
        , mtch.cd_race_census
        , mtch.pk_gndr
        , mtch.init_cd_plcm_setng
        , mtch.long_cd_plcm_setng
        , mtch.county_cd');
    else
        set @incl=concat(@incl,' 
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0');
    end if;
    set @incl=concat(@incl,'
        , outcomes.mnth
        , (sum(outcomes.discharge_count)/tot_episodes.tot_episodes) * 100');
    set @incl=concat(@incl,char(13),', DATE',char(39), p_minmonthstart,char(39));
    set @incl=concat(@incl,char(13),', DATE',char(39), p_maxmonthstart,char(39));
    set @incl=concat(@incl,char(13),', ',char(39), rand(),char(39));
    set @incl=concat(@incl,char(13),', ',char(39), rand(),char(39));    
    set @incl=concat(@incl,char(13),', DATE',char(39), now() ,char(39),' as insert_date'); 
     set @incl=concat(@incl,char(13),'   
		,tot_episodes.qry_id
        ,year(outcomes.cohort_entry_date)
        , tot_episodes.int_hash_key

    FROM prtl_outcomes outcomes');
		if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set @incl=concat(@incl,char(13),
			'join tblprmlocdem mtch 
            on mtch.int_match_param_key=outcomes.int_match_param_key 
            and mtch.cd_race_census in (select cd_race from tbleth)');
		end if;
    if trim(p_bin_dep_cd)<>'0' then
			set@incl=concat(@incl,char(13),'
			join tbldep dep on outcomes.bin_dep_cd=dep.match_code');
    end if;		
    if trim(p_bin_los_cd)<>'0' then
			set @incl=concat(@incl,char(13),'
			join tbllos los on outcomes.max_bin_los_cd=los.match_code');
        end if;
        if trim(p_bin_placement_cd)<>'0' then
		    set @incl=concat(@incl,char(13),'
			join tblnbrplc plc on plc.match_code=outcomes.bin_placement_cd');
        end if;   
        if trim(p_bin_ihs_svc_cd)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblihs ihs on ihs.match_code=outcomes.bin_ihs_svc_cd');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblrpt rpt on rpt.match_code=outcomes.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblacc acc on acc.match_code=outcomes.filter_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblalg alg on alg.match_code=outcomes.filter_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblfnd fnd on fnd.match_code=outcomes.filter_finding');
        end if;	        
        if trim(p_filter_service_category) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblsrvc srv on srv.match_code=outcomes.filter_service_type');
        end if;	        
        if trim(p_filter_service_budget) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblbudg bud on bud.match_code=outcomes.filter_budget_type ');
        end if;	
      set @incl=concat(@incl,char(13),'
     join tot_episodes  
        on tot_episodes.int_hash_key=');
    	if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set @incl=concat(@incl,'
            cast((cast(mtch.int_param_key as decimal(22,0)) *  cast(',@mult_int_param_key,' as decimal(22,0))) as decimal(22,0))');
		else
			set @incl=concat(@incl,'
            cast((cast(',@int_param_key,' as decimal(22,0))  *  cast(',@mult_int_param_key,' as decimal(22,0))) as decimal(22,0))');
		end if;
		if trim(p_bin_dep_cd)<>'0' then
			set @incl=concat(@incl,' 
            + cast((dep.bin_dep_cd * ',@mult_bin_dep_cd,' )as decimal(22,0)) ');
        end if;	
    if trim(p_bin_los_cd)<>'0' then
			set @incl=concat(@incl,' 
            + cast((los.bin_los_cd * ',@mult_bin_los_cd,' )as decimal(22,0)) ');
        end if;
        if trim(p_bin_placement_cd)<>'0' then
		    set @incl=concat(@incl,' 
            + cast((plc.bin_placement_cd * ',@mult_bin_placement_cd,' )as decimal(22,0))');
        end if;   
        if trim(p_bin_ihs_svc_cd)<>'0' then
	        set @incl=concat(@incl,' 
            + cast( (ihs.bin_ihs_svc_cd * ',@mult_bin_ihs_svc_cd,' ) as decimal(22,0))');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,'
            + cast((rpt.cd_reporter_type * ',@mult_cd_reporter_type,' ) as decimal(22,0)) ');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,' 
            + cast((acc.cd_access_type * ',@mult_cd_access_type,') as decimal(22,0))');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,' 
            + cast( (alg.cd_allegation * ',@mult_cd_allegation,') as decimal(22,0))');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,'
            + cast( (fnd.cd_finding * ',@mult_cd_finding,') as decimal(22,0))');
        end if;	        
        if trim(p_filter_service_category) <> '0' then
	        set @incl=concat(@incl,'
            + cast((srv.cd_subctgry_poc_frc * ',@mult_cd_subctgry_poc_frc,') as decimal(22,0))');
        end if;	        
        if trim(p_filter_service_budget) <> '0' then
	        set @incl=concat(@incl,'
            +  bud.cd_budget_poc_frc * ' ,  @mult_cd_budget_poc_frc);
        end if;	
		set @incl=concat(@incl,'
        and tot_episodes.cohort_entry_date=outcomes.cohort_entry_date
        and tot_episodes.qry_type=outcomes.qry_type
        and tot_episodes.date_type=outcomes.date_type',char(10));
-- 		set @incl=concat(@incl,'where exists(select * from cachekeys che
	-- 		where che.in_cache=0 and che.int_hash_key=tot_episodes.int_hash_key)',char(13));

		set @incl=concat(@incl,char(10),'
        group by  outcomes.qry_type
									,outcomes.date_type 
									,outcomes.cohort_entry_date
									,outcomes.cd_discharge_type
									,year(outcomes.cohort_entry_date)
                  ,outcomes.mnth');
     	if NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
			set @incl=concat(@incl,'
				,mtch.int_param_key
        ,mtch.age_grouping_cd 
        ,mtch.pk_gndr
        ,mtch.cd_race_census
        ,mtch.init_cd_plcm_setng
        ,mtch.long_cd_plcm_setng
        ,mtch.county_cd');
		end if;
		if trim(p_bin_dep_cd)<>'0' then
			set @incl=concat(@incl,'
				,dep.bin_dep_cd');
        end if;
		if trim(p_bin_los_cd)<>'0' then
			set @incl=concat(@incl,'
				,los.bin_los_cd');
        end if;
        if trim(p_bin_placement_cd)<>'0' then
		    set @incl=concat(@incl,'
			, plc.bin_placement_cd');
        end if;   
        if trim(p_bin_ihs_svc_cd)<>'0' then
	        set @incl=concat(@incl,'
			, ihs.bin_ihs_svc_cd');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,'
			, rpt.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,'
			, acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,'
			, alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,'
			, fnd.cd_finding');
        end if;	        
        if trim(p_filter_service_category) <> '0' then
	        set @incl=concat(@incl,'
			, srv.cd_subctgry_poc_frc');
        end if;	        
        if trim(p_filter_service_budget) <> '0' then
	        set @incl=concat(@incl,'
			, bud.cd_budget_poc_frc ');
        end if;	
       set @incl=concat(@incl,' 
        , tot_episodes.tot_episodes',char(13),'
        ,  tot_episodes.qry_id;');  
--   select @incl;


        drop temporary table if exists mycode_outcomes;
        create temporary table mycode_outcomes as select @incl;
        PREPARE stmt FROM @incl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        INSERT IGNORE INTO cache_qry_param_outcomes
								   (int_param_key
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
								   ,age_grouping_cd
								   ,cd_race
								   ,pk_gndr
								   ,init_cd_plcm_setng
								   ,long_cd_plcm_setng
								   ,county_cd
								   ,qry_id
								   ,int_hash_key)
						select ck.int_param_key
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
								   ,age_grouping_cd
								   ,cd_race_census
								   ,pk_gndr
								   ,init_cd_plcm_setng
								   ,long_cd_plcm_setng
								   ,county_cd
								   ,ck.qry_id
								   ,int_hash_key
						from cachekeys ck
						join (select distinct int_param_key,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd from tblprmlocdem)  q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;        
             
         
        end if;--  all rows not in cache
   
select 
    outcomes.cohort_entry_date as "Cohort Period",
    qry_type "qry_type_poc1_first_unique",
    outcomes.age_grouping_cd,
    case outcomes.age_grouping_cd
        when 0 then @age0
        when 1 then @age1
        when 2 then @age2
        when 3 then @age3
        when 4 then @age4
        when 5 then @age5
        when 6 then @age6
        when 7 then @age7
    end as "Age Grouping",
    outcomes.cd_race as ethnicity_cd,
    case outcomes.cd_race
        when 0 then @eth0
        when 1 then @eth1
        when 2 then @eth2
        when 3 then @eth3
        when 4 then @eth4
        when 5 then @eth5
        when 6 then @eth6
        when 7 then @eth7
        when 8 then @eth8
        when 9 then @eth9
        when 10 then @eth10
        when 11 then @eth11
        when 12 then @eth12
    end as "Race/Ethnicity",
    outcomes.pk_gndr as gender_cd,
    case outcomes.pk_gndr
        when 0 then @gdr0
        when 1 then @gdr1
        when 2 then @gdr2
        when 3 then @gdr3
    end as "Gender",
    outcomes.init_cd_plcm_setng,
    case
        when outcomes.init_cd_plcm_setng = 0 then @fpl0
        when outcomes.init_cd_plcm_setng = 3 then @fpl3
        when outcomes.init_cd_plcm_setng = 4 then @fpl4
        when outcomes.init_cd_plcm_setng = 5 then @fpl5
        when outcomes.init_cd_plcm_setng = 6 then @fpl6
        when outcomes.init_cd_plcm_setng = 7 then @fpl7
    end as "Initial Placement",
    outcomes.long_cd_plcm_setng,
    case
        when outcomes.long_cd_plcm_setng = 0 then @lpl0
        when outcomes.long_cd_plcm_setng = 3 then @lpl3
        when outcomes.long_cd_plcm_setng = 4 then @lpl4
        when outcomes.long_cd_plcm_setng = 5 then @lpl5
        when outcomes.long_cd_plcm_setng = 6 then @lpl6
        when outcomes.long_cd_plcm_setng = 7 then @lpl7
    end as "Longest Placement",
    outcomes.county_cd,
    ref_cnty.county as "County",
    outcomes.bin_dep_cd as "dependency_cd",
    ref_dep.bin_dep_desc as "Dependency",
    outcomes.bin_los_cd,
    ref_los.bin_los_desc as "Length of Service Desc",
    outcomes.bin_placement_cd,
    case outcomes.bin_placement_cd
        when 0 then @plc0
        when 1 then @plc1
        when 2 then @plc2
        when 3 then @plc3
        when 4 then @plc4
        when 5 then @plc5
    end as "Placement Count Desc",
    outcomes.bin_ihs_svc_cd,
    ihs.bin_ihs_svc_tx as "In-Home Service Desc",
    outcomes.cd_reporter_type,
    ref_rpt.tx_reporter_type as "Reporter Desc",
    outcomes.cd_access_type,
    ref_acc.tx_access_type as "Access type desc",
    outcomes.cd_allegation,
    case outcomes.cd_allegation
        when 0 then @alg0
        when 1 then @alg1
        when 2 then @alg2
        when 3 then @alg3
        when 4 then @alg4
    end as "Allegation",
    outcomes.cd_finding,
    case outcomes.cd_finding
        when 0 then @fnd0
        when 1 then @fnd1
        when 2 then @fnd2
        when 3 then @fnd3
        when 4 then @fnd4
    end as "Finding",
--    outcomes.cd_subctgry_poc_frc as "service_type_cd",
--    ref_srv.tx_subctgry_poc_frc as "Service Type",
--    outcomes.cd_budget_poc_frc "budget_cd",
--    ref_bud.tx_budget_poc_frc "Budget",
    outcomes.cd_discharge_type,
    toe.type_of_exit_desc as "Discharge",
    rate as "Percent"
from
    cache_outcomes_aggr outcomes
        join
    cachekeys ck ON ck.qry_id = outcomes.qry_id
			and ck.int_hash_key = outcomes.int_hash_key
        join
    ref_lookup_type_of_exit toe ON toe.type_of_exit = outcomes.cd_discharge_type
    join ref_last_dw_transfer on 1=1
    join
    vw_ref_dependency_lag ref_dep ON ref_dep.bin_dep_cd = outcomes.bin_dep_cd
        and ref_dep.date_type = outcomes.date_type
        and outcomes.cohort_entry_date between min_filter_date and ref_dep.cohort_max_filter_date
	join ref_filter_los ref_los ON ref_los.bin_los_cd = outcomes.bin_los_cd
			and if(outcomes.bin_los_cd!=0,date_add(date_add(date_add(date_add(outcomes.cohort_entry_date,
				INTERVAL 1 year),
				  INTERVAL 9 month),
					INTERVAL - 1 DAY),
						INTERVAL abs(ref_los.lag) DAY),cutoff_date) <= cutoff_date
        join
    ref_lookup_county ref_cnty ON ref_cnty.county_cd = outcomes.county_cd
join ref_filter_ihs_services ihs on ihs.bin_ihs_svc_cd=outcomes.bin_ihs_svc_cd and outcomes.cohort_entry_date>=min_display_date
        join
    ref_filter_reporter_type ref_rpt ON ref_rpt.cd_reporter_type = outcomes.cd_reporter_type
        join
    ref_filter_access_type ref_acc ON ref_acc.cd_access_type = outcomes.cd_access_type
--        join
--    ref_lookup_service_category ref_srv ON ref_srv.cd_subctgry_poc_frc = outcomes.cd_subctgry_poc_frc
-- 			and outcomes.cohort_entry_date>=min_service_date
--        join
--    ref_lookup_service_budget ref_bud ON ref_bud.cd_budget_poc_frc = outcomes.cd_budget_poc_frc
-- 			and outcomes.cohort_entry_date>=min_budget_date
where  outcomes.mnth=12
    and date_add(cohort_entry_date,
        INTERVAL (15 + outcomes.mnth) MONTH) <= cutoff_date
order by outcomes.cohort_entry_date asc , qry_type , age_grouping_cd asc , gender_cd asc , ethnicity_cd asc , init_cd_plcm_setng asc , long_cd_plcm_setng asc , county_cd asc , outcomes.bin_dep_cd asc , outcomes.bin_los_cd asc , outcomes.bin_placement_cd asc , outcomes.bin_ihs_svc_cd asc , outcomes.cd_reporter_type , outcomes.cd_access_type , outcomes.cd_allegation , outcomes.cd_finding , /*outcomes.cd_subctgry_poc_frc , outcomes.cd_budget_poc_frc , */outcomes.mnth asc , outcomes.cd_discharge_type asc;
end if;
end$$
DELIMITER ;
