/******************************************************************************************************
Name:  M1774_Care_Day_Rate.sql
From: Condensed 1774/1566 Measurement Overview
Rate of care days per exit from out-of-home-care
Author: Jane Messerly
*********************************************************************************************************/


declare @state_fiscal_year datetime;
declare @max_state_fiscal_year datetime;




set @state_fiscal_year=(select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01');
set @max_state_fiscal_year=(select  dateadd(dd,-1,dateadd(yy,1,max(state_fiscal_year))) from calendar_dim  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
 where  dateadd(dd,-1,dateadd(yy,1,state_fiscal_year)) < cutoff_date );


 if object_ID('tempDB..#careday') is not null drop table #careday;
 create table #careday( start_date datetime,county_cd int,cnt_exits int,dur_days int,care_day_rate float)
 insert into #careday

 select  cd.STATE_FISCAL_YEAR 
				,cnty.cd_cnty
			,count( id_removal_episode_fact) as cnt_exits
			,sum(datediff(dd,eps.removal_dt,eps.federal_discharge_date)) + 1 [dur_days]
			,(sum(datediff(dd,eps.removal_dt,federal_discharge_date)) + 1 * 1.0000)/(count(*) * 1.0000) as [care day rate]
 from prtl.ooh_dcfs_eps eps
join CALENDAR_DIM cd on cd.CALENDAR_DATE=eps.Federal_Discharge_Date and cd.CALENDAR_DATE between @state_fiscal_year and @max_state_fiscal_year
join ref_last_dw_transfer dw on 1=1
join PEOPLE_DIM pd on pd.id_prsn=eps.id_prsn_child and pd.IS_CURRENT=1
join prm_cnty cnty on cnty.match_code=eps.exit_county_cd
where eps.Federal_Discharge_Date< cutoff_date  
group by cd.STATE_FISCAL_YEAR ,cnty.cd_cnty
			--, dbo.fnc_datediff_yrs(pd.DT_BIRTH,eps.Federal_Discharge_Date) 
			--,pd.cd_race_census 
			--,pd.census_hispanic_latino_origin_cd
			--,pk_gndr
	--		,exit_county_cd
--			,eps.max_bin_los_cd
order by state_fiscal_year ,cnty.cd_cnty

select * from #careday where county_cd=0 order by start_date,county_cd









