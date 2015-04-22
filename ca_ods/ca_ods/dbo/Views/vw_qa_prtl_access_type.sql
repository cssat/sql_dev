

create view [dbo].[vw_qa_prtl_access_type]
as
select 'prtl_poc1ab' [tbl],tx_access_type,count(*)  row_count from prtl.prtl_poc1ab
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc1ab.filter_access_type
group by tx_access_type
union
select 'prtl_poc1ab_entries' [tbl],tx_access_type,count(*)  from prtl.prtl_poc1ab_entries
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc1ab_entries.filter_access_type
group by tx_access_type
union
select 'prtl_poc1ab_exits' [tbl],tx_access_type,count(*)  from prtl.prtl_poc1ab_exits
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc1ab_exits.filter_access_type
group by tx_access_type
union
select 'prtl_poc2ab' [tbl],tx_access_type,count(*)  from prtl.prtl_poc2ab
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc2ab.filter_access_type
group by tx_access_type
union
select 'prtl_poc3ab' [tbl],tx_access_type,count(*)  from prtl.prtl_poc3ab
join ref_filter_access_type acc on acc.filter_access_type=prtl_poc3ab.filter_access_type
group by tx_access_type
union
select 'prtl_outcomes' [tbl],tx_access_type,count(*)  from prtl.prtl_outcomes
join ref_filter_access_type acc on acc.filter_access_type=prtl_outcomes.filter_access_type
group by tx_access_type
union
select 'prtl_pbcp5' [tbl],tx_access_type,count(*)  from prtl.prtl_pbcp5
join ref_filter_access_type acc on acc.filter_access_type=prtl_pbcp5.filter_access_type
group by tx_access_type
union
select 'prtl_pbcs2' [tbl],tx_access_type,count(*)  from prtl.prtl_pbcs2
join ref_filter_access_type acc on acc.filter_access_type=prtl_pbcs2.filter_access_type
group by tx_access_type
union
select 'prtl_pbcs3' [tbl],tx_access_type,count(*)  from prtl.prtl_pbcs3
join ref_filter_access_type acc on acc.filter_access_type=prtl_pbcs3.filter_access_type
group by tx_access_type
union
select 'prtl_pbcw3' [tbl],tx_access_type,count(*)  from prtl.prtl_pbcw3
join ref_filter_access_type acc on acc.filter_access_type=prtl_pbcw3.filter_access_type
group by tx_access_type
union
select 'prtl_pbcw4' [tbl],tx_access_type,count(*)  from prtl.prtl_pbcw4
join ref_filter_access_type acc on acc.filter_access_type=prtl_pbcw4.filter_access_type
group by tx_access_type
