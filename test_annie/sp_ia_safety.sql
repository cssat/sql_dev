-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DROP PROCEDURE `test_annie`.`sp_ia_safety`;

DELIMITER $$

CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_ia_safety`(  
p_age_grouping_cd varchar(30)
,  p_ethnicity_cd varchar(30)
,  p_cd_county varchar(250) 
,  p_cd_reporter_type varchar(100) 
,  p_filter_access_type varchar(30) 
,  p_filter_allegation  varchar(30)
, p_filter_finding varchar(30))
begin
 

    declare p_mindate datetime;
    declare p_maxdate datetime;
    declare p_maxmonthstart datetime;
    declare p_minmonthstart datetime;
    declare p_qry_id bigint;

    declare var_qry_cnt int;

    declare  flg_procedure_off int;
    declare var_row_cnt_param int;
    declare var_row_cnt_cache int;
    declare var_calling_procedure int;
   
	DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
    
    set flg_procedure_off =0;
    
    if  flg_procedure_off =0 then    
            

        
        set var_calling_procedure=6;
        
        call sp_ia_assign_desc (var_calling_procedure);
   
        select min_date_any ,max_date_yr,min_date_any 
        ,max_date_yr 
        into p_minmonthstart,p_maxmonthstart ,p_mindate,p_maxdate 
        FROM ref_lookup_max_date where id=var_calling_procedure;
    
       
        
        select qry_id into p_qry_id from cache_pbcs2_params
        where age_grouping_cd=left(p_age_grouping_cd,20)
            and cd_race_census=left(p_ethnicity_cd,30) 
            and cd_county=	left(p_cd_county,250)   
            and cd_reporter_type=left(p_cd_reporter_type,100)
            and filter_access_type=left(p_filter_access_type,30)
            and filter_allegation=left(p_filter_allegation,30)
            and filter_finding=left(p_filter_finding,30)

        limit 1; 
        set @qry_ID:= coalesce(p_qry_id,(select (max(qry_ID) + 1)  from cache_pbcs2_params),1);
            
  if p_qry_id is null then    
  
    
  
			INSERT INTO cache_pbcs2_params
  			(qry_id
			 , age_grouping_cd
  			,cd_race_census
  			,cd_county
  			,cd_reporter_type
  			,filter_access_type
  			,filter_allegation
  			,filter_finding
  			,min_start_date
  			,max_start_date
  			,cnt_qry
  			,last_run_date)

    select 
         @qry_id
  			,p_age_grouping_cd
  			,p_ethnicity_cd
  			,p_cd_county
  			,p_cd_reporter_type
  			,p_filter_access_type
  			,p_filter_allegation
  			,p_filter_finding
  			,p_minmonthstart
  			,p_maxmonthstart
  			,1
        ,now();
else
    update cache_pbcs2_params
    set cnt_qry=cnt_qry + 1,last_run_date=now()
    where qry_id=p_qry_id;
end if;


    call sp_create_ia_cachekeys (p_age_grouping_cd 
        , p_ethnicity_cd 
        , p_cd_county 
        , p_cd_reporter_type 
        , p_filter_access_type 
        , p_filter_allegation  
        , p_filter_finding 
        , coalesce(p_qry_id,@qry_id));




				
			update cachekeys cache join cache_qry_param_pbcs2 pbcs2
			set in_cache=1,cache.qry_id=pbcs2.qry_id
			where pbcs2.int_hash_key=cache.int_hash_key;
			
	
			select count(*), sum(in_cache) 
        into var_row_cnt_param,var_row_cnt_cache
        from cachekeys;

	if var_row_cnt_param <> var_row_cnt_cache then
    
      call sp_ia_load_param_tables(
           p_age_grouping_cd 
        ,  p_ethnicity_cd 
        ,  p_cd_county 
        ,  p_cd_reporter_type 
        ,  p_filter_access_type 
        ,  p_filter_allegation  
        ,  p_filter_finding 
        ,  0 
        ,  1 
        ,  p_mindate
        ,  p_maxdate
        ,  var_calling_procedure);    
        
    
    
        call sp_ia_assign_param_multiplier;

  drop temporary table if exists q_total;
   set @incl='
        create temporary table q_total engine=memory as
        select s2.cohort_begin_date
        ,s2.date_type
        ,s2.qry_type';
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
            set    @incl= concat(@incl,char(13),'
            , mtch.int_param_key ');
        else
            set @incl=concat(@incl,char(13),', ',@int_param_key,' as int_param_key');
        end if;     
        if trim(p_cd_reporter_type)='0' then
        set @incl=concat(@incl,char(13),', 0 as cd_reporter_type');
        else
        set @incl=concat(@incl,char(13),', rpt.cd_reporter_type');
        end if;	
        if trim(p_filter_access_type)='0' then
        set @incl=concat(@incl,char(13),', 0 as cd_access_type');
        else
        set @incl=concat(@incl,char(13),', acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation)= '0' then
        set @incl=concat(@incl,char(13),', 0 as cd_allegation');
        else
        set @incl=concat(@incl,char(13),', alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding)='0' then
        set @incl=concat(@incl,char(13),', 0 as cd_finding');
        else
        set @incl=concat(@incl,char(13),', fnd.cd_finding');
        end if;	        
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
             , cast(( mtch.int_param_key *  ',@mult_int_param_key,') as decimal(12,0))  ');
        else
            set @incl=concat(@incl,char(13),', cast((',@int_param_key,' *  ',@mult_int_param_key,' ) as decimal(12,0))');
        end if;
       if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,'
            + cast((rpt.cd_reporter_type * ',@mult_cd_reporter_type,')as decimal(12,0)) ');
        end if;					
       if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,' 
            + cast((acc.cd_access_type * ',@mult_cd_access_type,') as decimal(12,0))');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,' 
            + cast( (alg.cd_allegation * ',@mult_cd_allegation,') as decimal(12,0))');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,'
            + cast( (fnd.cd_finding * ',@mult_cd_finding,') as decimal(12,0))');
        end if;	        

     set @incl=concat(@incl,'as int_hash_key');
     set @incl=concat(@incl,char(13),'
      ,sum(cnt_case) as total_families
  FROM prtl_pbcs2 s2');
   if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
  	join tblprmlocdem mtch on mtch.int_match_param_key=s2.int_match_param_key 
		and  mtch.cd_race_census in (select distinct cd_race from tbleth)');
    end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblrpt rpt on rpt.match_code=s2.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblacc acc on acc.match_code=s2.filter_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblalg alg on alg.match_code=s2.filter_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblfnd fnd on fnd.match_code=s2.filter_finding');
        end if;	        
    set @incl=concat(@incl,char(13),'join cachekeys ck on 
         ck.int_hash_key=');
     if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
             cast(( mtch.int_param_key *  ',@mult_int_param_key,') as decimal(12,0))  ');
        else
            set @incl=concat(@incl,char(13),'cast((',@int_param_key,' * ',@mult_int_param_key,' ) as decimal(12,0))');
        end if;
       if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,'
            + cast((rpt.cd_reporter_type * ',@mult_cd_reporter_type,') as decimal(12,0)) ');
        end if;					
       if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,' 
            + cast((acc.cd_access_type * ',@mult_cd_access_type,') as decimal(12,0))');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,' 
            + cast( (alg.cd_allegation * ',@mult_cd_allegation,') as decimal(12,0))');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,'
            + cast( (fnd.cd_finding * ',@mult_cd_finding,') as decimal(12,0))');
        end if;
        set @incl=concat(@incl,char(13),' and ck.in_cache=0');
        set @incl=concat(@incl,char(13),'
        where cohortrefcount=1
        group by s2.cohort_begin_date
      ,s2.date_type
      ,s2.qry_type');
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
            , mtch.int_param_key');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			, rpt.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			, acc.cd_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,char(13),'
			, alg.cd_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,char(13),'
			, fnd.cd_finding');
        end if;	        
      
         if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
                                    , mtch.cd_sib_age_grp 
                                    , mtch.cd_race_census
                                    , mtch.cd_county');  
         end if;
        set @incl=concat(@incl,';',char(13));
        
        drop  temporary table if exists mycode;
        create temporary table mycode as select @incl;
        
        PREPARE stmt FROM @incl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        create index idx_params on q_total (cohort_begin_date,date_type,qry_type,int_hash_key);
        create index idx_other_params on q_total (cohort_begin_date,date_type,qry_type,cd_reporter_type,cd_access_type,cd_allegation,cd_finding);
        
       set @incl='        
        insert IGNORE into cache_pbcs2_aggr 
            ( qry_type
                ,date_type
                ,start_date
                ,int_param_key
                ,cd_reporter_type
                ,cd_access_type
                ,cd_allegation
                ,cd_finding
                ,cd_sib_age_grp
                ,cd_race
                ,cd_county
                ,month
                ,among_first_cmpt_rereferred
                ,min_start_date
                ,max_start_date
                ,x1
                ,x2
                ,insert_date
                ,int_hash_key
                ,qry_id
                ,start_year)

           SELECT    
              prtl_pbcs2.qry_type
            , prtl_pbcs2.date_type 
            , prtl_pbcs2.cohort_begin_date';
            
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
         set    @incl= concat(@incl,char(13),'
            , mtch.int_param_key ');
        else
            set @incl=concat(@incl,char(13),', ', @int_param_key);
        end if;
        if p_cd_reporter_type = '0' then
            set @incl=concat(@incl,char(13),', 0');
        else
            set @incl=concat(@incl,char(13),', rpt.cd_reporter_type');
        end if;
        if p_filter_access_type = '0' then
             set @incl=concat(@incl,char(13),', 0');       
        else
            set @incl=concat(@incl,char(13),', acc.cd_access_type');
        end if;        
        if p_filter_allegation = '0' then
             set @incl=concat(@incl,char(13),', 0');       
        else
            set @incl=concat(@incl,char(13),', alg.cd_allegation');
        end if;  
        if p_filter_finding = '0' then
             set @incl=concat(@incl,char(13),', 0');       
        else
            set @incl=concat(@incl,char(13),', fnd.cd_finding');
        end if;     
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
            set @incl=concat(@incl,char(13),'
            , mtch.cd_sib_age_grp 
            , mtch.cd_race_census
            , mtch.cd_county');
        else
             set @incl=concat(@incl,char(13),'
             ,0,0,0');
        end if;

        set @incl=concat(@incl,char(13),', n.nbr
        , sum(cnt_case)/(q.total_families * 1.0000 ) * 100
        ');
    set @incl=concat(@incl,char(13),', DATE',char(39), p_minmonthstart,char(39));
		set @incl=concat(@incl,char(13),', DATE',char(39), p_maxmonthstart,char(39));
		set @incl=concat(@incl,char(13),', ',char(39), rand(),char(39));
		set @incl=concat(@incl,char(13),', ',char(39), rand(),char(39));    
		set @incl=concat(@incl,char(13),', DATE',char(39), now() ,char(39),' as insert_date');           
       set @incl=concat(@incl,char(13),',cast((');
        if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
            set @incl=concat(@incl,'mtch.int_param_key');
        else
            set @incl=concat(@incl,@int_param_key);
        end if;
        set @incl=concat(@incl,' * ',@mult_int_param_key,') as decimal(12,0))
			+ cast((');
       if p_cd_reporter_type = '0' then
            set @incl=concat(@incl,char(13),' 0');
        else
            set @incl=concat(@incl,char(13),' rpt.cd_reporter_type');
        end if;
        set @incl=concat(@incl,'  * ',@mult_cd_reporter_type,') as decimal(12,0))
			+  cast((');
        if p_filter_access_type = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' acc.cd_access_type');
        end if;   
        set @incl=concat(@incl,'   * ',@mult_cd_access_type,') as decimal(12,0))
			+  cast((');
        if p_filter_allegation = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' alg.cd_allegation');
        end if;  
        set @incl=concat(@incl,' * ',@mult_cd_allegation,') as decimal(12,0))',char(13),'+ ');
        if p_filter_finding = '0' then
             set @incl=concat(@incl,char(13),'( 0');       
        else
            set @incl=concat(@incl,char(13),'( fnd.cd_finding');
        end if;     
        set @incl=concat(@incl,' * ',@mult_cd_finding,')');
        set @incl=concat(@incl,char(13),', ck.qry_id',char(13),'
            , year(prtl_pbcs2.cohort_begin_date)
        FROM prtl_pbcs2  ');
          if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
			set @incl=concat(@incl,char(13),
			'join tblprmlocdem mtch 
            on mtch.int_match_param_key=prtl_pbcs2.int_match_param_key 
            and mtch.cd_race_census in (select cd_race from tbleth)');
        end if;
        if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblrpt rpt on rpt.match_code=prtl_pbcs2.cd_reporter_type');
        end if;					
        if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,char(13),'
			join tblacc acc on acc.match_code=prtl_pbcs2.filter_access_type');
        end if;					

        if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblalg alg on alg.match_code=prtl_pbcs2.filter_allegation');
        end if;	       
        if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,char(13),'
			join tblfnd fnd on fnd.match_code=prtl_pbcs2.filter_finding');
        end if;	
    
    set @incl=concat(@incl,char(13),'join (select number * 3 as nbr from numbers where number between 1 and 16 ) n on n.nbr >= nxt_ref_within_min_month');
    
    
    set @incl=concat(@incl,char(13),'
    join cachekeys ck on ck.int_hash_key=cast((');
            if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
            set @incl=concat(@incl,'mtch.int_param_key');
        else
            set @incl=concat(@incl,@int_param_key);
        end if;
        set @incl=concat(@incl,' * ',@mult_int_param_key,') as decimal(12,0))
			+ cast((');
       if p_cd_reporter_type = '0' then
            set @incl=concat(@incl,char(13),' 0');
        else
            set @incl=concat(@incl,char(13),' rpt.cd_reporter_type');
        end if;
        set @incl=concat(@incl,'  * ',@mult_cd_reporter_type,') as decimal(12,0))
			+  cast((');
        if p_filter_access_type = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' acc.cd_access_type');
        end if;   
        set @incl=concat(@incl,'   * ',@mult_cd_access_type,') as decimal(12,0))
			+  cast((');
        if p_filter_allegation = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' alg.cd_allegation');
        end if;  
        set @incl=concat(@incl,' * ',@mult_cd_allegation,') as decimal(12,0))',char(13),'+ ');
        if p_filter_finding = '0' then
             set @incl=concat(@incl,char(13),'( 0');       
        else
            set @incl=concat(@incl,char(13),'( fnd.cd_finding');
        end if;  
         set @incl=concat(@incl,' * ',@mult_cd_finding,')');
        set @incl=concat(@incl,char(13), ' and ck.in_cache=0');
         set @incl= concat(@incl,char(13),' join q_total q on 
       q.cohort_begin_date =prtl_pbcs2.cohort_begin_date
	and q.date_type =prtl_pbcs2.date_type
	and q.qry_type =prtl_pbcs2.qry_type
  and q.int_hash_key=cast((');
          if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then
            set @incl=concat(@incl,'mtch.int_param_key');
        else
            set @incl=concat(@incl,@int_param_key);
        end if;
        set @incl=concat(@incl,' * ',@mult_int_param_key,') as decimal(12,0))
			+ cast((');
       if p_cd_reporter_type = '0' then
            set @incl=concat(@incl,char(13),' 0');
        else
            set @incl=concat(@incl,char(13),' rpt.cd_reporter_type');
        end if;
        set @incl=concat(@incl,'  * ',@mult_cd_reporter_type,') as decimal(12,0))
			+  cast((');
        if p_filter_access_type = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' acc.cd_access_type');
        end if;   
        set @incl=concat(@incl,'   * ',@mult_cd_access_type,') as decimal(12,0))
			+  cast((');
        if p_filter_allegation = '0' then
             set @incl=concat(@incl,char(13),' 0');       
        else
            set @incl=concat(@incl,char(13),' alg.cd_allegation');
        end if;  
        set @incl=concat(@incl,' * ',@mult_cd_allegation,') as decimal(12,0))',char(13),'+ ');
        if p_filter_finding = '0' then
             set @incl=concat(@incl,char(13),'( 0');       
        else
            set @incl=concat(@incl,char(13),'( fnd.cd_finding');
        end if;     
         set @incl=concat(@incl,' * ',@mult_cd_finding,')');
           
        set @incl=concat(@incl,char(13),'where prtl_pbcs2.cohortrefcount=1 
        and prtl_pbcs2.nxt_ref_within_min_month between 3 and 48
        group by prtl_pbcs2.qry_type
								, prtl_pbcs2.date_type 
								, prtl_pbcs2.cohort_begin_date
              , n.nbr');
          if NOT (p_age_grouping_cd = '0' 
            and p_ethnicity_cd = '0' 
            and p_cd_county = '0' ) then    
            set @incl=concat(@incl,char(13),'
                ,mtch.int_param_key
                ,mtch.cd_sib_age_grp 
                ,mtch.cd_race_census
                ,mtch.cd_county');
            end if;
              if trim(p_cd_reporter_type)<>'0' then
	        set @incl=concat(@incl,char(13),'   
                , rpt.cd_reporter_type');
            end if;
           if trim(p_filter_access_type)<>'0' then
	        set @incl=concat(@incl,char(13),'     
                , acc.cd_access_type');
         end if;
           if trim(p_filter_allegation) <> '0' then
	        set @incl=concat(@incl,char(13),'
                , alg.cd_allegation');
         end if;
           if trim(p_filter_finding) <> '0' then
	        set @incl=concat(@incl,char(13),'
                , fnd.cd_finding;');
            end if;  
         
        drop temporary table if exists mycode;
        create temporary table mycode as
        select @incl;
        
        PREPARE stmt FROM @incl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        			
        insert into cache_qry_param_pbcs2
						(int_param_key
						,cd_sib_age_grp
						,cd_race
						,cd_county
						,cd_reporter_type
						,cd_access_type
						,cd_allegation
						,cd_finding
						,qry_id
						,int_hash_key)
		
						select 
						ck.int_param_key
						,cd_sib_age_grp
						,cd_race_census
						,cd_county
						,cd_reporter_type
						,cd_access_type
						,cd_allegation
						,cd_finding
						,ck.qry_id
						,ck.int_hash_key
						from cachekeys ck
						join (select distinct int_param_key
											, cd_sib_age_grp 
											, cd_race_census
											, cd_county
											from tblprmlocdem) q on q.int_param_key=ck.int_param_key
						where ck.in_cache=0;
        
    end if; 

			SELECT  	 pbcs2.month as  "Months Since 1st Investigation/Assessment"
                ,pbcs2.qry_type   
								, pbcs2.start_year  as "Cohort Period"
								, pbcs2.cd_sib_age_grp as  "age_grouping_cd"
								, ref_age.tx_sib_age_grp as "Age Grouping"
								, pbcs2.cd_race  as "ethnicity_cd"
								, case pbcs2.cd_race  when 0   then @eth0  when 1   then @eth1  when 2   then @eth2  when 3   then @eth3  when 4   then @eth4  when 5   then @eth5  when 6   then @eth6  when 7   then @eth7  when 8   then @eth8  when 9   then @eth9  when 10  then @eth10 when 11  then @eth11 when 12  then @eth12 end as "Race/Ethnicity" 
								, pbcs2.cd_county as "county_cd"
								, ref_cnty.county as "County"
								, pbcs2.cd_reporter_type
								, ref_rpt.tx_reporter_type as "Reporter Desc"
								, pbcs2.cd_access_type
								, ref_acc.tx_access_type as "Access type desc"
								, pbcs2.cd_allegation
								, case pbcs2.cd_allegation  when 0  then @alg0 when 1  then @alg1 when 2  then @alg2 when 3  then @alg3 when 4  then @alg4 end as "Allegation"
								, pbcs2.cd_finding
              , case pbcs2.cd_finding  when 0  then @fnd0 when 1  then @fnd1 when 2  then @fnd2 when 3  then @fnd3 when 4  then @fnd4 end as "Finding"								
								, pbcs2.among_first_cmpt_rereferred as "Percent"
        from cache_pbcs2_aggr pbcs2
		 					join cachekeys ck on ck.int_hash_key=pbcs2.int_hash_key
							and pbcs2.qry_id=ck.qry_id
			join ref_last_dw_transfer on 1=1
            join ref_lookup_sib_age_grp ref_age on ref_age.cd_sib_age_grp=pbcs2.cd_sib_age_grp
						join ref_lookup_county ref_cnty on ref_cnty.county_cd=pbcs2.cd_county
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=pbcs2.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=pbcs2.cd_access_type
           where date_add(start_date,INTERVAL (15 + pbcs2.month) MONTH) <= cutoff_date
 						order by pbcs2.qry_type   

								, pbcs2.start_year
								, pbcs2.cd_sib_age_grp
								, pbcs2.cd_race
								, pbcs2.cd_county 
								, pbcs2.cd_access_type
								, pbcs2.cd_reporter_type
								, pbcs2.cd_allegation
								, pbcs2.cd_finding
								, pbcs2.month;
		
    end if; 
end