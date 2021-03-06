--update bad district dates
update ospi.temp
set DateEnrolledInDistrict = DateEnrolledInSchool
where DateExitedFromDistrict < DateEnrolledInDistrict
and DateEnrolledInSchool < DateExitedFromDistrict
go
update ospi.temp
set DateEnrolledInDistrict = DateEnrolledInSchool
	,DateExitedFromDistrict=DateExitedFromSchool
where DateExitedFromDistrict < DateEnrolledInDistrict
go
--update same district with later school enrollment period and earlier DistrictExitDate 
-- both have same Distrcit Start Date
update curr
set curr.DateExitedFromDistrict=nxt.DateExitedFromDistrict
--select curr.*
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID = nxt.int_researchID
	and curr.row_num_asc+ 1 = nxt.row_num_asc
where nxt.DateExitedFromDistrict < curr.DateExitedFromDistrict
	and nxt.DistrictID=curr.DistrictID
	and curr.DateEnrolledInDistrict=nxt.DateEnrolledInDistrict
	and curr.DateEnrolledInDistrict <nxt.DateExitedFromDistrict



if object_ID('tempDB..##ss') is not null drop table ##ss

--update ospi.temp
--set fl_delete = 0

select cast(0 as int) as frst,cast(0 as int) as ss_row_num
,cast(null as datetime) as  new_district_enroll
,cast(null as datetime) as new_district_exit
,curr.*
into ##ss
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.districtid=nxt.districtid
	and (curr.DateEnrolledInDistrict <> nxt.DateEnrolledInDistrict
		or curr.DateExitedFromDistrict <> nxt.DateExitedFromDistrict)
union
select cast(0 as int) as frst,cast(0 as int) as ss_row_num
,cast(null as datetime) as  new_district_enroll
,cast(null as datetime) as new_district_exit
,nxt.*
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.districtid=nxt.districtid
	and (curr.DateEnrolledInDistrict <> nxt.DateEnrolledInDistrict
		or curr.DateExitedFromDistrict <> nxt.DateExitedFromDistrict)

--select * From ##ss order by int_researchID,row_num_asc

update my
set ss_row_num = q.ss_row_num
from ##SS my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID
								,DateEnrolledInSchool asc
								,DateExitedFromSchool asc) as ss_row_num
		from ##SS
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
			
			


update ##ss
set frst=1
where ss_row_num=1	

update nxt
set frst=1
from ##ss curr
join ##ss nxt 
	on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
where curr.districtid<>nxt.districtid

-- select int_researchID from ##SS where ss_row_num=27    835744
-- select * from ##SS where int_researchID=835744 order by int_researchID,ss_row_num

if object_ID('tempDB..#rowspan') is not null drop table #rowspan
select ##SS.int_researchID,districtID,ss_row_num as start_row_num,cast(null as int) as stop_row_num
,q.max_row
,cast(null as datetime) as district_enroll
,cast(null as datetime) as district_exit
into #rowspan
from ##SS
join (select int_researchID,max(ss_row_num) as max_row from ##SS group by int_researchID) q on q.int_researchID=##SS.int_researchID
where frst=1;

update rs
set stop_row_num = case when q.start_row_num is not null then q.start_row_num - 1 else rs.max_row end
from  #rowspan rs
outer apply (select top 1 *
			 from #rowspan mult
			 where mult.int_researchID=rs.int_researchID
				and mult.start_row_num > rs.start_row_num
			order by int_researchID,start_row_num) q

update rs
set district_enroll=dstr_enrl
	,district_exit=dstr_exit
from #rowspan rs
join (
	 select min(ss.DateEnrolledInDistrict) as dstr_enrl
	 ,max(case when ss.DateExitedFromDistrict = '12/31/3999' then ss.DateExitedFromSchool else ss.DateExitedFromDistrict end) as dstr_exit
	 ,rs.int_researchID,rs.districtID,rs.start_row_num,rs.stop_row_num,rs.max_row
	from #rowspan rs
	join ##SS ss on rs.int_researchID=ss.int_researchID 
			and rs.districtID=ss.DistrictID 
			and ss.ss_row_num between rs.start_row_num and rs.stop_row_num
	-- where rs.int_researchID=835744
	 group by rs.int_researchID,rs.districtID,rs.start_row_num,rs.stop_row_num,rs.max_row 
	) q on q.int_researchID=rs.int_researchID
		and q.districtID=rs.districtID
		and q.start_row_num=rs.start_row_num
		and q.max_row=rs.max_row
		and q.stop_row_num=rs.stop_row_num


update nxt
set district_enroll = dateadd(dd,1,curr.district_exit)
from #rowspan curr
join #rowspan nxt on curr.int_researchID=nxt.int_researchID 
and curr.stop_row_num + 1=nxt.start_row_num
and nxt.district_enroll < curr.district_exit
and dateadd(dd,1,curr.district_exit) < nxt.district_exit

update curr
set district_exit = dateadd(dd,-1,nxt.district_enroll)
from #rowspan curr
join #rowspan nxt on curr.int_researchID=nxt.int_researchID 
and curr.stop_row_num + 1=nxt.start_row_num
and curr.district_exit > nxt.district_enroll
and dateadd(dd,-1,nxt.district_enroll) > curr.District_enroll

update SS
set new_district_enroll=district_enroll
	,new_district_exit=district_exit
from #rowspan rs
join ##SS ss on rs.int_researchID=ss.int_researchID 
			and rs.districtID=ss.DistrictID 
			and ss.ss_row_num between rs.start_row_num and rs.stop_row_num

update osp
set DateEnrolledInDistrict=new_district_enroll
	,DateExitedFromDistrict=new_district_exit
from ospi.temp osp
join ##SS SS on ss.int_researchID=osp.int_researchID
	and osp.districtID=ss.districtID
	and osp.schoolcode=ss.schoolcode
	and osp.DateEnrolledInSchool=ss.DateEnrolledInSchool
	and osp.DateExitedFromSchool=ss.DateExitedFromSchool
	and osp.row_num_asc=ss.row_num_asc

update ospi.temp
set DateEnrolledInDistrict = DateEnrolledInSchool
where DateExitedFromDistrict < DateEnrolledInDistrict
and DateEnrolledInSchool < DateExitedFromDistrict

--select * from #rowspan where int_researchID=835744 order by int_researchID,start_row_num
--select * from ospi.temp where int_researchID=835744 order by int_researchID,row_num_asc


--select * from #rowspan order by int_researchID,start_row_num
if object_ID(N'ospi.temp',N'U') is not null drop table ospi.temp_thru_9
select * into ospi.temp_thru_9 from ospi.temp

--select * from ospi.temp where int_researchID= 153593 order by int_researchID,row_num_asc

