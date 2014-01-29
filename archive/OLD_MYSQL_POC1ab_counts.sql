-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_poc1ab_counts`(  p_date  varchar(3000)
,  p_age_grouping_cd varchar(30)
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
, p_filter_service_category  varchar(100)
, p_filter_service_budget varchar(100)
 )
begin


    
declare flg_procedure_off int;
declare intFoundPos integer;

declare strElement varchar(3000);
declare strValues varchar(3000);
declare intVal integer;		
declare intincAll integer;


declare p_qry_id bigint;
declare p_mindate datetime;
declare p_maxdate datetime;
declare p_minmonthstart datetime;
declare p_maxmonthstart datetime;

declare var_qry_cnt int;
declare x1 float;
declare x2 float;
declare var_row_cnt_param int;
declare var_row_cnt_cache int;
DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;


set x1=rand();
set x2=rand();

/***  turn procedure on / off for loading data ***************************************/
set flg_procedure_off =0;

if  flg_procedure_off =0 then    
  
       DROP TEMPORARY TABLE IF EXISTS tbltmpValues;
        create temporary table tbltmpValues (strVal varchar(10));


        DROP TEMPORARY TABLE IF EXISTS tbldt;
        create temporary table tbldt(match_date datetime );
        alter table tbldt add primary key(match_date);
 
    
        --  dates
        set strValues=p_date;
        set 	intFoundPos =instr(strValues,','); 
        while intFoundPos <>0 do
                set strElement=SUBSTRING(strValues, 1, intFoundPos-1); 
                SET strValues = RIGHT(strValues,length(strValues)-intFoundPos);
            
                insert into tbltmpValues (strVal) values (strElement);
                set intFoundPos=instr(strValues,',');
        end while;

        if strValues <> ''  then
                INSERT Into tbltmpValues(strVal) values (strValues);
        end if;
        
        insert into tbldt (match_date)
        select distinct cast(strVal as datetime) from tbltmpValues;

    
     
     
     
--  set dates 
    
    select min_date_any ,max_date_all 
    into p_minmonthstart,p_maxmonthstart  
    FROM ref_lookup_max_date where id=19;
    select min(match_date),max(match_date) 
    into p_mindate,p_maxdate from tbldt;
  
    
    
    if NOT (trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )   then
    
    call load_poc1ab_parameters(p_date
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
        , 0
        , p_mindate
        , p_maxdate);
        
     set p_qry_id=(
            select qry_id 
            from cache_poc1ab_params
            where age_grouping_cd=left(p_age_grouping_cd,20)
                and cd_race_census=left(p_ethnicity_cd,30) 
                and pk_gndr=left(p_gender_cd,10) 
                and init_cd_plcm_setng=left(p_init_cd_plcm_setng,50) 
                and long_cd_plcm_setng=left(p_long_cd_plcm_setng,50) 
                and county_cd=	left(p_County_Cd,200)   
                and bin_los_cd=left(p_bin_los_cd,30)
                and bin_placement_cd=left(p_bin_placement_cd,30)
                and bin_ihs_svc_cd=left(p_bin_ihs_svc_cd,30)
                and cd_reporter_type=left(p_cd_reporter_type,100)
                and filter_access_type=left(p_filter_access_type,30)
                and filter_allegation=left(p_filter_allegation,30)
                and filter_finding=left(p_filter_finding,30)
                and filter_srvc_type=left(p_filter_service_category,50)
                and filter_budget=left(p_filter_service_budget,50)
                and min_start_date<=p_mindate
                and max_start_date >=p_maxdate
           order by qry_ID  limit 1);
  
  if p_qry_id is null then         
    select  qry.qry_id into p_qry_id
    from (
							select qry_ID,count(distinct param_pos) as match_cnt
							from (
								select qry_id,param_pos,count(distinct param_value) as cnt_val,q.cnt_sel
								from cache_qry_param_poc1ab
								join tblage age on age.age_grouping_cd=param_value and param_pos=1
								join (select count( age_grouping_cd) as cnt_sel 
                     from tblage2) q on 1=1
										group by qry_id,param_pos,q.cnt_sel
								having count(distinct param_value)  = cnt_sel 
								union
								select qry_id,param_pos
                        ,count(distinct param_value)as  cnt_val,q.cnt_sel
										from cache_qry_param_poc1ab
										join tbleth eth 
                    on eth.cd_race=param_value 
                    and param_pos=2
										join (select count( cd_race) as cnt_sel 
                    from tbleth2) q on 1=1
										group by qry_id,param_pos,q.cnt_sel
										having count(distinct param_value) = cnt_sel
								union
										select qry_id,param_pos
                    ,count(distinct param_value) as cnt_val,q.cnt_sel
										from cache_qry_param_poc1ab
										join tblgdr gdr on gdr.pk_gndr=param_value 
                    and param_pos=3
										join (select count( pk_gndr) as cnt_sel 
                         from tblgdr2) q on 1=1
										group by qry_id,param_pos,q.cnt_sel
										having count(distinct param_value) = cnt_sel
								union
											select qry_id,param_pos
                    ,count(distinct param_value)as  cnt_val,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblfpl fpl on 
                    fpl.cd_plcm_setng=param_value 
                    and param_pos=4
										join (select count( cd_plcm_setng) as cnt_sel 
                    from tblfpl2) q on 1=1
                    group by qry_id,param_pos,q.cnt_sel
                    having count(distinct param_value) = cnt_sel
								union
                    select qry_id,param_pos
                    ,count(distinct param_value)as  cnt_val
                    ,q.cnt_sel
										from cache_qry_param_poc1ab
										join tbllpl lpl on 
                        lpl.cd_plcm_setng=param_value 
                        and param_pos=5
                    join (select count( cd_plcm_setng) as cnt_sel 
                        from tbllpl2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union
											select qry_id,param_pos
                        ,count(distinct param_value) as cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblcnty cnty on cnty.cd_cnty=param_value 
                        and param_pos=6
											join (select count( cd_cnty) as cnt_sel 
                     from tblcnty2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union
											select qry_id,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tbllos los on los.bin_los_cd=param_value 
                        and param_pos=7
											join (select count( bin_los_cd) as cnt_sel 
                            from tbllos2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union 
											select qry_id,param_pos
                         ,count(distinct param_value) as  cnt_val
                         ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblnbrplc prm 
                            on prm.bin_placement_cd=param_value 
                            and param_pos=8
											join (select count( bin_placement_cd) as cnt_sel 
                            from tblnbrplc2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union
											select qry_id,param_pos
                          ,count(distinct param_value) as  cnt_val
                          ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblihs prm on prm.bin_ihs_svc_cd=param_value 
                            and param_pos=9
											join (select count( bin_ihs_svc_cd) as cnt_sel 
                        from tblihs2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union						
											select qry_id,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblrpt prm on prm.cd_reporter_type=param_value 
                                and param_pos=10
											join (select count( cd_reporter_type) as cnt_sel 
                        from tblrpt2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union
											select qry_id,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblacc prm on prm.cd_access_type=param_value 
                                and param_pos=11
											join (select count( cd_access_type) as cnt_sel 
                        from tblacc2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel
								union 
											select qry_id,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblalg prm 
                            on prm.cd_allegation=param_value 
                                and param_pos=12
											join (select count( cd_allegation) as cnt_sel 
                    from tblalg2) q on 1=1
                    group by qry_id,param_pos,q.cnt_sel
                    having count(distinct param_value) = cnt_sel	
								union
											select qry_id,param_pos
                            ,count(distinct param_value) as  cnt_val
                            ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblfnd prm 
                        on prm.cd_finding=param_value 
                        and param_pos=13
											join (select count( cd_finding) as cnt_sel 
                            from tblfnd2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel	
								union
											select qry_id
                        ,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblsrvc prm 
                        on prm.cd_subctgry_poc_frc=param_value 
                        and param_pos=14
											join (select count( cd_subctgry_poc_frc) as cnt_sel 
                        from tblsrvc2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel	
								union 
											select qry_id
                            ,param_pos
                        ,count(distinct param_value) as  cnt_val
                        ,q.cnt_sel
											from cache_qry_param_poc1ab
											join tblbudg prm 
                        on prm.cd_budget_poc_frc=param_value 
                        and param_pos=15
											join (select count( cd_budget_poc_frc) as cnt_sel 
                            from tblbudg2) q on 1=1
											group by qry_id,param_pos,q.cnt_sel
											having count(distinct param_value) = cnt_sel	) q
								group by qry_id
								
							) qry
						where qry.match_cnt=15 limit 1;
    
					-- qry_id is still null
    if p_qry_id is  null then
    
      start transaction;            
  
		INSERT INTO cache_poc1ab_params
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
  			,min_start_date
  			,max_start_date
  			,cnt_qry
  			,last_run_date)

    select 
         (select @qry_ID:=(max(qry_ID) + 1)  from cache_poc1ab_params)
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
  			,p_minmonthstart
  			,p_maxmonthstart
  			,1
        ,now();
  
        insert into cache_qry_param_poc1ab
        (qry_id,param_value,param_name,param_pos)
        select distinct @qry_id,age_grouping_cd,'age_grouping_cd',1 from tblage
        union 
        select distinct  @qry_id,cd_race,'cd_race',2 from tbleth
        union 
        select distinct @qry_id,pk_gndr,'pk_gndr',3 from tblgdr
        union
        select distinct @qry_id,cd_plcm_setng,'init_cd_plcm_setng',4 from tblfpl
        union
        select distinct @qry_id,cd_plcm_setng,'long_cd_plcm_setng',5 from tbllpl
        union
        select distinct @qry_id,cd_cnty,'county_cd',6 from tblcnty
        union
        select distinct @qry_id,bin_los_cd,'bin_los_cd',7 from tbllos
        union
        select distinct @qry_id,bin_placement_cd,'bin_placement_cd',8 from tblnbrplc
        union
        select distinct @qry_id,bin_ihs_svc_cd,'bin_ihs_svc_cd',9 from tblihs
        union
        select distinct @qry_id,cd_reporter_type,'cd_reporter_type',10 from tblrpt
        union
        select distinct @qry_id,cd_access_type,'cd_access_type',11 from tblacc
        union
        select distinct @qry_id,cd_allegation,'cd_allegation',12 from tblalg
        union
        select distinct @qry_id,cd_finding,'cd_finding',13 from tblfnd
        union
        select distinct @qry_id,cd_subctgry_poc_frc,'cd_subctgry_poc_frc',14 from tblsrvc
        union
        select distinct @qry_id,cd_budget_poc_frc,'cd_budget_poc_frc',15 from tblbudg;

 
 
    if   p_bin_los_cd='0' 
   					and trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
   					and trim(p_filter_finding)='0' 
   					and trim(p_filter_service_category)='0' 
   					and trim(p_filter_service_budget) ='0'  then

    insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
            SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
             , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
					   ,@qry_id
            ,prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,    tblprmlocdem mtch 
        where  prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
             
  			group by  prtl_poc1ab.qry_type
  					,prtl_poc1ab.date_type 
  					,prtl_poc1ab.start_date
  					,mtch.int_param_key
  					,mtch.age_grouping_cd 
  					,mtch.pk_gndr
  					,mtch.cd_race_census
  					,mtch.init_cd_plcm_setng
  					,mtch.long_cd_plcm_setng
  					,mtch.county_cd;
                    
          elseif   trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_age_grouping_cd) = '0'
            and trim(p_ethnicity_cd) = '0'
            and trim(p_gender_cd) = '0'
            and trim(p_init_cd_plcm_setng) = '0'
            and trim(p_long_cd_plcm_setng) = '0'
            and trim(p_county_cd) = '0'    
            and trim(p_filter_finding)<>'0' 
   					and trim(p_filter_service_category)<>'0' then

        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, power(10,8)   
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, fnd.cd_finding
  					, srvc.cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, 0 as age_grouping_cd 
  					, 0  as cd_race_census
  					, 0 as pk_gndr
  					, 0 as init_cd_plcm_setng
  					, 0 as  long_cd_plcm_setng
  					, 0 as  county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
             , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
					   ,@qry_id
            ,prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblfnd fnd 
        ,  tblsrvc srvc
         where  srvc.match_code=prtl_poc1ab.filter_service_category
             and fnd.match_code=prtl_poc1ab.filter_finding
  			group by  prtl_poc1ab.qry_type
  					,prtl_poc1ab.date_type 
  					,prtl_poc1ab.start_date
            , fnd.cd_finding
  					, srvc.cd_subctgry_poc_frc;
  			          
                      
        elseif   trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_age_grouping_cd) = '0'
            and trim(p_ethnicity_cd) = '0'
            and trim(p_gender_cd) = '0'
            and trim(p_init_cd_plcm_setng) = '0'
            and trim(p_long_cd_plcm_setng) = '0'
            and trim(p_county_cd) = '0'    
            and trim(p_filter_finding)<>'0' 
   					and trim(p_filter_service_category)='0' then

        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, power(10,8)   
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, fnd.cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, 0 as age_grouping_cd 
  					, 0  as cd_race_census
  					, 0 as pk_gndr
  					, 0 as init_cd_plcm_setng
  					, 0 as  long_cd_plcm_setng
  					, 0 as  county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
             , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
					   ,@qry_id
            ,prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblfnd fnd 
         where  fnd.match_code=prtl_poc1ab.filter_finding
  			group by  prtl_poc1ab.qry_type
  					,prtl_poc1ab.date_type 
  					,prtl_poc1ab.start_date
            , fnd.cd_finding
  				;
                    
       elseif   trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)<>'0' 
            and trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_age_grouping_cd) = '0'
            and trim(p_ethnicity_cd) = '0'
            and trim(p_gender_cd) = '0'
            and trim(p_init_cd_plcm_setng) = '0'
            and trim(p_long_cd_plcm_setng) = '0'
            and trim(p_county_cd) = '0'    
            and trim(p_filter_finding)<>'0' 
   					and trim(p_filter_service_category)='0' then

        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, power(10,8)   
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, alg.cd_allegation
  					, fnd.cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, 0 as age_grouping_cd 
  					, 0  as cd_race_census
  					, 0 as pk_gndr
  					, 0 as init_cd_plcm_setng
  					, 0 as  long_cd_plcm_setng
  					, 0 as  county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
             , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
					   ,@qry_id
            ,prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblfnd fnd 
        ,  tblalg alg
         where  fnd.match_code=prtl_poc1ab.filter_finding
            and alg.match_code=prtl_poc1ab.filter_allegation
  			group by  prtl_poc1ab.qry_type
  					,prtl_poc1ab.date_type 
  					,prtl_poc1ab.start_date
            , fnd.cd_finding
            , alg.cd_allegation
  				;
                
        elseif   trim(p_bin_placement_cd)='0' 
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)<>'0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  )  then
  
         insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, acc.cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblacc acc
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and acc.match_code=prtl_poc1ab.filter_access_type
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , acc.cd_access_type
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;
       elseif   trim(p_bin_placement_cd)<>'0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)         
            
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, plc.bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblnbrplc plc
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and plc.match_code=prtl_poc1ab.bin_placement_cd
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , plc.bin_placement_cd
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;  
      elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)<>'0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
         insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)           
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, ihs.bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblihs ihs
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and ihs.match_code=prtl_poc1ab.bin_ihs_svc_cd
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , ihs.bin_ihs_svc_cd
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;                       
    elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)<>'0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
         insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)           
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, rpt.cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblrpt rpt
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and rpt.match_code=prtl_poc1ab.cd_reporter_type
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , rpt.cd_reporter_type
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd; 
    
        elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)<>'0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
            
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, alg.cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblalg alg
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and alg.match_code=prtl_poc1ab.filter_allegation
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , alg.cd_allegation
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd; 
                    
       elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)<>'0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and (trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
            
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, power(10,8) as int_param_key 
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, alg.cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, 0 
  					, 0
  					, 0
  					, 0
  					, 0
  					, 0
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblalg alg
         where   alg.match_code=prtl_poc1ab.filter_allegation
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
                    , alg.cd_allegation;
 
        
    elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)<>'0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
            
         insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
                
         SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, fnd.cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblfnd fnd
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and fnd.match_code=prtl_poc1ab.filter_finding
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , fnd.cd_finding
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd; 
    
    elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)<>'0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
            
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, los.bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tbllos los
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and los.match_code=prtl_poc1ab.max_bin_los_cd
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , los.bin_los_cd
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;                     
    elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) <>'0' 
            and trim(p_filter_service_category)='0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)    
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, 0 as cd_subctgry_poc_frc
  					, budg.cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblbudg budg
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and budg.match_code=prtl_poc1ab.filter_service_budget
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , budg.cd_budget_poc_frc
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;                     
    elseif   trim(p_bin_placement_cd)='0'
   					and trim(p_bin_ihs_svc_cd)='0' 
   					and trim(p_cd_reporter_type)='0' 
   					and trim(p_filter_access_type)='0' 
   					and trim(p_filter_allegation)='0' 
            and trim(p_filter_finding)='0' 
            and trim(p_bin_los_cd)='0'
            and trim(p_filter_service_budget) ='0' 
            and trim(p_filter_service_category)<>'0'
            and NOT(trim(p_age_grouping_cd) ='0' 
            and trim(p_gender_cd) ='0'
            and trim(p_ethnicity_cd)='0'
            and trim(p_init_cd_plcm_setng)='0' 
            and trim(p_long_cd_plcm_setng)='0' 
            and trim(p_county_cd) = '0'  ) then
  
         
            
        SELECT    prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
  					, 0 as bin_los_cd
  					, 0 as bin_placement_cd
  					, 0 as bin_ihs_svc_cd
  					, 0 as cd_reporter_type
  					, 0 as cd_access_type
  					, 0 as cd_allegation
  					, 0 as cd_finding
  					, srvc.cd_subctgry_poc_frc
  					, 0 as cd_budget_poc_frc
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
   					, p_maxmonthstart
   					, x1
   					, x2
   					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
        ,  tblprmlocdem mtch 
        ,  tblsrvc srvc
         where   prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
            and srvc.match_code=prtl_poc1ab.filter_service_category
          
  			group by  prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key  
  					, prtl_poc1ab.bin_dep_cd
            , srvc.cd_subctgry_poc_frc
            , mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd;   
                    
        else
        insert IGNORE into cache_poc1ab_aggr
			   ( qry_type
                ,date_type
                ,start_date
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
                ,cnt_start_date
                ,cnt_entries
                ,cnt_exits
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,qry_id
                ,start_year)
            
--            explain
            SELECT    
              prtl_poc1ab.qry_type
  					, prtl_poc1ab.date_type 
  					, prtl_poc1ab.start_date
  					, mtch.int_param_key
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
  					, mtch.age_grouping_cd 
  					, mtch.cd_race_census
  					, mtch.pk_gndr
  					, mtch.init_cd_plcm_setng
  					, mtch.long_cd_plcm_setng
  					, mtch.county_cd
  					, coalesce(sum(prtl_poc1ab.cnt_start_date),0) as cnt_start_date
  					, coalesce(sum(prtl_poc1ab.cnt_entries),0) as cnt_entries
  					, coalesce(sum(prtl_poc1ab.cnt_exits),0) as cnt_exits
            , p_minmonthstart
  					, p_maxmonthstart
  					, x1
  					, x2
  					, now() as insert_date
            , @qry_id
            , prtl_poc1ab.start_year
  			FROM prtl_poc1ab_ram prtl_poc1ab  
            ,  tblprmlocdem  mtch 
             , tbllos los 
  						, tblnbrplc plc 
  						, tblihs ihs 
  						, tblrpt rpt 
  						, tblacc acc 
  						, tblalg alg 
  						, tblfnd fnd 
  						, tblsrvc srv 
  						, tblbudg bud 
        where start_year >= 2000 
             and prtl_poc1ab.int_match_param_key = mtch.int_match_param_key
             and  los.match_code = prtl_poc1ab.max_bin_los_cd
             and plc.match_code=prtl_poc1ab.bin_placement_cd
             and ihs.match_code=prtl_poc1ab.bin_ihs_svc_cd
             and rpt.match_code=prtl_poc1ab.cd_reporter_type
             and acc.match_code=prtl_poc1ab.filter_access_type
             and alg.match_code=prtl_poc1ab.filter_allegation
             and fnd.match_code=prtl_poc1ab.filter_finding
             and srv.match_code=prtl_poc1ab.filter_service_category
             and bud.match_code=prtl_poc1ab.filter_service_budget
  			group by  prtl_poc1ab.qry_type
  					,prtl_poc1ab.date_type 
  					,prtl_poc1ab.start_date
  					,mtch.int_param_key
  					,mtch.age_grouping_cd 
  					,mtch.pk_gndr
  					,mtch.cd_race_census
  					,mtch.init_cd_plcm_setng
  					,mtch.long_cd_plcm_setng
  					,mtch.county_cd
  					, prtl_poc1ab.bin_dep_cd
  					, los.bin_los_cd
  					, plc.bin_placement_cd
  					, ihs.bin_ihs_svc_cd
  					, rpt.cd_reporter_type
  					, acc.cd_access_type
  					, alg.cd_allegation
  					, fnd.cd_finding
  					, srv.cd_subctgry_poc_frc
  					, bud.cd_budget_poc_frc  ;        
                    
    
        end if;
        commit;
      else
          start transaction;
           INSERT INTO cache_poc1ab_params
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
                ,min_start_date
                ,max_start_date
                ,cnt_qry
                ,last_run_date)

        select 
         (select @qry_ID:=(max(qry_ID) + 1)  from cache_poc1ab_params)
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
  			,p_minmonthstart
  			,p_maxmonthstart
  			,1
        ,now();                                 
      end if;
      commit;
 else
        update cache_poc1ab_params
        set cnt_qry=cnt_qry + 1,last_run_date=now()
        where p_qry_id=qry_id;
end if;

 
                  SELECT  
                            poc1ab.qry_type as   "qry_type_poc1"
                            , poc1ab.date_type
                            , poc1ab.start_date  as "Month"
                            , poc1ab.age_grouping_cd as  "Age_Grouping_Cd"
                            , ref_age.age_grouping as "Age Grouping"
                            , poc1ab.pk_gndr  as "Gender_Cd"
                            , ref_gdr.gender_desc as "Gender" 
                            , poc1ab.cd_race  as "Ethnicity_Cd"
                            , ref_eth.tx_race_census as "Race/Ethnicity" 
                            , poc1ab.init_cd_plcm_setng as "InitPlacementCd"
                            , ref_fpl.placement as  "First Placement Setting"
                            , poc1ab.long_cd_plcm_setng as "LongPlacementCd"
                            , ref_lpl.placement as "Longest Placement Setting" 
                            , poc1ab.county_cd as "Removal_County_Cd"
                            , ref_cnty.county as "County"
                            , poc1ab.bin_dep_cd as "Dependency_Cd"
                            , ref_dep.bin_dep_desc as "Dependency"
 --                           , case when poc1ab.bin_dep_cd=0 then 'All episodes'
 --                                  when poc1ab.bin_dep_cd=1 then 'No Dependency'
 --                                 when poc1ab.bin_dep_cd=2 then 'Immediate Dependency'
 --                                 when poc1ab.bin_dep_cd=3 then 'Eventual Dependency' end as "Dependency"
                            , poc1ab.bin_los_cd 
                            , ref_los.bin_los_desc as "Length of Service Desc"
                            , poc1ab.bin_placement_cd
                            , ref_plc.bin_placement_desc as "Placement Count Desc"
                            , poc1ab.bin_ihs_svc_cd
                            , ref_ihs.bin_ihs_svc_tx as "In-Home Service Desc"
                            , poc1ab.cd_reporter_type
                            , ref_rpt.tx_reporter_type as "Reporter Desc"
                            , poc1ab.cd_access_type
                            , ref_acc.tx_access_type as "Access type desc"
                            , poc1ab.cd_allegation
                            , ref_alg.tx_allegation as "Allegation"
                            , poc1ab.cd_finding
                            , ref_fnd.tx_finding as "Finding"
                            , poc1ab.cd_subctgry_poc_frc as "Service Type Cd"
                            , ref_srv.tx_subctgry_poc_frc as "Service Type"
                            , poc1ab.cd_budget_poc_frc as "Budget Cd"
                            , ref_bud.tx_budget_poc_frc as "Budget"
                            , case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end  as   "Total In Care First Day"
                            , case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end as "Number of Entries"
                            ,  case when ( --  first day + entered care < exited care
                                (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end)
                                +
                                (case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1))
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end)) >= -- exited care
                                    (case when (cnt_exits) > 0 /* jitter all above 0 */ 
                                        then 
                                            case when (round(cnt_exits + 2 * sqrt(-2 
                                            * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
                                            then 1
                                            else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                            end
                                        else cnt_exits
                                    end)
                                    
                                then -- use exits as they are
                                (case when (cnt_exits) > 0 /* jitter all above 0 */ 
                                        then 
                                            case when (round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                            * cos(2*pi()*poc1ab.x2),0) ) <1
                                            then 1
                                            else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                            end
                                        else cnt_exits
                                    end)
                                else -- use first day plus entered
                                (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end)
                                +
                                (case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end)
                            end as "Number of Exits"
            FROM cache_poc1ab_aggr poc1ab  
            join (select distinct int_param_key from tblprmlocdem) 
            prm on prm.int_param_key=poc1ab.int_param_key
--             join  (select distinct bin_los_cd from tbllos) los on los.bin_los_cd=poc1ab.bin_los_cd
--             join (select distinct bin_placement_cd from tblnbrplc) plc on plc.bin_placement_cd=poc1ab.bin_placement_cd
--             join (select distinct bin_ihs_svc_cd from tblihs) ihs on ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
--             join (select distinct cd_reporter_type from tblrpt) rpt on rpt.cd_reporter_type=poc1ab.cd_reporter_type
--             join (select distinct cd_access_type from tblacc) acc on acc.cd_access_type=poc1ab.cd_access_type
--             join (select distinct cd_allegation from tblalg) alg on alg.cd_allegation=poc1ab.cd_allegation
--             join (select distinct cd_finding from tblfnd) fnd on fnd.cd_finding=poc1ab.cd_finding
--             join (select distinct cd_subctgry_poc_frc from tblsrvc) srv on srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
--             join (select distinct cd_budget_poc_frc from tblbudg) bud on bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
            join tbllos2 los on los.bin_los_cd=poc1ab.bin_los_cd
            join tblnbrplc2 plc on plc.bin_placement_cd=poc1ab.bin_placement_cd
            join tblihs2 ihs on ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
            join tblrpt2 rpt on rpt.cd_reporter_type=poc1ab.cd_reporter_type
            join tblacc2 acc on acc.cd_access_type=poc1ab.cd_access_type
            join tblalg2 alg on alg.cd_allegation=poc1ab.cd_allegation
            join tblfnd2 fnd on fnd.cd_finding=poc1ab.cd_finding
            join tblsrvc2 srv on srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
            join tblbudg2  bud on bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
              join ref_lookup_age_census ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
            join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc1ab.cd_race
            join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc1ab.pk_gndr
            join ref_lookup_placement ref_fpl on ref_fpl.placement_cd=poc1ab.init_cd_plcm_setng
            join ref_lookup_placement ref_lpl on ref_lpl.placement_cd=poc1ab.long_cd_plcm_setng
            join ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
             join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
            join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
            join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=poc1ab.bin_placement_cd
            join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
            join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
            join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
            join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
            join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
            join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
            where poc1ab.start_date 
            between p_mindate and p_maxdate
            order by qry_type,date_type,start_date,poc1ab.bin_dep_cd;     


  
 else --  all zeroes
          update cache_poc1ab_params
        set cnt_qry=cnt_qry + 1,last_run_date=now()
        where p_qry_id=1;
        
                  SELECT  
                            poc1ab.qry_type as   "qry_type_poc1"
                            , poc1ab.date_type
                            , poc1ab.start_date  as "Month"
                            , poc1ab.age_grouping_cd as  "Age_Grouping_Cd"
                            , ref_age.age_grouping as "Age Grouping"
                            , poc1ab.pk_gndr  as "Gender_Cd"
                            , ref_gdr.gender_desc as "Gender" 
                            , poc1ab.cd_race  as "Ethnicity_Cd"
                            , ref_eth.tx_race_census as "Race/Ethnicity" 
                            , poc1ab.init_cd_plcm_setng as "InitPlacementCd"
                            , ref_fpl.placement as  "First Placement Setting"
                            , poc1ab.long_cd_plcm_setng as "LongPlacementCd"
                            , ref_lpl.placement as "Longest Placement Setting" 
                            , poc1ab.county_cd as "Removal_County_Cd"
                            , ref_cnty.county as "County"
                            , poc1ab.bin_dep_cd as "Dependency_Cd"
                            , ref_dep.bin_dep_desc as "Dependency"
 --                           , case when poc1ab.bin_dep_cd=0 then 'All episodes'
 --                                  when poc1ab.bin_dep_cd=1 then 'No Dependency'
 --                                 when poc1ab.bin_dep_cd=2 then 'Immediate Dependency'
 --                                 when poc1ab.bin_dep_cd=3 then 'Eventual Dependency' end as "Dependency"
                            , poc1ab.bin_los_cd 
                            , ref_los.bin_los_desc as "Length of Service Desc"
                            , poc1ab.bin_placement_cd
                            , ref_plc.bin_placement_desc as "Placement Count Desc"
                            , poc1ab.bin_ihs_svc_cd
                            , ref_ihs.bin_ihs_svc_tx as "In-Home Service Desc"
                            , poc1ab.cd_reporter_type
                            , ref_rpt.tx_reporter_type as "Reporter Desc"
                            , poc1ab.cd_access_type
                            , ref_acc.tx_access_type as "Access type desc"
                            , poc1ab.cd_allegation
                            , ref_alg.tx_allegation as "Allegation"
                            , poc1ab.cd_finding
                            , ref_fnd.tx_finding as "Finding"
                            , poc1ab.cd_subctgry_poc_frc as "Service Type Cd"
                            , ref_srv.tx_subctgry_poc_frc as "Service Type"
                            , poc1ab.cd_budget_poc_frc as "Budget Cd"
                            , ref_bud.tx_budget_poc_frc as "Budget"
                            , case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end  as   "Total In Care First Day"
                            , case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end as "Number of Entries"
                            ,  case when ( --  first day + entered care < exited care
                                (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end)
                                +
                                (case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1))
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end)) >= -- exited care
                                    (case when (cnt_exits) > 0 /* jitter all above 0 */ 
                                        then 
                                            case when (round(cnt_exits + 2 * sqrt(-2 
                                            * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
                                            then 1
                                            else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                            end
                                        else cnt_exits
                                    end)
                                    
                                then -- use exits as they are
                                (case when (cnt_exits) > 0 /* jitter all above 0 */ 
                                        then 
                                            case when (round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                            * cos(2*pi()*poc1ab.x2),0) ) <1
                                            then 1
                                            else round(cnt_exits + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                            end
                                        else cnt_exits
                                    end)
                                else -- use first day plus entered
                                (case when (cnt_start_date) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_start_date) 
                                end)
                                +
                                (case when (cnt_entries) > 0 /* jitter all above 0 */ 
                                    then 
                                        case when (round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) 
                                        * cos(2*pi()*poc1ab.x2),0) ) <1
                                        then 1
                                        else round(cnt_entries + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
                                        end
                                    else (cnt_entries) 
                                end)
                            end as "Number of Exits"
            FROM cache_poc1ab_aggr poc1ab  
         
              join ref_lookup_age_census ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
            join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc1ab.cd_race
            join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc1ab.pk_gndr
            join ref_lookup_placement ref_fpl on ref_fpl.placement_cd=poc1ab.init_cd_plcm_setng
            join ref_lookup_placement ref_lpl on ref_lpl.placement_cd=poc1ab.long_cd_plcm_setng
            join ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
             join ref_filter_dependency ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
            join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
            join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=poc1ab.bin_placement_cd
            join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
            join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
            join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
            join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
            join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
            join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
            join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
            where poc1ab.qry_id=1
            and  poc1ab.int_param_key=power(10,8)
            and poc1ab.bin_los_cd=0
            and poc1ab.bin_placement_cd=0
            and poc1ab.bin_ihs_svc_cd=0
            and poc1ab.cd_reporter_type=0
            and poc1ab.cd_access_type=0
            and poc1ab.cd_allegation=0
            and poc1ab.cd_finding=0
            and poc1ab.cd_subctgry_poc_frc=0
            and poc1ab.cd_budget_poc_frc=0
            and poc1ab.start_date 
            between p_mindate and p_maxdate
            order by qry_type,date_type,start_date,poc1ab.bin_dep_cd;     
    end if; -- end all NOT ZEROES
 end if;--  end strored procedure on
end
