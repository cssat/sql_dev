
create view [dbo].[vw_qa_poc2ab_access_type]
as
select 'prtl_poc2ab' [tbl],tx_access_type,sum(cnt_opened) cnt_opened,sum(cnt_closed)  cnt_closed from prtl.prtl_poc2ab
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc2ab.filter_access_type
where qry_type=2
group by tx_access_type





