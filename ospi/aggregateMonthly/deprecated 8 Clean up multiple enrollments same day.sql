-- select * from ospi.temp where fl_multiple_primaryschool=1
update osp
set DateEnrolledInSchool = convert(datetime,cast(frst_enr_mnth  as char(6))  + '01',112)
--select int_researchID,DateEnrolledInSchool,convert(datetime,cast(frst_enr_mnth as char(6)) + '01',112) as new_date,DateExitedFromSchool
from ospi.temp osp
where fl_multiple_primaryschool=1
and year(DateEnrolledInSchool) * 100 + month(DateEnrolledInSchool) <> frst_enr_mnth
and convert(datetime,cast(frst_enr_mnth as char(6)) + '01',112) < DateExitedFromSchool

update ospi.temp
set fl_multiple_primaryschool = 0
go
update my
set fl_multiple_primaryschool = 1
from ospi.temp  my
join (					  
	select int_researchID,DateEnrolledInSchool,count(*) as cnt
	 from ospi.temp 
	 group by int_researchID,DateEnrolledInSchool
	 having count(*) > 1 ) q on q.int_researchID=my.int_researchID
		and my.DateEnrolledInSchool=q.DateEnrolledInSchool
go
update my
set row_num_asc = q.row_num_asc
	,row_num_desc=q.row_num_desc
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go	




update nxt
set DateEnrolledInSchool = dateadd(dd,1,curr.DateExitedFromSchool	)
--select dateadd(dd,1,curr.DateExitedFromSchool	) as new_exit_date,nxt.*
--into #temp
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID = nxt.int_researchID
	and curr.row_num_asc+ 1 = nxt.row_num_asc
where curr.fl_multiple_primaryschool = 1
	and nxt.fl_multiple_primaryschool = 1
	and curr.DateEnrolledInSchool=nxt.DateEnrolledInSchool
	and curr.last_enr_mnth < nxt.last_enr_mnth
	and nxt.DateExitedFromSchool > curr.DateExitedFromSchool	
go
--select t.* from #temp	t
--join [ospi].[temp] tmp on tmp.int_researchID=t.int_researchID
--and tmp.[DistrictID]=t.[DistrictID]
--and tmp.[SchoolCode]=t.[SchoolCode]
--and tmp.DateExitedFromSchool=t.DateExitedFromSchool
--and tmp.DateEnrolledInSchool=t.new_exit_date

--select *  from ospi.temp where int_researchID in (711989,1213596) order by int_researchID,row_num_asc


update ospi.temp
set fl_multiple_primaryschool = 0 where fl_multiple_primaryschool=1
go
update my
set fl_multiple_primaryschool = 1
from ospi.temp  my
join (					  
	select int_researchID,DateEnrolledInSchool,count(*) as cnt
	 from ospi.temp 
	 group by int_researchID,DateEnrolledInSchool
	 having count(*) > 1 ) q on q.int_researchID=my.int_researchID
		and my.DateEnrolledInSchool=q.DateEnrolledInSchool
go
update my
set row_num_asc = q.row_num_asc
	
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go

update my
set row_num_desc=q.row_num_desc
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go

select curr.*
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID = nxt.int_researchID
	and curr.row_num_asc+ 1 = nxt.row_num_asc
where curr.fl_multiple_primaryschool = 1
	and nxt.fl_multiple_primaryschool = 1
	and curr.DateEnrolledInSchool=nxt.DateEnrolledInSchool
	and curr.last_enr_mnth < nxt.last_enr_mnth
union
select nxt.*	
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID = nxt.int_researchID
	and curr.row_num_asc+ 1 = nxt.row_num_asc
where curr.fl_multiple_primaryschool = 1
	and nxt.fl_multiple_primaryschool = 1
	and curr.DateEnrolledInSchool=nxt.DateEnrolledInSchool
	and curr.last_enr_mnth < nxt.last_enr_mnth		