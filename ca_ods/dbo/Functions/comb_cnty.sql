
CREATE function [dbo].[comb_cnty] ()
Returns @Table table
(prm varchar(100))
as 
begin


insert into @Table
select  ltrim(cast(a.county_cd as varchar(2))) + ',' + ltrim(cast(b.county_cd as varchar(2)))
from (select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day) desc) a
,(select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day)desc) b
where b.county_cd>a.county_cd 
union all
select  ltrim(cast(a.county_cd as varchar(2))) + ',' + ltrim(cast(b.county_cd as varchar(2)))+ ',0'
from (select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day) desc) a
,(select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day)desc) b
where b.county_cd>a.county_cd 
union all
select  ltrim(cast(a.county_cd as varchar(2))) + ',' + ltrim(cast(b.county_cd as varchar(2)))+ ',' + ltrim(cast(c.county_cd as varchar(2)))
from (select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day) desc) a
,(select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day)desc) b
,(select top 15 county as county_cd,sum(tot_first_day) as tot_first_day
	 from PRTL_POC1AB 
	 where county between 1 and 39 group by county order by sum(tot_first_day)desc) c
where b.county_cd>a.county_cd 
	and c.county_cd > b.county_cd

RETURN
end