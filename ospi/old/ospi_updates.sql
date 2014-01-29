update ospi_0607 set 	IsApprovedPrivateSchoolStudentAttendingPartTime=0 
where rtrim(ltrim(IsApprovedPrivateSchoolStudentAttendingPartTime))=''

update ospi_0607 
set 	IsHomeBasedStudentAttendingPartTime=0 
where rtrim(ltrim(IsHomeBasedStudentAttendingPartTime))=''


update ospi_0607 
set 	IsForeignExchangeStudent=case when rtrim(ltrim(IsForeignExchangeStudent))='' then 0 else IsForeignExchangeStudent end
where isnumeric(IsForeignExchangeStudent)=0

update ospi_0607 
set Migrant=case when rtrim(ltrim(Migrant))='' then 0 else migrant end
where isnumeric(Migrant)=0
			

update ospi_0607 
set Gifted=0 
where isnumeric(Gifted)=0

update ospi_0607 
set Section504=0 
where isnumeric(Section504)=0


update ospi_0607 
set 	IsForeignExchangeStudent=0 
where isnumeric(IsForeignExchangeStudent)=0


update ospi_0607 
set 	Homeless=0 
where isnumeric(Homeless)=0

update ospi_0607 
set SpecialEd=0 
where isnumeric(SpecialEd)=0

update ospi_0607 
set FREligibility =0 
where isnumeric(FREligibility)=0


