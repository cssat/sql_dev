USE [CA_ODS]
GO
/**
truncate table prtl.cache_poc3ab_aggr;
truncate table prtl.cache_poc3ab_params;
truncate table prtl.cache_qry_param_poc3ab;
**/

DECLARE	@return_value int

EXEC	 [prtl].[sp_cache_poc3ab_counts]
		@date = N'2009-01-01,2013-07-01',
		@cd_sib_age_grp = N'0',
		@race_cd = N'0',
		@cd_office = N'0',
		@bin_ihs_svc_cd = N'0',
		@cd_reporter_type = N'0',
		@filter_access_type = N'0',
		@filter_allegation = N'0',
		@filter_finding = N'0',
		@filter_service_category = N'0',
		@filter_service_budget = N'0'

SELECT	'Return Value' = @return_value

GO



select p3.start_date,p3.date_type,sum(p3.cnt_start_date) as frst_day,sum(p3.cnt_opened) as opened,sum(p3.cnt_closed) as closed
,q.cnt_start_date,q.cnt_opened,q.cnt_closed
from prtl.prtl_poc3ab  p3
join (select start_date,date_type,cnt_start_date,cnt_opened,cnt_closed
 from prtl.cache_poc3ab_aggr  where qry_id=1 and start_date 
 between '2009-01-01' and '2013-07-01' and qry_type=2 --  order by date_type,start_date
) q on q.start_date=p3.start_date and q.date_type=p3.date_type
where qry_type=2 
and  p3.start_date between '2009-01-01' and '2013-07-01'
group by p3.date_type,p3.start_date,
q.cnt_start_date,q.cnt_opened,q.cnt_closed
-- having sum(p3.cnt_start_date) <> q.cnt_start_date or sum(p3.cnt_opened)<>q.cnt_opened  or sum(p3.cnt_closed)  <> q.cnt_closed
order  by  p3.date_type,p3.start_date


select prtl_poc3ab.start_date,sum(cnt_opened) as cnt_opened,old_tot_opened
from CA_ODS.prtl.prtl_poc3ab 
join 
(select period_start,sum(prtl_poc3.tot_opened) as old_tot_opened from dbCoreAdministrativeTables.dbo.prtl_poc3 
where qry_type=2 and date_type=0
and period_start >='2009-01-01'
group by period_start
) q on q.period_start=prtl_poc3ab.start_date
where qry_type=2 and date_type=0
and prtl_poc3ab.start_date >='2009-01-01'
group by prtl_poc3ab.start_date,old_tot_opened
order by prtl_poc3ab.[start_date]



--select * From ##age
--select * from prtl.prtl_poc3ab where cd_sib_age_group is null or cd_sib_age_group not between 1 and 4

--select * from prtl.prtl_poc3ab p3 left join 
--(select distinct cd_origin,match_code from ##eth) q on q.match_code=p3.cd_race_census
--	and q.cd_origin=p3.census_hispanic_latino_origin_cd
--	where q.match_code is null

--	select distinct * from ##ihs
--	select distinct bin_ihs_svc_cd from prtl.prtl_poc3ab

--	select distinct * from ##rpt
--	select distinct cd_Reporter_type from prtl.prtl_poc3ab

--	select distinct filter_access_type from prtl.prtl_poc3ab
--	select * from ##access_type

--	select distinct filter_allegation from prtl.prtl_poc3ab where filter_allegation
--	not in (	select distinct match_code from ##algtn)

--		select distinct filter_finding from prtl.prtl_poc3ab where filter_finding
--	not in (	select distinct match_code from ##find)

--	select distinct p3.filter_service_type from prtl.prtl_poc3ab p3
--	where p3.filter_service_type not in (select match_code from ##srvc)

--	select distinct p3.filter_budget_type from prtl.prtl_poc3ab p3
--	where p3.filter_budget_type not in (select match_code from ##budg)

--select p3.* from prtl.prtl_poc3ab p3 where p3.cd_office not in (select match_code from ##ofc)

--select distinct int_match_param_key from prtl.prtl_poc3ab
--where int_match_param_key not in (select int_match_param_key from ref_match_intake_parameters where fl_in_tbl_intakes=1)

--select distinct id_intake_fact from  prtl.prtl_poc3ab where int_match_param_key in
--(1382760,
--1212717,
--1134760,
--1482756,
--1242737,
--1342710,
--1112760)

--se

--select * from ref_match_intake_parameters where int_match_param_key in (1382760,
--1212717,
--1134760,
--1482756,
--1242737,
--1342710,
--1112760)




--select distinct *  from ##ihs
--select distinct bin_ihs_svc_cd from prtl.prtl_poc3ab
--select * from ##ofc 
--select * from prtl.prtl_poc3ab poc3 where poc3.cd_office not in (select match_code from ##ofc) or poc3.cd_office is null
--select * from ##budg
--select distinct filter_budget_type from prtl.prtl_poc3ab poc3  where filter_budget_type not in (select match_code from ##budg)

--select count(*) from base.tbl_ihs_episodes where tbl_ihs_episodes.ihs_begin_date between '2009-01-01' and '2009-01-31'
--select sum(cnt_opened) from prtl.prtl_poc3ab where start_date= '2009-01-01' and date_type=0 and qry_type=2;

select * from prtl.cache_poc3ab_params;
select count(*) from prtl.cache_poc3ab_aggr

update prtl.cache_poc3ab_params
set filter_finding='1,2'
where qry_id=22

