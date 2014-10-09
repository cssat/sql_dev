USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_placement_care_days_mobility]    Script Date: 10/8/2014 2:31:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec [base].[prod_build_placement_care_days_mobility]
ALTER  procedure [base].[prod_build_placement_care_days_mobility]
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
	,cast(iif(datediff(dd,removal_dt,discharge_dt)<8,1,0) as smallint) flag_7day
	,cast(0 as smallint) flag_trh
	,(select max(calendar_date) from CALENDAR_DIM where month(calendar_date)=month(rp.removal_dt)
			and CALENDAR_DATE between cd.fy_start_date and cd.fy_stop_date and day(calendar_date)<=day(rp.removal_dt))	 anniv_removal_dt
	,sfy
	,cd.fy_start_date
	,cd.fy_stop_date
into #placements
from (select  distinct state_fiscal_yyyy sfy
							,min(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM) fy_start_date_int
							,max(ID_CALENDAR_DIM)  over (partition by state_fiscal_yyyy order by ID_CALENDAR_DIM asc RANGE between current row and UNBOUNDED FOLLOWING) fy_stop_date_int
							,min(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date)  fy_start_date
							,max(calendar_date)  over (partition by state_fiscal_yyyy order by calendar_date asc RANGE between current row and UNBOUNDED FOLLOWING)   fy_stop_date 
						from ca_ods.dbo.calendar_dim 
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
where rp.cd_epsd_type <> 5  
-- and placement begin date less than cutoff_date
and begin_date <= 
				iif( -- lessor of 18th birthday , discharge date,cutoff_date
						IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt) > cutoff_date
							, cutoff_date
							, IIF([18bday]<rp.discharge_dt,[18bday],rp.discharge_dt)) 
order by child, begin_date ,sfy


update #placements
set flag_trh=1
 from #placements 
 where NOT(tx_end_rsn = 'Changed Caregiver'  and charindex('Trial Return Home',prior_end_rsn)>0)
				and charindex('Trial Return Home',prior_end_rsn)>0




CREATE NONCLUSTERED INDEX idx_plcmnt_seq
ON #placements ([plcmnt_seq])
INCLUDE ([removal_dt],[id_placement_fact],[plc_begin],[tx_end_rsn],[prior_end_rsn])

CREATE NONCLUSTERED INDEX idx_seq_begin_incl
ON #placements ([plc_begin],[plcmnt_seq])
INCLUDE ([removal_dt],[id_placement_fact],[tx_end_rsn],[prior_end_rsn])


if object_id('tempdb..#care_day_count') is not null
	drop table #care_day_count

create table #care_day_count(fiscal_yr int,care_days int,years_in_care int
,age_removal int,age_exit int,cd_race int, cd_cnty int, excludes_7day int,excludes_trh int
,placement_moves int,kin_cnt int,foster_cnt int,group_cnt int)


-- INSERT  year 0 for removals in the fiscal year
insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
		rp.sfy fiscal_yr
		,0 years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
  		, sum(DATEDIFF(d
			, iif(  plc_begin  < fy_start_date, fy_start_date , plc_begin )
			 , iif( isnull(plc_end , '9999-01-01')  > fy_stop_date , fy_stop_date , isnull(plc_end , '9999-01-01')  )
           ) ) n_care_days
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
where rp.removal_dt between fy_start_date and fy_stop_date
and rp.plc_begin between fy_start_date and fy_stop_date
group by 
		  rp.sfy
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh

--		 rp.removal_dt not between fy_start_date and fy_stop_date
--and rp.anniv_removal_dt not between rp.plc_begin and rp.plc_end


	-- QA
	--select * from #care_day_count where  age_exit=-99 and age_removal=-99
	--and cd_cnty=0 and cd_race=0
	--and excludes_7day=0 and excludes_trh=0
	--order by fiscal_yr

-- INSERT those placements not including removal anniversary date
insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
	rp.sfy fiscal_yr
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, iif(plc_begin<fy_start_date,fy_start_date,plc_begin)) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, iif(plc_begin<fy_start_date,fy_start_date,plc_begin))) years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
  		, sum(DATEDIFF(d
         , iif(  plc_begin  < fy_start_date, fy_start_date ,  plc_begin )
         , iif( isnull(plc_end , '9999-01-01')  > fy_stop_date 
				, fy_stop_date 
				, isnull(plc_end, '9999-01-01')  )
           ) ) n_care_days
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
where rp.removal_dt not between fy_start_date and fy_stop_date
and rp.anniv_removal_dt not between rp.plc_begin and rp.plc_end
group by 
	rp.sfy
,iif(dbo.fnc_datediff_yrs(rp.removal_dt, iif(plc_begin<fy_start_date,fy_start_date,plc_begin)) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, iif(plc_begin<fy_start_date,fy_start_date,plc_begin)))
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh


	--QA
	--	select * from #care_day_count where  age_exit=-99 and age_removal=-99
	--and cd_cnty=0 and cd_race=0
	--and excludes_7day=0 and excludes_trh=0
	--order by fiscal_yr,years_in_care

--  INSERT those placements  including removal anniversary date  from fiscal_year_start to anniversary_date -1
insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
	rp.sfy fiscal_yr
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, dateadd(d,-1,anniv_removal_dt)) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, dateadd(d,-1,anniv_removal_dt))) years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
  		, sum(DATEDIFF(d
         , iif(  plc_begin < fy_start_date, fy_start_date , plc_begin  )
         , dateadd(dd,-1,anniv_removal_dt)
           ) +1 ) n_care_days
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
where rp.removal_dt not between fy_start_date and fy_stop_date
and rp.anniv_removal_dt  between rp.plc_begin and rp.plc_end
group by 
	rp.sfy
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt, dateadd(d,-1,anniv_removal_dt)) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, dateadd(d,-1,anniv_removal_dt))) 
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh


--QA	
--select * from #care_day_count where  age_exit=-99 and age_removal=-99
--	and cd_cnty=0 and cd_race=0
--	and excludes_7day=0 and excludes_trh=0
--	order by fiscal_yr,years_in_care

--	select fiscal_yr,sum(care_days) care_days
--	from #care_day_count where  age_exit=-99 and age_removal=-99
--	and cd_cnty=0 and cd_race=0
--	and excludes_7day=0 and excludes_trh=0
--	group by fiscal_yr
--	order by fiscal_yr

--since we split episodes by anniversary date to get both service years we do not want to count placements again -- use 0
--  those placements  including removal anniversary date  from anniversary_date  to lessor of placement end date,state fiscal year
insert into #care_day_count (fiscal_yr
		,years_in_care,age_removal,age_exit,cd_race,cd_cnty
		,excludes_7day,excludes_trh
		,care_days
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt)
select  
	rp.sfy fiscal_yr
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt,anniv_removal_dt) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, anniv_removal_dt)) years_in_care
		, yrs.age_yr age_removal
		, yrs_exit.age_yr age_exit
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh
  		, sum(DATEDIFF(d
					 , anniv_removal_dt
					 , iif( isnull(plc_end , '9999-01-01')  > fy_stop_date , fy_stop_date , isnull(plc_end , '9999-01-01')  )
		          ) ) n_care_days
		,0
		,0
		,0
		,0
from  #placements rp
	join prm_age_yrs yrs on yrs.match_age_yr=rp.age_yrs_removal
	join prm_age_yrs yrs_exit on yrs_exit.match_age_yr=rp.age_yrs_exit
	join prm_eth_census eth on eth.match_code=rp.cd_race_census and eth.cd_origin=rp.census_Hispanic_Latino_Origin_cd
	join prm_cnty cnty on cnty.match_code=rp.county_cd
	join prm_shortstay ss on ss.match_code=rp.flag_7day
	join prm_trh trh on trh.match_code=rp.flag_trh
where rp.removal_dt not between fy_start_date and fy_stop_date
and rp.anniv_removal_dt  between rp.plc_begin and rp.plc_end
group by 
	rp.sfy
	,iif(dbo.fnc_datediff_yrs(rp.removal_dt,anniv_removal_dt) >= 10
					,10
					,dbo.fnc_datediff_yrs(rp.removal_dt, anniv_removal_dt))
		, yrs.age_yr 
		 ,yrs_exit.age_yr
		, eth.cd_race
		, cnty.cd_cnty
		, ss.excludes_7day
		, trh.excludes_trh



--select * from #care_day_count where  age_exit=-99 and age_removal=-99
--	and cd_cnty=0 and cd_race=0
--	and excludes_7day=0 and excludes_trh=0
--	order by fiscal_yr,years_in_care

	--select fiscal_yr,sum(care_days) care_days,sum(placement_moves) placement_moves
	--,sum(kin_cnt)kin_cnt
	--,sum(foster_cnt)foster_cnt
	--,sum(group_cnt)group_cnt
	--from #care_day_count where  age_exit=-99 and age_removal=-99
	--and cd_cnty=0 and cd_race=0
	--and excludes_7day=0 and excludes_trh=0
	--group by fiscal_yr
	--order by fiscal_yr

	
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




truncate table base.placement_care_days_mobility
 insert into base.placement_care_days_mobility(fiscal_yr,age_yrs_removal,age_yrs_exit,county_cd
 ,cd_race,years_in_care,exclude_7day,exclude_trh,care_days,placement_moves,kin_cnt,foster_cnt,group_cnt)
 select fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh,sum(care_days),sum(placement_moves),sum(kin_cnt),sum(foster_cnt),sum(group_cnt)
  from #care_day_count
  group by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh
 order by fiscal_yr,age_removal,age_exit,cd_cnty,cd_race,years_in_care
 ,excludes_7day,excludes_trh

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

	
		update  base.procedure_flow 
		set last_run_date=getdate()
		where ikey=20 