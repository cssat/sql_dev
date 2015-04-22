

CREATE view  [dbo].[vw_qa_load_nulls_after_ca_load]
as 

select ca.tblname,ca.colname,ca.nullprcnt as [Current Load Null %],calast.nullprcnt as [Last Load Null %],(ca.nullprcnt-calast.nullprcnt)/((ca.nullprcnt+calast.nullprcnt)/2) * 100 as PRCNT_DIFF
from ca_null_analysis ca
join ca_null_analysis caLast on ca.tblname=calast.tblname and ca.colname=calast.colname
join (
	select * ,row_number() over (partition by tblname,colname order by tblname,colname,load_date desc) as sort_key
	from ca_null_analysis
	) q on q.sort_key=1 and q.tblname=ca.tblname and q.colname=ca.colname and q.load_date=ca.load_date
join (
	select * ,row_number() over (partition by tblname,colname order by tblname,colname,load_date desc) as sort_key
	from ca_null_analysis
	) q2 on q2.sort_key=2 and q2.tblname=caLast.tblname and q2.colname=caLast.colname and q2.load_date=caLast.load_date
where abs(ca.nullprcnt-calast.nullprcnt)>=1
and ca.load_date >=(select max(load_date)-2 from ca_null_analysis) 


