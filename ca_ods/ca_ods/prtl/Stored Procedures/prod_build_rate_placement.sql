--  exec prtl.prod_build_rate_placement 

CREATE procedure prtl.prod_build_rate_placement 
as
	

alter table prtl.rate_placement  NOCHECK CONSTRAINT ALL;

--  The numerator is Households with at least 1 removal this month 
--           with no children already in episode this month
--- The denominator is referrals this month that are screened-in
truncate table prtl.rate_placement


insert into prtl.rate_placement(date_type,qry_type,cohort_date,county_cd,entry_point,cnt_households_w_plcm,cnt_referrals_u18,rate_placement)
select  0 "date_type"
			, 2 "qry_type"
			, mnth.start_date
			, refC.county_cd
			, ep.entry_point
			,  coalesce(cnt_hh_plcm ,0)cnt_hh_plcm
			,  coalesce(scrn.cnt_referrals,0) cnt_ref
			, IIF(scrn.cnt_referrals>0, cnt_hh_plcm/(scrn.cnt_referrals*1.0000) * 1000 ,null) "placement_rate"
from (select distinct [Month] start_date from Calendar_dim ,ref_last_dw_transfer where [Month] between '2000-01-01' and dateadd(mm,-1,cutoff_date)) mnth
join ref_lookup_county refC on refC.county_cd between 0 and 39
join (select distinct entry_point from prm_entry_point) ep on ep.entry_point=ep.entry_point
left join (
				select distinct 0 "date_type",2 "qry_type",[month] start_date
						,count(distinct plc.id_case) cnt_hh_plcm
						,cnty.cd_cnty   "county_cd"
						,ep.entry_point
				From  base.rptPlacement plc
						left join prtl.vw_referrals_grp ref on ref.id_intake_fact=plc.id_intake_fact
						join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
						join calendar_dim cd on cd.CALENDAR_DATE=plc.removal_dt and cd.MONTH between '2000-01-01'  and  dateadd(mm,-1,cutoff_date)
						join prm_cnty cnty on cnty.match_code=plc.removal_county_cd
						--if the entry point is null meaning the id_intake_fact is null in rptPlacement -- default it as a CPS referrals
						 join prm_entry_point ep on ep.match_code=coalesce(ref.entry_point,1)
				--age in months is less than 18 * 12
				where  IIF(day([month]) < day(plc.birthdate) and plc.birthdate<[month]
												, datediff(mm,plc.birthdate,[month]) - 1
												,datediff(mm,plc.birthdate,[month])) < (18*12)
				-- exclude nondcfs episodes
				and not exists(select * from [dbo].[vw_nondcfs_combine_adjacent_segments]  nd where nd.id_prsn=plc.child
								and removal_dt between nd.cust_begin and nd.cust_end
								and iif([18bday]<discharge_dt and discharge_dt <=cutoff_date , [18bday] ,discharge_dt) between nd.cust_begin and nd.cust_end)
				and not exists(--exclude families with a child already in care
								select id_case from base.rptPlacement sic where sic.id_case=plc.id_case
									and sic.removal_dt < cd.[MONTH] 
									and --discharge date greater than removal date
										 iif(sic.[18bday]<sic.discharge_dt 
													and sic.discharge_dt <=dw.cutoff_date , sic.[18bday] ,sic.discharge_dt)> plc.removal_dt)
					group by cd.MONTH,cnty.cd_cnty,ep.entry_point
				) plc on plc.start_date=mnth.start_date and plc.county_cd=refC.county_cd and ep.entry_point=plc.entry_point
left join prtl.rate_referrals_scrn_in scrn on 
						 scrn.start_date=mnth.start_date
						and  scrn.county_cd=refC.county_cd
						and  scrn.entry_point= ep.entry_point
order by refC.county_cd,mnth.start_date,ep.entry_point

alter table prtl.rate_placement  CHECK CONSTRAINT ALL;			

--   select * from prtl.rate_placement where entry_point=0 and county_cd=0
--  select * from prtl.rate_referrals_scrn_in where entry_point=0 and county_cd=0


