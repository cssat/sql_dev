--/****** Object:  StoredProcedure [prtl].[sp_ooh_pit_counts]    Script Date: 6/19/2014 2:24:18 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


CREATE PROCEDURE [prtl].[sp_ooh_pit_counts](
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
, @bin_dep_cd varchar(20)
,@fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
, @debug smallint = 0
)
as
 set nocount on
-- declare  @date varchar(3000)
--declare @age_grouping_cd varchar(30)
--declare @race_cd varchar(30)
--declare @gender_cd varchar(10)
--declare @init_cd_plcm_setng varchar(30)
--declare @long_cd_plcm_setng varchar(30) 
--declare @county_cd varchar(200) 
--declare @bin_los_cd varchar(30) 
--declare @bin_placement_cd varchar(30) 
--declare @bin_ihs_svc_cd varchar(30) 
--declare @cd_reporter_type varchar(100) 
--declare @filter_access_type varchar(30) 
--declare @filter_allegation  varchar(30)
--declare @filter_finding varchar(30)
--declare @filter_service_category  varchar(100)
--declare @filter_service_budget varchar(100)
--declare @bin_dep_cd varchar(20)
--declare @fl_return_results smallint  -- 1 = yes; 0 = no (for loading cache tables set to 0)
--set @date = '2000-01-01,2014-04-01'
--set @age_grouping_cd='1'
--set @race_cd='8'
--set @gender_cd='0'
--set @init_cd_plcm_setng='0'
--set @long_cd_plcm_setng='0'
--set @county_cd='0'
--set @bin_los_cd='0'
--set @bin_placement_cd='0'
--set @bin_ihs_svc_cd='0'
--set @cd_reporter_type='0'
--set @filter_access_type='0'
--set @filter_allegation='0'
--set @filter_finding='0'
--set  @filter_service_category='0'
--set @filter_service_budget= '0'
--set @bin_dep_cd='0'
--set @fl_return_results=0

   declare @qry_id bigint;
    declare @mindate datetime;
    declare @maxdate datetime;
		declare @tblqryid table(qry_id int)
	declare @var_row_cnt_param int;
	declare @var_row_cnt_cache int;
	declare @mysql varchar(8000);
    declare @x1 float;
    declare @x2 float;

    set @x1=dbo.RandFn();
    set @x2=dbo.RandFn();


	

    -----------------------------------  set dates  -------------------------------------  		
    select @mindate=min_date_any ,@maxdate=max_date_any 
	FROM ref_lookup_max_date where id=19;

	
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
		and filter_srvc_type=left(@filter_service_category,100)
		and filter_budget=left(@filter_service_budget,100)
		and bin_dep_cd=left(@bin_dep_cd,20)
		order by qry_ID asc	);  


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
					,bin_dep_cd
					,[min_start_date]
					,[max_start_date]
					,[cnt_qry]
					,[last_run_date])
					OUTPUT inserted.qry_ID into @tblqryid
				select 
					isnull((select max(qry_id) +1
						from prtl.[cache_poc1ab_params]),1)
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
					,@bin_dep_cd
					,@mindate
					,@maxdate
					,1
					,getdate()

					select @qry_id=qry_id from @tblqryid;
			end 
			else
				begin
						update prtl.cache_poc1ab_params
						set cnt_qry=cnt_qry + 1,last_run_date=getdate()
						where @qry_id=qry_id				
				end
			
					-- see if results are in cache as a subset of previously run query
		if OBJECT_ID('tempDB..#cachekeys') is not null drop table #cachekeys;
		   select	(select multiplier from prtl.ooh_int_hash_key where parameter_name='constant') + 
					(age.age_grouping_cd	* (select multiplier from prtl.ooh_int_hash_key where parameter_name='age_grouping_cd') ) + 
					(cd_race		*   (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_race_census')) +
					(pk_gndr		*   (select multiplier from prtl.ooh_int_hash_key where parameter_name='pk_gndr')) +
					(init_cd_plcm_setng		*   (select multiplier from prtl.ooh_int_hash_key where parameter_name='init_cd_plcm_setng')) +
					(long_cd_plcm_setng 	* 	 (select multiplier from prtl.ooh_int_hash_key where parameter_name='long_cd_plcm_setng')) +
					(cd_cnty 	* 	 (select multiplier from prtl.ooh_int_hash_key where parameter_name='county_cd')) +
					([bin_dep_cd] *  (select multiplier from prtl.ooh_int_hash_key where parameter_name='bin_dep_cd') ) +
					([bin_los_cd] *  (select multiplier from prtl.ooh_int_hash_key where parameter_name='bin_los_cd') ) +
					([bin_placement_cd] *  (select multiplier from prtl.ooh_int_hash_key where parameter_name='bin_placement_cd') ) +
					([bin_ihs_svc_cd] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='bin_ihs_svc_cd') ) +
					([cd_reporter_type] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_reporter_type') ) + 
					([cd_access_type] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_access_type')) +
					([cd_allegation] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_allegation')) +
					([cd_finding] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_finding')) + 
					([cd_subctgry_poc_frc] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_subctgry_poc_frc'))  + 
					( [cd_budget_poc_frc] * (select multiplier from prtl.ooh_int_hash_key where parameter_name='cd_budget_poc_frc'))    [int_hash_key]
					 ,power(10.0,8) + (age.age_grouping_cd	* power(10.0,7)) +   
									(cd_race		*  power(10.0,6)) +
									(pk_gndr		*  power(10.0,4)) +
									(init_cd_plcm_setng		*  power(10.0,3)) +
									(long_cd_plcm_setng 	* 	power(10.0,2)) +
									cd_cnty 	[int_param_key]
					,age_grouping_cd
					,cd_race
					,pk_gndr
					,init_cd_plcm_setng
					,long_cd_plcm_setng
					,cd_cnty
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
					 ,0 as in_cache
					 ,q.qry_id as qry_id
					,RAND(cast(NEWID() as varbinary))  x1 
					,RAND(cast(NEWID() as varbinary)) x2
				into #cachekeys
				from (select @qry_id  qry_id) q  
				cross join (	select cast(arrValue as int) age_grouping_cd from  [dbo].[fn_ReturnStrTableFromList] (@age_grouping_cd,0) 
						) age
				cross join (	select cast(arrValue as int) cd_race
						from  [dbo].[fn_ReturnStrTableFromList](@race_cd,0) 
						) eth
				cross join (	select cast(arrValue as int)pk_gndr
						from dbo.fn_ReturnStrTableFromList(@gender_cd,0)
						) gdr
				cross join (	select cast(arrValue as int) init_cd_plcm_setng
						from  dbo.fn_ReturnStrTableFromList(@init_cd_plcm_setng,0) sel ) fpl
				cross join (	select cast(arrValue as int) long_cd_plcm_setng
						from dbo.fn_ReturnStrTableFromList(@long_cd_plcm_setng,0) sel 
							) lpl
				cross join (	select  cast(arrValue as int) cd_cnty
						from dbo.fn_ReturnStrTableFromList(@County_Cd,0) sel 
						) cnty
				cross join (	select cast(arrValue as int)  bin_los_cd
						from [dbo].[fn_ReturnStrTableFromList] (@bin_los_cd,0)
						) los 
				cross join (	select cast(arrValue as int)  bin_placement_cd
						from  dbo.fn_ReturnStrTableFromList(@bin_placement_cd,0) sel
						) plc
				cross join (	select cast(arrValue as int) bin_ihs_svc_cd
						from dbo.fn_ReturnStrTableFromList(@bin_ihs_svc_cd,0) sel
						) ihs
				cross join (	select cast(arrValue as int)  cd_reporter_type
						from dbo.fn_ReturnStrTableFromList(@cd_reporter_type,0) sel
						) rpt
				cross join (	select  cast(arrValue as int)  cd_access_type
						from  dbo.fn_ReturnStrTableFromList(@filter_access_type,0) sel
						) acc
				cross join (	select cast(arrValue as int)  cd_allegation
						from dbo.fn_ReturnStrTableFromList(@filter_allegation,0) sel
						) alg
				cross join (	select cast(arrValue as int)  cd_finding
						from dbo.fn_ReturnStrTableFromList(@filter_finding,0) sel
					) fnd
				cross join (	select cast(arrValue as int)  cd_subctgry_poc_frc
						from dbo.fn_ReturnStrTableFromList(@filter_service_category,0) sel
						) srv
				cross join (	select cast(arrValue as int)  cd_budget_poc_frc
						from  dbo.fn_ReturnStrTableFromList(@filter_service_budget,0) sel
							) bud
				cross join (	select cast(arrValue as int)  bin_dep_cd
						from [dbo].[fn_ReturnStrTableFromList] (@bin_dep_cd,0) ) dep



			create index idx_int_hash_key on #cachekeys(int_hash_key,in_cache);
			create index idx_qryid_params on #cachekeys(qry_id,int_hash_key);
			create index  idx_params on #cachekeys(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation	,cd_finding,cd_budget_poc_frc,cd_subctgry_poc_frc,in_cache);                   

				
			update cache
			set in_cache=1,qry_id=poc1ab.qry_id
			from #cachekeys cache
			join [prtl].[cache_qry_param_poc1ab] poc1ab
			on poc1ab.int_hash_key=cache.int_hash_key

	
			select @var_row_cnt_param=count(*),@var_row_cnt_cache=sum(in_cache) from #cachekeys;
		
	if @var_row_cnt_param <> @var_row_cnt_cache
			begin


			
						set @mysql='insert into prtl.cache_poc1ab_aggr( 
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
								,[age_grouping_cd]
								,[cd_race]
								,[pk_gndr]
								,[init_cd_plcm_setng]
								,[long_cd_plcm_setng]
								,[county_cd]
								,[cnt_start_date]
								,[min_start_date]
								,[max_start_date]
								,[x1]
								,[x2]
								,[insert_date]
								,int_hash_key
								,qry_id
								,start_year,fl_include_perCapita)
					SELECT    poc1ab.qry_type
								, poc1ab.date_type 
								, poc1ab.[start_date]
								, che.int_param_key  '
					
				if @bin_dep_cd!='0' 
								set @mysql=CONCAT(@mysql,'
									, dep.bin_dep_cd')
				else			set @mysql=CONCAT(@mysql,'
									, 0');
				if @bin_los_cd!='0' 
								set @mysql=CONCAT(@mysql,'
									, los.bin_los_cd')
				else			set @mysql=CONCAT(@mysql,'
									, 0');
				if @bin_placement_cd!='0' 
								set @mysql=CONCAT(@mysql,'
									, plc.bin_placement_cd')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @bin_ihs_svc_cd!='0' 
								set @mysql=CONCAT(@mysql,'
									, ihs.bin_ihs_svc_cd')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @cd_reporter_type!='0' 
								set @mysql=CONCAT(@mysql,'
								, rpt.cd_reporter_type')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @filter_access_type!='0' 
								set @mysql=CONCAT(@mysql,'
								, acc.cd_access_type')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @filter_allegation!='0' 
								set @mysql=CONCAT(@mysql,'
								, alg.cd_allegation')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @filter_finding!='0' 
								set @mysql=CONCAT(@mysql,'
								,  fnd.cd_finding')
				else			set @mysql=CONCAT(@mysql,'
								, 0');		
				if @filter_service_category!='0' 
								set @mysql=CONCAT(@mysql,'
								, srv.cd_subctgry_poc_frc')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @filter_service_budget!='0' 
								set @mysql=CONCAT(@mysql,'
								, bud.cd_budget_poc_frc')
				else			set @mysql=CONCAT(@mysql,'
								, 0');	
				if @age_grouping_cd!='0' 
								set @mysql=CONCAT(@mysql,'
								, age.age_grouping_cd ')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @race_cd!='0' 
								set @mysql=CONCAT(@mysql,'
								, eth.cd_race')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @gender_cd!='0' 
								set @mysql=CONCAT(@mysql,'
								, gdr.pk_gndr')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @init_cd_plcm_setng!='0' 
								set @mysql=CONCAT(@mysql,'
								, fpl.init_cd_plcm_setng')
				else			set @mysql=CONCAT(@mysql,'
								, 0');		
				if @long_cd_plcm_setng!='0' 
								set @mysql=CONCAT(@mysql,'
								, lpl.long_cd_plcm_setng')
				else			set @mysql=CONCAT(@mysql,'
								, 0');
				if @county_cd!='0' 
								set @mysql=CONCAT(@mysql,'
								, cnty.cd_cnty')
				else			set @mysql=CONCAT(@mysql,'
								, 0');									
				set @mysql=CONCAT(@mysql,'
								, isnull(sum(poc1ab.cnt_child_unique),0) as cnt_start_date');
				set @mysql=CONCAT(@mysql,'
								,',char(39),convert(varchar(10),@mindate,121),char(39) );
				set @mysql=CONCAT(@mysql,'
								,',char(39),convert(varchar(10),@maxdate,121),char(39) );
				set @mysql=CONCAT(@mysql,'
								, che.x1');  			
				set @mysql=CONCAT(@mysql,'
								, che.x2' );  				
				set @mysql=CONCAT(@mysql,'
								,',char(39),convert(varchar(10),getdate() ,121),char(39) );
				set @mysql=CONCAT(@mysql,'
								, che.int_hash_key ' );  			
				set @mysql=CONCAT(@mysql,'
								, che.qry_id ' );  	
				set @mysql=CONCAT(@mysql,'
								,','year(poc1ab.[start_date]),1
							FROM prtl.ooh_point_in_time_measures  poc1ab');
				if (@age_grouping_cd!='0')
					set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select prm.*
										from prm_age_census prm
										join [dbo].[fn_ReturnStrTableFromList](',char(39),@age_grouping_cd,char(39),',0) 
										on cast(arrValue as int)=age_grouping_cd
											) age on age.match_code=poc1ab.age_grouping_cd_census');
				if (@race_cd!='0')
				set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select eth.cd_race,eth.cd_origin,eth.match_code
									from prm_eth_census eth
									join [dbo].[fn_ReturnStrTableFromList](',char(39),@race_cd,char(39),',0) 
									on cast(arrValue as int)=eth.cd_race
											) eth on eth.match_code=poc1ab.cd_race and poc1ab.census_hispanic_latino_origin_cd = eth.cd_origin');
				if (@gender_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select pk_gndr,match_code
									from prm_gndr gdr
									join dbo.fn_ReturnStrTableFromList(',char(39),@gender_cd,char(39),',0) 
									on cast(arrValue as int)=gdr.pk_gndr) gdr on gdr.match_code=poc1ab.pk_gndr');
				if (@init_cd_plcm_setng!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select fpl.init_cd_plcm_setng,fpl.match_code
										from prm_fpl  fpl
										join dbo.fn_ReturnStrTableFromList(',char(39),@init_cd_plcm_setng,char(39),',0)  sel on cast(sel.arrValue as int)=fpl.init_cd_plcm_setng) fpl on fpl.match_code=poc1ab.init_cd_plcm_setng');
				if (@long_cd_plcm_setng!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select lpl.long_cd_plcm_setng,lpl.match_code
										from prm_lpl    lpl
										join dbo.fn_ReturnStrTableFromList(',char(39),@long_cd_plcm_setng,char(39),',0)  sel on cast(sel.arrValue as int)=lpl.long_cd_plcm_setng) lpl on lpl.match_code=poc1ab.long_cd_plcm_setng');
				if(@County_Cd!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select  cnty.cd_cnty,cnty.match_code
										from prm_cnty cnty
										join dbo.fn_ReturnStrTableFromList(',char(39),@County_Cd,char(39),',0)  sel on cast(sel.arrValue as int)=cnty.cd_cnty 
										) cnty on cnty.match_code=poc1ab.county_cd');
				if(@bin_los_cd!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select los.bin_los_cd,los.match_code from [dbo].[fn_ReturnStrTableFromList] (',char(39),@bin_los_cd,char(39),',0) sel
								join [prm_los_max_bin_los_cd] los on los.bin_los_cd=cast(arrValue as int)) los on los.match_code=poc1ab.max_bin_los_cd');
				if(@bin_placement_cd!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (	select plc.bin_placement_cd,plc.match_code
										from prm_plc plc
										join dbo.fn_ReturnStrTableFromList(',char(39),@bin_placement_cd,char(39),',0)  sel
										on cast(sel.arrValue as int)=plc.bin_placement_cd) plc on plc.match_code=poc1ab.bin_placement_cd');
				if(@bin_ihs_svc_cd!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (	select ihs.bin_ihs_svc_cd,ihs.match_code
										from prm_ihs ihs
										join dbo.fn_ReturnStrTableFromList(',char(39),@bin_ihs_svc_cd,char(39),',0)  sel
										on cast(sel.arrValue as int)=ihs.bin_ihs_svc_cd) ihs on ihs.match_code=poc1ab.bin_ihs_svc_cd');
				if(@cd_reporter_type!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (	select rpt.cd_reporter_type,rpt.match_code
										from prm_rpt rpt
										join dbo.fn_ReturnStrTableFromList(',char(39),@cd_reporter_type,char(39),',0)  sel
										on cast(sel.arrValue as int)=rpt.cd_reporter_type) rpt on rpt.match_code=poc1ab.cd_reporter_type');
				if(@filter_access_type!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join ( 	select  acc.cd_access_type,acc.match_code
										from prm_acc acc			
										join dbo.fn_ReturnStrTableFromList(',char(39),@filter_access_type,char(39),',0)  sel
										on cast(sel.arrValue as int)=acc.cd_access_type)  acc on acc.match_code=poc1ab.filter_access_type');
				if(@filter_allegation!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select alg.cd_allegation,alg.match_code
										from prm_alg alg
										join dbo.fn_ReturnStrTableFromList(',char(39),@filter_allegation,char(39),',0)  sel
										on cast(sel.arrValue as int)=alg.cd_allegation) alg on alg.match_code=poc1ab.filter_allegation');
				if(@filter_finding!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (select fnd.cd_finding,fnd.match_code
										from prm_fnd fnd
										join dbo.fn_ReturnStrTableFromList(',char(39),@filter_finding,char(39),',0)  sel
										on cast(sel.arrValue as int)= fnd.cd_finding) fnd on fnd.match_code=poc1ab.filter_finding');
				if(@filter_service_category!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
							join (	select srvc.cd_subctgry_poc_frc,srvc.match_code
										from prm_srvc srvc				
										join dbo.fn_ReturnStrTableFromList(',char(39),@filter_service_category,char(39),',0)  sel
										on cast(sel.arrValue as int)=srvc.cd_subctgry_poc_frc) srv on srv.match_code=poc1ab.filter_service_category');
				if(@filter_service_budget!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
								join (	select cd_budget_poc_frc,match_code
										from prm_budg bud
											join dbo.fn_ReturnStrTableFromList(',char(39),@filter_service_budget,char(39),',0)  sel
												on cast(sel.arrValue as int)=bud.cd_budget_poc_frc		) bud on bud.match_code=poc1ab.filter_service_budget');
				if(@bin_dep_cd!='0')
							set @mysql=CONCAT(@mysql,char(13),char(10),'
								join (select dep.bin_dep_cd,dep.match_code 
											from prm_dep dep 
											join [dbo].[fn_ReturnStrTableFromList] (',char(39),@bin_dep_cd,char(39),',0)  on dep.bin_dep_cd=cast(arrValue as int)) dep on dep.match_code=poc1ab.bin_dep_cd');
				set @mysql=CONCAT(@mysql,char(13),char(10),'
								join #cachekeys che on che.int_hash_key=power(10.0,21) +  ')
				if (@age_grouping_cd!='0')
					set @mysql=CONCAT(@mysql,char(13),char(10),'
											(age.age_grouping_cd	* power(10.0,20)) + ');
				if (@race_cd!='0')
				set @mysql=CONCAT(@mysql,char(13),char(10),'
											(eth.cd_race		*  power(10.0,18)) +');
				if (@gender_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
												(gdr.pk_gndr		*  power(10.0,17)) +');
					if (@init_cd_plcm_setng!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(fpl.init_cd_plcm_setng		*  power(10.0,16)) +');
					if (@long_cd_plcm_setng!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
												(lpl.long_cd_plcm_setng 	* 	power(10.0,15)) +');
					if (@county_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(cnty.cd_cnty 	* 	power(10.0,13)) +');
					if (@bin_dep_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(dep.[bin_dep_cd] * power(10.0,12))  +');
					if (@bin_los_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(los.[bin_los_cd] * power(10.0,11) ) +');
					if (@bin_placement_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(plc.[bin_placement_cd] * power(10.0,10) ) +');
					if (@bin_ihs_svc_cd!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(ihs.[bin_ihs_svc_cd] * power(10.0,9) ) +');
					if (@cd_reporter_type!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'
													(rpt.[cd_reporter_type] * power(10.0,7) ) + ');
					if (@filter_access_type!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
												(acc.[cd_access_type] * power(10.0,6)) +');
					if (@filter_allegation!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
													(alg.[cd_allegation] * power(10.0,5)) +');
					if (@filter_finding!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
													(fnd.[cd_finding] * power(10.0,4)) + ');
					if (@filter_service_category!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
													(srv.[cd_subctgry_poc_frc] * power(10.0,2))  + ');
					if (@filter_service_budget!='0')
								set @mysql=CONCAT(@mysql,char(13),char(10),'	
													 bud.[cd_budget_poc_frc]  + ');
				set @mysql=concat(@mysql,'   0  and che.in_cache=0');
				set @mysql=CONCAT(@mysql,char(13),char(10),'where fl_poc1ab=1 
						group by  poc1ab.qry_type
									,poc1ab.date_type 
									,poc1ab.[start_date]
									,year(poc1ab.[start_date])
									,che.int_hash_key
									,che.int_param_key
									,che.qry_id
									,che.x1
									,che.x2');
								if @bin_dep_cd!='0'   	set @mysql=CONCAT(@mysql,char(13),char(10),', dep.bin_dep_cd')
								if @bin_los_cd!='0' 		set @mysql=CONCAT(@mysql,char(13),char(10),', los.bin_los_cd')
								if @bin_placement_cd!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', plc.bin_placement_cd')
								if @bin_ihs_svc_cd!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', ihs.bin_ihs_svc_cd')
								if @cd_reporter_type!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', rpt.cd_reporter_type')
								if @filter_access_type!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', acc.cd_access_type')
								if @filter_allegation!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', alg.cd_allegation')
								if @filter_finding!='0' set @mysql=CONCAT(@mysql,char(13),char(10),',  fnd.cd_finding')
								if @filter_service_category!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', srv.cd_subctgry_poc_frc')
								if @filter_service_budget!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', bud.cd_budget_poc_frc')
								if @age_grouping_cd!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', age.age_grouping_cd ')
								if @race_cd!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', eth.cd_race')
								if @gender_cd!='0' set @mysql=CONCAT(@mysql,char(13),char(10),', gdr.pk_gndr')
								if @init_cd_plcm_setng!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', fpl.init_cd_plcm_setng')
								if @long_cd_plcm_setng!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', lpl.long_cd_plcm_setng')
								if @county_cd!='0' 	set @mysql=CONCAT(@mysql,char(13),char(10),', cnty.cd_cnty')

								truncate table prtl.poc1ab_code
								insert into prtl.poc1ab_code(mycode)
								select @mysql;
								exec (@mysql)
	
		update cache_poc1ab_aggr
		set cache_poc1ab_aggr.fl_include_perCapita=0
		-- select pop_cnt, cache_poc1ab_aggr.*
		from prtl.cache_poc1ab_aggr,prm_ooh_census_population   
		where exists(select * from #cachekeys ck where cache_poc1ab_aggr.qry_id=ck.qry_id)
		and prm_ooh_census_population.measurement_year=start_year
		and prm_ooh_census_population.county_cd=cache_poc1ab_aggr.county_cd 
		and prm_ooh_census_population.pk_gndr=cache_poc1ab_aggr.pk_gndr
		and prm_ooh_census_population.cd_race=cache_poc1ab_aggr.cd_race
		and prm_ooh_census_population.age_grouping_cd=cache_poc1ab_aggr.age_grouping_cd
		and  (cache_poc1ab_aggr.cnt_start_date *1.00 >   pop_cnt * .35  	);

	
		
	
						update statistics prtl.cache_poc1ab_aggr
						insert into prtl.cache_qry_param_poc1ab
									   ([int_param_key]
									   ,bin_dep_cd
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
								,bin_dep_cd
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
								   ,cd_cnty
								   ,qry_id
								   ,[int_hash_key]
						from #cachekeys ck
						where ck.in_cache=0;
	

						update statistics prtl.cache_qry_param_poc1ab;
	end

		if @fl_return_results=1
						SELECT  
								poc1ab.qry_type as   "qry_type_poc1"
								, poc1ab.date_type
								, poc1ab.start_date  as "Month"
								, poc1ab.age_grouping_cd as  "Age_Grouping_Cd"
								, ref_age.age_grouping as "Age Grouping"
								, poc1ab.pk_gndr  as "Gender_Cd"
								, ref_gdr.tx_gndr as "Gender" 
								, poc1ab.cd_race  as "Ethnicity_Cd"
								, ref_eth.tx_race_census as "Race/Ethnicity" 
								, poc1ab.init_cd_plcm_setng as "InitPlacementCd"
								, ref_fpl.tx_plcm_setng as  "First Placement Setting"
								, poc1ab.long_cd_plcm_setng as "LongPlacementCd"
								, ref_lpl.tx_plcm_setng as "Longest Placement Setting" 
								, poc1ab.county_cd as "Removal_County_Cd"
								, ref_cnty.county_desc as "County"
								, poc1ab.bin_dep_cd as [Dependency Cd]
								, ref_dep.bin_dep_desc as [Dependency]
								, poc1ab.bin_los_cd 
								, ref_los.bin_los_desc as [Length of Service Desc]
								, poc1ab.bin_placement_cd
								, ref_plc.bin_placement_desc as [Placement Count Desc]
								, poc1ab.bin_ihs_svc_cd
								, ref_ihs.bin_ihs_svc_tx as [In-Home Service Desc]
								, poc1ab.cd_reporter_type
								, ref_rpt.tx_reporter_type as [Reporter Desc]
								, poc1ab.cd_access_type
								, ref_acc.tx_access_type as [Access type desc]
								, poc1ab.cd_allegation
								, ref_alg.tx_allegation as [Allegation]
								, poc1ab.cd_finding
								, ref_fnd.tx_finding as [Finding]
								, poc1ab.cd_subctgry_poc_frc as [Service Type Cd]
								, ref_srv.tx_subctgry_poc_frc as [Service Type]
								, poc1ab.cd_budget_poc_frc as [Budget Cd]
								, ref_bud.tx_budget_poc_frc as [Budget]
								, case when (cnt_start_date) > 0 /* jitter all above 0 */ 
										then 
											case when (round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0) ) <1
											then 1
											else round(cnt_start_date + 2 * sqrt(-2 * log(poc1ab.x1)) * cos(2*pi()*poc1ab.x2),0)
											end
										else (cnt_start_date) 
									end  as   "Total In Care First Day"
							
						FROM prtl.cache_poc1ab_aggr poc1ab  
						 join #cachekeys ck on poc1ab.qry_id=ck.qry_id and poc1ab.int_hash_key=ck.int_hash_key
						join ref_age_groupings_census ref_age on ref_age.age_grouping_cd=poc1ab.age_grouping_cd
						join ref_lookup_ethnicity_census ref_eth on ref_eth.cd_race_census=poc1ab.cd_race
						join ref_lookup_gender ref_gdr on ref_gdr.pk_gndr=poc1ab.pk_gndr
						join ref_lookup_plcmnt ref_fpl on ref_fpl.cd_plcm_setng=poc1ab.init_cd_plcm_setng
						join ref_lookup_plcmnt ref_lpl on ref_lpl.cd_plcm_setng=poc1ab.long_cd_plcm_setng
						join ref_lookup_county ref_cnty on ref_cnty.county_cd=poc1ab.county_cd
						join vw_ref_dependency_lag ref_dep on ref_dep.bin_dep_cd=poc1ab.bin_dep_cd
							and poc1ab.date_type=ref_dep.date_type
							and poc1ab.start_date between min_filter_date and cohort_max_filter_date
						join ref_filter_los ref_los on ref_los.bin_los_cd=poc1ab.bin_los_cd
						join ref_filter_nbr_placement ref_plc on ref_plc.bin_placement_cd=poc1ab.bin_placement_cd
						join ref_filter_ihs_services ref_ihs on ref_ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
						join ref_filter_reporter_type ref_rpt on ref_rpt.cd_reporter_type=poc1ab.cd_reporter_type
						join ref_filter_access_type ref_acc on ref_acc.cd_access_type=poc1ab.cd_access_type
						join ref_filter_allegation ref_alg on ref_alg.cd_allegation=poc1ab.cd_allegation
						join ref_filter_finding ref_fnd on ref_fnd.cd_finding=poc1ab.cd_finding
						join ref_service_cd_subctgry_poc ref_srv on ref_srv.cd_subctgry_poc_frc=poc1ab.cd_subctgry_poc_frc
						join ref_service_cd_budget_poc_frc ref_bud on ref_bud.cd_budget_poc_frc=poc1ab.cd_budget_poc_frc
            where poc1ab.start_date   between @mindate and @maxdate
			order by poc1ab.qry_type 
								, poc1ab.date_type
								, poc1ab.start_date
								, poc1ab.age_grouping_cd
								, poc1ab.pk_gndr
								, poc1ab.cd_race  
								, poc1ab.init_cd_plcm_setng 
								, poc1ab.long_cd_plcm_setng
								, poc1ab.county_cd 
								, poc1ab.bin_dep_cd 
								, poc1ab.bin_los_cd 
								, poc1ab.bin_placement_cd
								, poc1ab.bin_ihs_svc_cd
								, poc1ab.cd_reporter_type
								, poc1ab.cd_access_type
								, poc1ab.cd_allegation
								, poc1ab.cd_finding
								, poc1ab.cd_subctgry_poc_frc 
								, poc1ab.cd_budget_poc_frc 
								;

	

	IF @debug = 1
	begin

		--Table
		IF OBJECT_ID (N'temp.cachekeys', N'U') IS NOT NULL
			DROP TABLE temp.cachekeys;

		select * into temp.cachekeys 
		from #cachekeys;
	end