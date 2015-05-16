--  exec [base].[prod_build_placement_care_days_mobility]
CREATE  procedure [base].[prod_build_placement_care_days_mobility]
as
set nocount on
declare @fystart int= 2000;
declare @fystop int= 2013;



if object_id('tempdb..#placements') is not null
	drop table #placements

select 
			rp.removal_dt
			,rp.birthdate
			-- age yr at removal
			,isnull(dbo.fnc_datediff_yrs(birthdate, removal_dt),-99)  age_yrs_removal
			--age_yrs_exit
			,isnull(iif(rp.discharge_dt <= cutoff_date,iif( rp.[18bday] <= rp.discharge_dt
							,dbo.fnc_datediff_yrs(birthdate,rp.[18bday])
							,dbo.fnc_datediff_yrs(birthdate,rp.discharge_dt)),-99),-99) age_yrs_exit
			-- race
			,isnull(pd.cd_race_census,7) cd_race_census
			--ethnicity
			,isnull(pd.census_Hispanic_Latino_Origin_cd,5) census_Hispanic_Latino_Origin_cd
			--county_cd
			,isnull(rp.derived_county,-99) [county_cd]
			-- federal discharge date force
			,iif( -- lessor date of 18th birthday is greater than cutoff_date use cutoff else use lessor date 18 bday or discharge date
					IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) > cutoff_date
						, cutoff_date
						,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) ) discharg_frc_18
			,rp.id_removal_episode_fact 
			,rp.id_placement_fact
			,rp.plcmnt_seq
			,rp.begin_date plc_begin
			,IIF(rp.end_date> -- discharg_frc_18
							iif(IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)  > cutoff_date
								, cutoff_date
								,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) ) 
						--   choose discharg_frc_18
						,iif(IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)  > cutoff_date
								, cutoff_date
								,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) ) 
						,rp.end_date)  plc_end
			,iif(rp.plcmnt_seq >= 11
				,11
				,rp.plcmnt_seq) ord 
			,child
			,isnull(rpx.berk_tx_plcm_setng, 'Other') current_setng
			--,lead(isnull(rpx.berk_tx_plcm_setng, 'Other'), 1,0) 
			--	over (partition by child order by begin_date) next_setng
			,tx_end_rsn
			,lag(tx_end_rsn) over (partition by sfy,id_removal_episode_fact order by begin_date,end_date) prior_end_rsn
			,cast(iif(datediff(dd,removal_dt,(IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt))))<8,1,0) as smallint) flag_7day
			,cast(0 as smallint) flag_trh
			,(select max(calendar_date) from CALENDAR_DIM where month(calendar_date)=month(rp.removal_dt)
					and CALENDAR_DATE between cd.fy_start_date and cd.fy_stop_date and day(calendar_date)<=day(rp.removal_dt))	 anniv_removal_dt
			,sfy
			,cd.fy_start_date
			,cd.fy_stop_date
			,iif(nd.id_prsn is not null,1,0) fl_nondcfs_custody
		,cast(null as int)  as care_day_cnt_prior_anniv
		,cast(null as int)  as care_day_cnt_post_anniv
		,cast(null as int) as prior_year_service
		,cast(null as int) as post_year_service
into #placements
from (select  distinct state_fiscal_yyyy sfy
							,min(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM) fy_start_date_int
							,max(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM asc RANGE between current row and UNBOUNDED FOLLOWING) fy_stop_date_int
							,min(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date)  fy_start_date
							,max(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date asc RANGE between current row and UNBOUNDED FOLLOWING)   fy_stop_date 
						from dbo.calendar_dim 
						where state_fiscal_yyyy between @fystart and @fystop
				) cd
join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
join base.rptPlacement_Events rp 
		on removal_dt <= cd.fy_stop_date
--		 discharge_dt >=fy_start_date
		and (iif( -- lessor date of 18th birthday is greater than cutoff_date use cutoff else use lessor date 18 bday or discharge date
			IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) > cutoff_date
				, cutoff_date
				,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) )) >=fy_start_date	
			and rp.begin_date <= cd.fy_stop_date
			--  end_date >=cd.fy_start_date
			and (IIF(rp.end_date> -- discharg_frc_18
					iif(IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)  > cutoff_date
						, cutoff_date
						,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) ) 
				--   choose discharg_frc_18
				,iif(IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)  > cutoff_date
						, cutoff_date
						,IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) ) 
				,rp.end_date) ) >= cd.fy_start_date
	left join dbo.ref_plcm_setting_xwalk rpx
		on rp.cd_plcm_setng = rpx.cd_plcm_setng
left join PEOPLE_DIM pd on pd.ID_PRSN=rp.child and pd.IS_CURRENT=1
left join dbo.vw_nondcfs_combine_adjacent_segments nd on nd.id_prsn=rp.child
		and nd.cust_begin<=rp.begin_date
		and rp.end_date<=nd.cust_end
where rp.cd_epsd_type <> 5   and dbo.fnc_datediff_yrs(pd.dt_birth,begin_date)<18
-- and placement begin date less than cutoff_date
and removal_dt <= 
				iif( -- lessor of 18th birthday , discharge date,cutoff_date
						IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) > cutoff_date
							, cutoff_date
							, IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)) 
order by child, begin_date ,sfy



update #placements
set flag_trh=1
--  select * 
 from #placements 
 where NOT(tx_end_rsn = 'Changed Caregiver'  and charindex('Trial Return Home',prior_end_rsn)>0)
				and charindex('Trial Return Home',prior_end_rsn)>0

--select * from #placements where anniv_removal_dt is null
--these are last placements before a discharge where the discharge occurs prior to the removal anniversary date within the fiscal year
update #placements
set anniv_removal_dt = null
		,care_day_cnt_prior_anniv=datediff(dd,iif(fy_start_date>=plc_begin
		,fy_start_date,plc_begin)
		,iif(fy_stop_date <=IIF(discharg_frc_18>plc_end,plc_end,discharg_frc_18) ,fy_stop_date,IIF(discharg_frc_18>plc_end,plc_end,discharg_frc_18)))
		,prior_year_service=dbo.fnc_datediff_yrs(removal_dt,discharg_frc_18)
where   anniv_removal_dt not between removal_dt and discharg_frc_18 

delete  #placements where anniv_removal_dt is null and care_day_cnt_prior_anniv =0 ;

-- update the placements containing the anniversary dates.
update #placements 
set care_day_cnt_prior_anniv=datediff(dd,iif(fy_start_date>=plc_begin,fy_start_date,plc_begin),anniv_removal_dt)
		,prior_year_service=dbo.fnc_datediff_yrs(removal_dt,iif(removal_dt<>anniv_removal_dt,dateadd(dd,-1,anniv_removal_dt),removal_dt))
		,care_day_cnt_post_anniv=datediff(dd,anniv_removal_dt,iif(plc_end>=fy_stop_date,fy_stop_date,plc_end))
		,post_year_service=dbo.fnc_datediff_yrs(removal_dt,anniv_removal_dt)
where anniv_removal_dt is not null and anniv_removal_dt between plc_begin and plc_end

--update the placements without the anniversary dates
update P 
set care_day_cnt_prior_anniv=datediff(dd,iif(fy_start_date>=plc_begin	,fy_start_date,plc_begin),iif(plc_end>=fy_stop_date,fy_stop_date,plc_end))
		,prior_year_service=dbo.fnc_datediff_yrs(removal_dt, iif(plc_begin<fy_start_date,fy_start_date,plc_begin)) 
from #placements P
where anniv_removal_dt is not null and anniv_removal_dt NOT between plc_begin and plc_end






--select * from #placements where anniv_removal_dt is not null and care_day_cnt_prior_anniv is null and care_day_cnt_post_anniv is null  order by child,id_removal_episode_fact

--CREATE NONCLUSTERED INDEX idx_1
--ON #placements ([flag_7day],[flag_trh],[fl_nondcfs_custody])
--INCLUDE ([removal_dt],[age_yrs_removal],[age_yrs_exit],[cd_race_census],[census_Hispanic_Latino_Origin_cd],[county_cd],[plcmnt_seq],[plc_begin],[current_setng],[sfy],[fy_start_date],[fy_stop_date],[care_day_cnt_post_anniv],[post_year_service])

--CREATE NONCLUSTERED INDEX idx_2
--ON #placements ([cd_race_census],[census_Hispanic_Latino_Origin_cd],[flag_7day],[flag_trh],[fl_nondcfs_custody])
--INCLUDE ([removal_dt],[age_yrs_removal],[age_yrs_exit],[county_cd],[plcmnt_seq],[plc_begin],[current_setng],[sfy],[fy_start_date],[fy_stop_date],[care_day_cnt_post_anniv],[post_year_service])

CREATE NONCLUSTERED INDEX idx_3
on #placements ([sfy], [post_year_service])



if object_id('tempdb..#care_day_count') is not null
	drop table #care_day_count

create table #care_day_count(fiscal_yr int,care_days int,years_in_care int
,age_removal int,age_exit int,cd_race int, cd_cnty int, excludes_7day int,excludes_trh int,excludes_nondcfs int
,placement_moves int,kin_cnt int,foster_cnt int,group_cnt int)



insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh,excludes_nondcfs
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
		rp.sfy fiscal_yr
		,IIF(rp.prior_year_service>10,10,rp.prior_year_service)
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
		, nd.excludes_nondcfs
  		,  sum(rp.care_day_cnt_prior_anniv) n_care_days
		, sum(iif(plcmnt_seq > 1 and plc_begin between fy_start_date and fy_stop_date,1,0)) placement_moves
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Kin',1,0)) kin_cnt
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Foster',1,0)) foster_cnt
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Group',1,0)) group_cnt
from  #placements rp
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_yrs_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_yrs_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join prm_shortstay ss on ss.match_code=rp.flag_7day
	join prm_trh trh on trh.match_code=rp.flag_trh
	join prm_nondcfs_custody nd on nd.match_code=rp.fl_nondcfs_custody
group by 
		  rp.sfy
		  ,IIF(rp.prior_year_service>10,10,rp.prior_year_service)
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
		,nd.excludes_nondcfs

insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh,excludes_nondcfs
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
		rp.sfy fiscal_yr
		, ISNULL(IIF(rp.post_year_service>10,10,rp.post_year_service),0)
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
		, nd.excludes_nondcfs
  		,  sum(rp.care_day_cnt_post_anniv) n_care_days
		, sum(iif(plcmnt_seq > 1 and plc_begin between fy_start_date and fy_stop_date,1,0)) placement_moves
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Kin',1,0)) kin_cnt
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Foster',1,0)) foster_cnt
		, sum(iif(plcmnt_seq>1  and plc_begin between fy_start_date and fy_stop_date and current_setng='Group',1,0)) group_cnt
from  #placements rp
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_yrs_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_yrs_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join prm_shortstay ss on ss.match_code=rp.flag_7day
	join prm_trh trh on trh.match_code=rp.flag_trh
	join prm_nondcfs_custody nd on nd.match_code=rp.fl_nondcfs_custody
group by 
		  rp.sfy
		, ISNULL(IIF(rp.post_year_service>10,10,rp.post_year_service),0)
		, yrs.age_yr 
		, yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
		,nd.excludes_nondcfs



truncate table base.placement_care_days_mobility
 insert into base.placement_care_days_mobility(fiscal_yr,age_yrs_removal,age_yrs_exit,county_cd
 ,cd_race,years_in_care,exclude_7day,exclude_trh,exclude_nondcfs,care_days,placement_moves,kin_cnt,foster_cnt,group_cnt)
 select fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh,excludes_nondcfs,sum(care_days),sum(placement_moves),sum(kin_cnt),sum(foster_cnt),sum(group_cnt)
  from #care_day_count
  group by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh,excludes_nondcfs
 order by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh,excludes_nondcfs

 --select * from base.placement_care_days_mobility
 --where age_exit=-99 and age_removal=-99 
 --and county_cd=0 and cd_race=0 and exclude_7day=0
 --and exclude_trh=0 order by fiscal_yr,age_removal,age_exit,county_cd,cd_race,years_in_care
 --,exclude_7day,exclude_trh

 --select fiscal_yr,sum(care_days) care_days
 --from base.care_day_count
 --where age_exit=-99 and age_removal=-99 
 --and county_cd=0 and cd_race=0 and exclude_7day=0
 --and exclude_trh=0
 --group by fiscal_yr

--  select fiscal_yr,sum(care_days) care_days
-- from #care_day_count
-- where age_exit=-99 and age_removal=-99 
-- and cd_cnty=0 and cd_race=0 and excludes_7day=0
-- and excludes_trh=0 and excludes_nondcfs=0
-- group by fiscal_yr
-- order by fiscal_yr	

--  select fiscal_yr,sum(care_days) care_days
-- from base.placement_care_days_mobility
-- where age_yrs_exit=-99 and age_yrs_removal=-99 
-- and county_cd=0 and cd_race=0 and exclude_7day=0
-- and exclude_trh=0 and exclude_nondcfs=0
-- group by fiscal_yr
-- order by fiscal_yr	


-- select fiscal_yr,sum(care_days) care_days 
-- from base.episode_care_days eps
--where eps.age_yrs_exit=-99 and eps.age_yrs_removal=-99 and eps.cd_race=0 and eps.county_cd=0 and eps.exclude_7day=0 and eps.exclude_nondcfs=0
--group by fiscal_yr
--order by fiscal_yr asc

		update  base.procedure_flow 
		set last_run_date=getdate()
		where ikey=20 