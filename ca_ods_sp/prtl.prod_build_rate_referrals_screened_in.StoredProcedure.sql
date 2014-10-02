--   exec prtl.prod_build_rate_referrals_screened_in

alter  procedure prtl.prod_build_rate_referrals_screened_in as 
declare @startdate datetime=getdate()
alter table prtl.rate_referrals_screened_in NOCHECK CONSTRAINT ALL
truncate table prtl.rate_referrals_scrn_in
insert into prtl.rate_referrals_scrn_in(qry_type,date_type,start_date,county_cd,cnt_referrals)
SELECT tce.qry_type
		,tce.[date_type]
		,cohort_entry_date as [start_date]
		,cnty.cd_cnty county_cd
		,count( distinct intake_grouper) as cnt_ref
from [prtl].[vw_referrals_grp] tce
join prm_cnty cnty on cnty.match_code=intake_county_cd
--				  join prtl.rate_referrals ref on ref.county_cd=cnty.cd_cnty and ref.start_date=cohort_entry_date
where  tce.cd_access_type in (1,4) and fl_dlr=0
and hh_with_children_under_18=1 
and tce.cd_final_decision=1
group by   tce.qry_type
		,tce.[date_type]
		,cohort_entry_date 
		,cnty.cd_cnty 
--					  ,ref.cnt_referrals
order by cnty.cd_cnty,cohort_entry_date

update scr
set scr.tot_pop=ref.cnt_referrals,
referral_rate=IIF(ref.cnt_referrals>0,scr.cnt_referrals /(ref.cnt_referrals * 1.0000) *1000 ,null)
from prtl.rate_referrals_scrn_in scr
join prtl.rate_referrals ref on ref.start_date=scr.start_date and ref.county_cd=scr.county_cd

								  


alter table prtl.rate_referrals_screened_in CHECK CONSTRAINT ALL

declare @enddate datetime=getdate();
update tbl
set tbl.last_build_date=getdate()
		,tbl.row_count=(select count(*) from prtl.rate_referrals_scrn_in)
		,tbl.load_time_mins=dbo.fnc_datediff_mis(@startdate,@enddate)
from prtl.prtl_tables_last_update tbl
where tbl_id=56



