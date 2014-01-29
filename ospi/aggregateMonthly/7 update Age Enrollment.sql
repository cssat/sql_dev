update osp
set approx_age_enroll_start = datediff(yy,dob_yrmonth_date,DateEnrolledInSchool)
	, approx_age_enroll_end = datediff(yy,dob_yrmonth_date,case when isnull(DateExitedFromSchool,'12/31/3999') = '12/31/3999' then '2011-10-28' else DateExitedFromSchool end)
	, enrollment_duration = datediff(dd,DateEnrolledInSchool,case when isnull(DateExitedFromSchool,'12/31/3999') = '12/31/3999' then '2011-10-28' else DateExitedFromSchool end) + 1
	, MonthYearBirth=dob_yrmonth
from ospi.temp osp
join ospi.person_dim opd on opd.int_researchID=osp.int_researchID

go
with CTE_grades (int_researchID,int_min_grade,int_max_grade)
as (select int_researchID,min(int_min_grade) as int_min_grade,max(int_max_grade) as int_max_grade 
	from ospi.temp
	group by int_researchID)

update osp
set int_startGradeLevel=cte.int_min_grade
	,int_stopGradeLevel=cte.int_max_grade
	,startGradeLevel=case when cte.int_min_grade > 0 then cast(cte.int_min_grade as char(2))
							when cte.int_min_grade=0 then 'K2'
							when cte.int_min_grade=-1 then 'K1'
							when cte.int_min_grade=-2 then 'PK' end
	,stopGradeLevel=case when cte.int_max_grade > 0 then cast(cte.int_max_grade as char(2))
							when cte.int_max_grade=0 then 'K2'
							when cte.int_max_grade=-1 then 'K1'
							when cte.int_max_grade=-2 then 'PK' end
from  ospi.temp osp
join CTE_grades cte on cte.int_researchID=osp.int_researchID

if object_ID('tempDB..#baddob') is not null drop table #baddob
select distinct int_researchID,MonthYearBirth,cast(null as int ) as NEW_DOB into #baddob from ospi.temp where approx_age_enroll_start < 0  
or approx_age_enroll_start > 21

update bad
set NEW_DOB=cast(right(osp.MonthYearOfBirth,4) as int) * 100 + cast(left(osp.MonthYearOfBirth,2) as int)
from  #baddob bad
join ospi.ospi_1011 osp on osp.int_researchID = bad.int_researchID
where osp.MonthYearOfBirth is not null
	and osp.MonthYearOfBirth <> '0'
	and bad.MonthYearBirth<> cast(right(osp.MonthYearOfBirth,4) as int) * 100 + cast(left(osp.MonthYearOfBirth,2) as int)
	
update bad
set NEW_DOB=cast(right(osp.MonthYearOfBirth,4) as int) * 100 + cast(left(osp.MonthYearOfBirth,2) as int)
from  #baddob bad
join ospi.ospi_0910 osp on osp.int_researchID = bad.int_researchID
where osp.MonthYearOfBirth is not null
	and osp.MonthYearOfBirth <> '0'
	and bad.MonthYearBirth<> cast(right(osp.MonthYearOfBirth,4) as int) * 100 + cast(left(osp.MonthYearOfBirth,2) as int)
	
		

update bad
set NEW_DOB=cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
from  #baddob bad
join ospi.ospi_0809 osp on osp.int_researchID = bad.int_researchID
where osp.dob is not null
	and osp.dob <> '0'
	and bad.MonthYearBirth<> cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
	
update bad
set NEW_DOB=cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
from  #baddob bad
join ospi.ospi_0708 osp on osp.int_researchID = bad.int_researchID
where osp.dob is not null
	and osp.dob <> '0'
	and bad.MonthYearBirth<> cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)	
	and new_dob is null
	
update bad
set NEW_DOB=cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
from  #baddob bad
join ospi.ospi_0607 osp on osp.int_researchID = bad.int_researchID
where osp.dob is not null
	and osp.dob <> '0'
	and bad.MonthYearBirth<> cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)	
	and new_dob is null	

update bad
set NEW_DOB=cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
from  #baddob bad
join ospi.ospi_0506 osp on osp.int_researchID = bad.int_researchID
where osp.dob is not null
	and osp.dob <> '0'
	and bad.MonthYearBirth<> cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)	
	and new_dob is null	
		
update bad
set NEW_DOB=cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)
from  #baddob bad
join ospi.ospi_0405 osp on osp.int_researchID = bad.int_researchID
where osp.dob is not null
	and osp.dob <> '0'
	and bad.MonthYearBirth<> cast(right(osp.dob,4) as int) * 100 + cast(left(osp.dob,2) as int)	
	and new_dob is null		

update bad
set NEW_DOB=year(brth_dte) * 100 + month(brth_dte)
from  #baddob bad
join ospi.person_dim pd on pd.int_researchID=bad.int_researchID
join ospi.ospi_person osp on osp.researchID = pd.researchID
where osp.brth_dte is not null
	and bad.MonthYearBirth<> year(brth_dte) * 100 + month(brth_dte)
	and new_dob is null	
	
	
update ospi.person_dim
set dob_yrmonth_date = convert(datetime,cast(new_DOB as char(6)) + '01')
from #baddob bad where bad.int_researchID=ospi.person_dim.int_researchID
and bad.new_dob is not null;

update osp
set approx_age_enroll_start = datediff(yy,dob_yrmonth_date,DateEnrolledInSchool)
	, approx_age_enroll_end = datediff(yy,dob_yrmonth_date,case when isnull(DateExitedFromSchool,'12/31/3999') = '12/31/3999' then '2011-10-28' else DateExitedFromSchool end)
	, enrollment_duration = datediff(dd,DateEnrolledInSchool,case when isnull(DateExitedFromSchool,'12/31/3999') = '12/31/3999' then '2011-10-28' else DateExitedFromSchool end) + 1
	, MonthYearBirth=dob_yrmonth
from ospi.temp osp
join ospi.person_dim opd on opd.int_researchID=osp.int_researchID

delete
 from ospi.temp where 
 approx_age_enroll_start < 0


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


select * into ospi.temp_thru_7 from ospi.temp