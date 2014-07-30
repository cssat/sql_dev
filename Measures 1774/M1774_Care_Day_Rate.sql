/******************************************************************************************************
Name:  M1774_Care_Day_Rate.sql
From: Condensed 1774/1566 Measurement Overview
Rate of care days per exit from out-of-home-care
Author: Jane Messerly
*********************************************************************************************************/



create view prtl.CareDays_per_Exits_SFY
as
 select  cd.STATE_FISCAL_YEAR 
			, cnty.cd_cnty
			, count( id_removal_episode_fact) as cnt_exits
			, sum(datediff(dd,eps.removal_dt,eps.federal_discharge_date)) + 1 [dur_days]
			,(sum(datediff(dd,eps.removal_dt,federal_discharge_date)) + 1 * 1.0000)/(count(*) * 1.0000) as [care day rate]
			, ROW_NUMBER() over (order by cnty.cd_cnty,cd.State_Fiscal_Year) row_num
 from prtl.ooh_dcfs_eps eps
join CALENDAR_DIM cd on cd.CALENDAR_DATE=eps.Federal_Discharge_Date and cd.CALENDAR_DATE 
		between (select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01')
					 and (select  dateadd(dd,-1,dateadd(yy,1,max(state_fiscal_year))) from calendar_dim  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
								where  dateadd(dd,-1,dateadd(yy,1,state_fiscal_year)) < cutoff_date )
join ref_last_dw_transfer dw on 1=1
join prm_cnty cnty on cnty.match_code=eps.exit_county_cd
where eps.Federal_Discharge_Date< cutoff_date  
group by cd.STATE_FISCAL_YEAR ,cnty.cd_cnty










