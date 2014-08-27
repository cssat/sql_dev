alter procedure base.prod_build_care_days_placement_mobility
as

declare @fystart int
declare @fystop int

set @fystart = 2010
set @fystop = 2013;

if object_id('tempdb..#dates') is not null
	drop table #dates

select distinct 
	id_calendar_dim
	,state_fiscal_yyyy
	,calendar_date 
into #dates
from ca_ods.dbo.calendar_dim 
where state_fiscal_yyyy between @fystart and @fystop;

create index idx_sfy on #dates(state_fiscal_yyyy)

if object_id('tempdb..#placements') is not null
	drop table #placements

select 
	rp.removal_dt
	,rp.birthdate
	,isnull(dbo.fnc_datediff_yrs(birthdate, removal_dt),-99)  age_removal
	,isnull(iif(rp.discharge_dt <= cutoff_date,iif( rp.[18bday] <= rp.discharge_dt
					,dbo.fnc_datediff_yrs(birthdate,rp.[18bday])
					,dbo.fnc_datediff_yrs(birthdate,rp.discharge_dt)),-99),-99) age_exit
	,isnull(pd.cd_race_census,7) cd_race_census
	,isnull(pd.census_Hispanic_Latino_Origin_cd,5) census_Hispanic_Latino_Origin_cd
	,isnull(rp.derived_county,-99) [county_cd]
	,convert(int, convert(varchar, rp.removal_dt, 112)) removal_dt_int
	,convert
	(
	int
	,convert(int
		,convert(
		varchar
			,case 
				when iif(rp.[18bday] < rp.discharge_dt
					,rp.[18bday]
					,rp.discharge_dt) = '9999-12-31'
				then datefromparts(@fystop, 06, 30)
				else iif(rp.[18bday] < rp.discharge_dt
					,rp.[18bday]
					,rp.discharge_dt)
			end
			,112
		)
		)
		) discharg_frc_18_int
	,convert(int, convert(varchar, dateadd(yy, 17, rp.birthdate), 112)) bday17_int
	,rp.id_removal_episode_fact 
	,rp.id_placement_fact
	,rp.plcmnt_seq
	,convert(int, convert(varchar, rp.begin_date, 112)) plc_begin_int
	,convert(int, convert(varchar, rp.end_date, 112)) plc_end_int
	,iif(rp.plcmnt_seq >= 11
		,11
		,rp.plcmnt_seq) ord 
	,child
	,begin_date 
	,isnull(rpx.berk_tx_plcm_setng, 'Other') current_setng
	,lead(isnull(rpx.berk_tx_plcm_setng, 'Other'), 1,0) 
		over (partition by child order by begin_date) next_setng
	,tx_end_rsn
	,lag(tx_end_rsn) over (partition by id_removal_episode_fact order by begin_date,end_date) prior_end_rsn
	,cast(iif(datediff(dd,removal_dt,discharge_dt)<8,1,0) as smallint) flag_7day
	,cast(0 as smallint) flag_trh
into #placements
from ca_ods.base.rptPlacement_Events rp
join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
	left join dbo.ref_plcm_setting_xwalk rpx
		on rp.cd_plcm_setng = rpx.cd_plcm_setng
left join PEOPLE_DIM pd on pd.ID_PRSN=rp.child and pd.IS_CURRENT=1
where rp.cd_epsd_type <> 5 
order by child, begin_date 

update #placements
set flag_trh=1
 from #placements where NOT(tx_end_rsn = 'Changed Caregiver'  and charindex('Trial Return Home',prior_end_rsn)>0)
and charindex('Trial Return Home',prior_end_rsn)>0



CREATE NONCLUSTERED INDEX  idx_temp_pp
ON #placements ([removal_dt_int],[discharg_frc_18_int],[plc_begin_int],[plc_end_int])
INCLUDE ([removal_dt],id_removal_episode_fact)

CREATE NONCLUSTERED INDEX idx_plcmnt_seq
ON #placements ([plcmnt_seq])
INCLUDE ([removal_dt],[id_placement_fact],[plc_begin_int],[tx_end_rsn],[prior_end_rsn])

CREATE NONCLUSTERED INDEX idx_seq_begin_incl
ON #placements ([plc_begin_int],[plcmnt_seq])
INCLUDE ([removal_dt],[id_placement_fact],[tx_end_rsn],[prior_end_rsn])




if OBJECT_ID('tempDB..#trh') is not null drop table #trh
if OBJECT_ID('tempDB..#shortstay') is not null drop table #shortstay
create table #trh(match_code smallint,excludes_trh smallint)
create table #shortstay(match_code smallint,excludes_7day smallint)

insert into #trh
select 0 match_code,1 excludes_trh
 union
select 0,0
union
select 1,0

insert into #shortstay
select 0 match_code,1 excludes_7day
 union
select 0,0
union
select 1,0




if object_id('tempdb..#care_day_count') is not null
	drop table #care_day_count

create table #care_day_count(fiscal_yr int,care_days int,years_in_care int
,age_removal int,age_exit int,cd_race int, cd_cnty int, excludes_7day int,excludes_trh int)



insert into #care_day_count
select  
	sfy fiscal_yr
	,sum(DATEDIFF(d
         , iif(  convert(datetime,convert(varchar,plc_begin_int),112)  < fy_start_date, fy_start_date ,  convert(datetime,convert(varchar,plc_begin_int),112)  )
         , iif( isnull(convert(datetime,convert(varchar,plc_end_int),112) , '9999-01-01')  > fy_stop_date , cd.fy_stop_date , isnull(convert(datetime,convert(varchar,plc_end_int),112) , '9999-01-01')  )
           ) + 1 ) n_care_days
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date) >= 10
		,10
		,dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date)) years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
from (select distinct state_fiscal_yyyy sfy
			,min(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM) fy_start_date_int
			,max(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM asc RANGE between current row and UNBOUNDED FOLLOWING) fy_stop_date_int
			,min(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date)  fy_start_date
			,max(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date asc RANGE between current row and UNBOUNDED FOLLOWING)   fy_stop_date 
	--		,CALENDAR_DATE
			from #dates  cd
			) cd
	 join #placements rp
		on rp.removal_dt_int <= cd.fy_stop_date_int
			and rp.discharg_frc_18_int >=cd.fy_start_date_int
			and rp.plc_begin_int<= cd.fy_stop_date_int
			and rp.plc_end_int >=cd.fy_start_date_int
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join #shortstay ss on ss.match_code=rp.flag_7day
	join #trh trh on trh.match_code=rp.flag_trh
group by 
	sfy
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date) >= 10
		, 10
		, dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date))
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
order by 
	  fiscal_yr
	, years_in_care
	, age_removal
	, eth.cd_race
	, cnty.cd_cnty
	, ss.excludes_7day
	, trh.excludes_trh

	--select * 
 ----select fiscal_yr,sum(care_days)
 --from #care_day_count 
 --where age_removal=-99 
 --and age_exit=-99
	-- and cd_race=0 
	-- and cd_cnty=0
	-- and excludes_7day=0
	-- and excludes_trh=0
 ----group by fiscal_yr	
 --order by fiscal_yr,years_in_care

 truncate table base.care_day_count
 insert into base.care_day_count(fiscal_yr,age_removal,age_exit,county_cd
 ,cd_race,years_in_care,exclude_7day,exclude_trh,care_days)
 select fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care,excludes_7day,excludes_trh,care_days from #care_day_count

	if object_id('tempdb..#mobility_count') is not null
	drop table #mobility_count
	
select 
	sfy fiscal_yr
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date) >= 10
		,10
		,dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date)) years_in_care
		,yrs.age_yr  age_removal
		,yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
		,count(distinct rp.id_placement_fact) placement_moves
		,sum(iif(rp.current_setng =  'Kin',1,0)) kin_cnt
		,sum(iif(rp.current_setng= 'Foster',1,0)) foster_cnt
		,sum(iif(rp.current_setng= 'Group',1,0)) group_cnt
into #mobility_count
from (select distinct state_fiscal_yyyy sfy
			,min(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM) fy_start_date_int
			,max(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM asc RANGE between current row and UNBOUNDED FOLLOWING) fy_stop_date_int
			,min(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date)  fy_start_date
			,max(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date asc 
			RANGE between current row and UNBOUNDED FOLLOWING)   fy_stop_date 
	--		,CALENDAR_DATE
			from #dates  cd
			) cd
	 join #placements rp
		on rp.plc_begin_int between fy_start_date_int and fy_stop_date_int
			and rp.plcmnt_seq > 1
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_removal
		join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join #shortstay ss on ss.match_code=rp.flag_7day
	join #trh trh on trh.match_code=rp.flag_trh
group by 
	sfy
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date) >= 10
		,10
		,dbo.fnc_datediff_yrs(rp.removal_dt, cd.fy_stop_date))
		,yrs.age_yr 
		,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
order by 
	fiscal_yr
	,years_in_care
	,yrs_exit.age_yr
	, age_removal
	, eth.cd_race
	, cnty.cd_cnty
	,ss.excludes_7day
	,trh.excludes_trh
		
	--select  fiscal_yr,sum(placement_moves) from #mobility_count		
	--where age_removal=-99 and age_exit=-99 and cd_race=0 and cd_cnty=0 and excludes_7day=0 and excludes_trh=0
	--group by fiscal_yr

	--select * 
	--from #mobility_count
	--order by fiscal_yr,years_in_care,age_removal,age_exit,cd_race,cd_cnty,excludes_7day,excludes_trh

	--select count(distinct id_placement_fact)
	--from #placements rp
	--	where  rp.plc_begin_int between 20120701 and 20130630
	--		and rp.plcmnt_seq > 1 
	--		and removal_dt_int between 20100701 and 20110630
--   select * into base.placement_mobility_counts from #mobility_count
truncate table base.placement_mobility_counts
INSERT INTO [base].[placement_mobility_counts]
           ([fiscal_yr]
           ,[years_in_care]
           ,[age_removal]
           ,[age_exit]
           ,[cd_race]
           ,[cd_cnty]
           ,[excludes_7day]
           ,[excludes_trh]
           ,[placement_moves]
           ,[kin_cnt]
           ,[foster_cnt]
           ,[group_cnt])


select [fiscal_yr]
           ,[years_in_care]
           ,[age_removal]
           ,[age_exit]
           ,[cd_race]
           ,[cd_cnty]
           ,[excludes_7day]
           ,[excludes_trh]
           ,[placement_moves]
           ,[kin_cnt]
           ,[foster_cnt]
           ,[group_cnt]
 from #mobility_count