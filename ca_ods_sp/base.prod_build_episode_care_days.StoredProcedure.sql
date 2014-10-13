alter procedure base.prod_build_episode_care_days
as

			declare @fystart int= 2000;
			declare @fystop int= 2013;

			set nocount on

			if object_id('tempdb..#episodes') is not null
				drop table #episodes

			select  distinct
						 rp.child
						,rp.birthdate
						,rp.removal_dt
						, -- lessor date of 18th birthday is greater than cutoff_date use cutoff else use lessor date 18 bday or discharge date
								IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt)) discharg_frc_18
						,(select max(calendar_date) from CALENDAR_DIM where month(calendar_date)=month(rp.removal_dt)
								and CALENDAR_DATE between cd.fy_start_date and cd.fy_stop_date 
										and day(calendar_date)<=day(rp.removal_dt)
										having max(calendar_date) between removal_dt and (IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt))))	 anniv_removal_dt
						,sfy
						,cd.fy_start_date
						,cd.fy_stop_date
						,rp.discharge_dt orig_discharge_dt
						,cast(iif(datediff(dd,removal_dt,(IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt))))<8,1,0) as smallint) flag_7day
						,rp.id_removal_episode_fact 
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
						,isnull(rp.removal_county_cd,-99) [county_cd]
-- federal discharge date force

						,iif(nd.id_prsn is not null,1,0) fl_nondcfs_custody
						,cast(null as int)  as care_day_cnt_prior_anniv
						,cast(null as int)  as care_day_cnt_post_anniv
						,cast(null as int) as prior_year_service
						,cast(null as int) as post_year_service
			into #episodes
			from (select  distinct state_fiscal_yyyy sfy
										,min(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date)  fy_start_date
										,max(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date asc RANGE between current row and UNBOUNDED FOLLOWING)   fy_stop_date 
									from ca_ods.dbo.calendar_dim 
									where state_fiscal_yyyy between @fystart and @fystop
							) cd
			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			join base.rptPlacement rp 
					on removal_dt <= cd.fy_stop_date
					and  --discharge_dt force 18  >=fy_start_date
						IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt))  >=cd.fy_start_date	
			left join PEOPLE_DIM pd on pd.ID_PRSN=rp.child and pd.IS_CURRENT=1
			left join dbo.vw_nondcfs_combine_adjacent_segments nd on nd.id_prsn=rp.child
					and nd.cust_begin<=rp.removal_dt
					and rp.discharge_dt<=nd.cust_end
					--removal_dt less than federal discharge force 18
			where  removal_dt  <=IIF([18bday]<rp.discharge_dt and [18bday]<= cutoff_date
									, [18bday]
									,iif(cutoff_date<=rp.discharge_dt,cutoff_date,rp.discharge_dt)) 
									and age_at_removal_mos < (18*12)
			order by child, removal_dt ,sfy


			
update #episodes
set anniv_removal_dt = null
		,care_day_cnt_prior_anniv=datediff(dd,iif(fy_start_date>=removal_dt
		,fy_start_date,removal_Dt)
		,iif(fy_stop_date <=discharg_frc_18,fy_stop_date,discharg_frc_18))
		,prior_year_service=dbo.fnc_datediff_yrs(removal_dt,discharg_frc_18)
where  anniv_removal_dt is null;

delete from #episodes where anniv_removal_dt is null and care_day_cnt_prior_anniv =0 ;

--select  * from #episodes where anniv_removal_dt not between removal_dt and discharg_frc_18 or anniv_removal_dt is null 
-- select  * from #episodes where child=2502572 order by child,sfy;

update #episodes 
set care_day_cnt_prior_anniv=datediff(dd,iif(fy_start_date>=removal_dt,fy_start_date,removal_Dt),iif(removal_dt<>anniv_removal_dt,anniv_removal_dt,removal_dt))
		,prior_year_service=dbo.fnc_datediff_yrs(removal_dt,iif(removal_dt<>anniv_removal_dt,dateadd(dd,-1,anniv_removal_dt),removal_dt))
		,care_day_cnt_post_anniv=datediff(dd,anniv_removal_dt,iif(fy_stop_date>=discharg_frc_18,discharg_frc_18,fy_stop_date))
		,post_year_service=dbo.fnc_datediff_yrs(removal_dt,anniv_removal_dt)
where anniv_removal_dt is not null


if object_id('tempdb..#care_day_count') is not null
	drop table #care_day_count

create table #care_day_count(fiscal_yr int,years_in_care int
,age_removal int,age_exit int,cd_race int, cd_cnty int, excludes_7day int, excludes_nondcfs int,care_days int
)


-- INSERT  year 0 for removals in the fiscal year
insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_nondcfs
		,care_days
)
select  
		rp.sfy fiscal_yr
		,rp.prior_year_service years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, nd.excludes_nondcfs
  		, sum(rp.care_day_cnt_prior_anniv)    n_care_days
from  #episodes rp
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_yrs_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_yrs_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join prm_shortstay ss on ss.match_code=rp.flag_7day
	join prm_nondcfs_custody nd on nd.match_code=rp.fl_nondcfs_custody
group by 
		  rp.sfy 
		,rp.prior_year_service 
		, yrs.age_yr 
		, yrs_exit.age_yr 
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, nd.excludes_nondcfs

union all
select  
		rp.sfy fiscal_yr
		,rp.post_year_service years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, nd.excludes_nondcfs
  		, sum(rp.care_day_cnt_post_anniv)    n_care_days
from  #episodes rp
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_yrs_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_yrs_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join prm_shortstay ss on ss.match_code=rp.flag_7day
	join prm_nondcfs_custody nd on nd.match_code=rp.fl_nondcfs_custody
group by 
		  rp.sfy 
		,rp.post_year_service 
		, yrs.age_yr 
		, yrs_exit.age_yr 
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, nd.excludes_nondcfs
	
	
	update #care_day_count
	set years_in_care=10 
	where years_in_care>10

	truncate table base.[episode_care_days]
	 insert into base.[episode_care_days](fiscal_yr,age_yrs_removal,age_yrs_exit,county_cd
	 ,cd_race,years_in_care,exclude_7day,exclude_nondcfs,care_days)
	 select fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
	 ,excludes_7day,excludes_nondcfs,sum(care_days)
	  from #care_day_count
	  group by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
	 ,excludes_7day,excludes_nondcfs
	 having sum(care_days) is not null
	 order by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
	 ,excludes_7day,excludes_nondcfs

 --select * from base.placement_care_days_mobility
 --where age_exit=-99 and age_removal=-99 
 --and county_cd=0 and cd_race=0 and exclude_7day=0
 --and exclude_trh=0 order by fiscal_yr,age_removal,age_exit,county_cd,cd_race,years_in_care
 --,exclude_7day,exclude_trh

 	
--	select fy_start_date
--						,sum(DATEDIFF(d
--         , iif(  begin_date < fy_start_date, fy_start_date , begin_date  )
--         , iif( isnull(end_date , '9999-01-01')  > fy_stop_date , fy_stop_date 
--		 , end_date)
--           ) ) n_care_days
--		,sum(iif(plcmnt_seq > 1 and begin_date between fy_start_date and fy_stop_date,1,0)) placement_moves
--	from #dates cd
--			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
--			join ca_ods.base.rptPlacement_Events rp 
--					on removal_dt <= cd.fy_stop_date
--			and  iif(dbo.lessorDate( [18bday],rp.discharge_dt) > cutoff_date
--				, cutoff_date
--				,dbo.lessorDate( [18bday],rp.discharge_dt))  >=cd.fy_start_date
--			and rp.plc_begin<= cd.fy_stop_date
--			and coalesce(rp.end_date,'12/31/3999') >=cd.fy_start_date
--			--where dbo.fnc_datediff_yrs(birthdate,removal_dt) = 0
--		--	and rp.derived_county=17
--group by fy_start_date

 --select fiscal_yr,sum(care_days) care_days
 --from base.episode_care_days
 --where age_yrs_exit=-99 and age_yrs_removal=-99 
 --and county_cd=0 and cd_race=0 and exclude_7day=1
 --and exclude_nondcfs=0
 --group by fiscal_yr
 --order by fiscal_yr

 --select fiscal_yr,sum(care_days) care_days
 --from base.placement_care_days_mobility
 --where age_yrs_exit=-99 and age_yrs_removal=-99 
 --and county_cd=0 and cd_race=0 and exclude_7day=1
 --and exclude_trh=0 and exclude_nondcfs=0
 --group by fiscal_yr
 -- order by fiscal_yr
 	
		update  base.procedure_flow 
		set last_run_date=getdate()
		where ikey=21



