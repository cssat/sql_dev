
 
if object_ID(N'ospi.person_dim',N'U') is not null drop table ospi.person_dim 
create table ospi.person_dim (
researchID varchar(10)
,int_researchID int not null
,dob_yrmonth_date datetime
,dob_yrmonth int
,Gender char(10)
,FederalEthRaceID int
,PrimaryLanguageID int
,HomeLanguageID int
,fl_disability int
,fl_gifted int
,fl_bilingual int
,BirthCountryCode varchar(10)
,primary key(int_researchID))



 insert into ospi.person_dim  (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.MonthYearOfBirth,4) as int) * 10000 + cast(left(q.MonthYearOfBirth,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.MonthYearOfBirth,4) as int) * 100 + cast(left(q.MonthYearOfBirth,2)  as int)) as yrmonth_dob
	,q.Gender,q.FederalEthRaceRollupCode as FederalEthRace,q.PrimaryLanguageCode  as PrimaryLanguage
,q.LanguageSpokenatHomeCode,case when q.DisabilityFlag='Y' then 1 else 0 end
,case when q.GiftedFlag='Y' then 1 else 0 end
,case when q.BilingualFlag='Y' then 1 else 0 end
,q.BirthCountryCode
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,MonthYearOfBirth,BirthCountryCode,Gender,FederalEthRaceRollupCode
 ,PrimaryLanguageCode,LanguageSpokenatHomeCode,DisabilityFlag,GiftedFlag,BilingualFlag
 , row_number() over (partition by int_researchID order by int_researchID,primaryschoolflag desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_1011 
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 

insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.MonthYearOfBirth,4) as int) * 10000 + cast(left(q.MonthYearOfBirth,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.MonthYearOfBirth,4) as int) * 100 + cast(left(q.MonthYearOfBirth,2)  as int)) as yrmonth_dob
	,q.Gender,q.FederalEthRaceRollupCode as FederalEthRace,q.PrimaryLanguageCode  as PrimaryLanguage
,q.LanguageSpokenatHomeCode,case when q.DisabilityFlag='Y' then 1 else 0 end
,case when q.GiftedFlag='Y' then 1 else 0 end
,case when q.BilingualFlag='Y' then 1 else 0 end
,q.BirthCountryCode
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,MonthYearOfBirth,BirthCountryCode,Gender,FederalEthRaceRollupCode
 ,PrimaryLanguageCode,LanguageSpokenatHomeCode,DisabilityFlag,GiftedFlag,BilingualFlag
 , row_number() over (partition by int_researchID order by int_researchID,primaryschoolflag desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0910 
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;


---CRS Data------------------------------------------------------------------------------------------------------------
insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.dob,4) as int) * 10000 + cast(left(q.dob,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2)  as int)) as yrmonth_dob
	,q.Gender,q.RaceEthnicity as FederalEthRace,q.[Language]  as PrimaryLanguage
,q.HomeLanguage,q.Disability,q.Gifted,q.LEPBilingual as Bilingual,0
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,dob,cast(null as int) as BirthCountryCode,Gender,RaceEthnicity,Language,HomeLanguage,Disability,Gifted,LEPBilingual
 , row_number() over (partition by int_researchID order by int_researchID,yrmonth desc,primaryschool desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0809
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 go
 
  
insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.dob,4) as int) * 10000 + cast(left(q.dob,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2)  as int)) as yrmonth_dob
	,q.Gender,q.RaceEthnicity as FederalEthRace,q.[Language]  as PrimaryLanguage
,q.HomeLanguage,q.Disability,q.Gifted,q.LEPBilingual as Bilingual,0
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,dob,cast(null as int) as BirthCountryCode,Gender,RaceEthnicity,Language,HomeLanguage,Disability,Gifted,LEPBilingual
 , row_number() over (partition by int_researchID order by int_researchID,yrmonth desc,primaryschool desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0708
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 go
 
   
insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.dob,4) as int) * 10000 + cast(left(q.dob,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2)  as int)) as yrmonth_dob
	,q.Gender,q.RaceEthnicity as FederalEthRace,q.[Language]  as PrimaryLanguage
,q.HomeLanguage,q.Disability,q.Gifted,q.LEPBilingual as Bilingual,0
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,dob,cast(null as int) as BirthCountryCode,Gender,RaceEthnicity,Language,HomeLanguage,Disability,Gifted,LEPBilingual
 , row_number() over (partition by int_researchID order by int_researchID,yrmonth desc,primaryschool desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0607
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 go
   
insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.dob,4) as int) * 10000 + cast(left(q.dob,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2)  as int)) as yrmonth_dob
	,q.Gender,q.RaceEthnicity as FederalEthRace,q.[Language]  as PrimaryLanguage
,q.HomeLanguage,q.Disability,q.Gifted,q.LEPBilingual as Bilingual,0
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,dob,cast(null as int) as BirthCountryCode,Gender,RaceEthnicity,Language,HomeLanguage,Disability,Gifted,LEPBilingual
 , row_number() over (partition by int_researchID order by int_researchID,yrmonth desc,primaryschool desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0506
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 go
 
    
insert into ospi.person_dim (researchID,int_researchID,dob_yrmonth_date,dob_yrmonth
	,Gender,FederalEthRaceID,PrimaryLanguageID,HomeLanguageID,fl_disability,fl_gifted,fl_bilingual,BirthCountryCode)
select distinct  osp.researchID
	,osp.int_researchID
	,cast(cast(cast(right(q.dob,4) as int) * 10000 + cast(left(q.dob,2)  as int) * 100 + 1 as varchar(8)) as datetime) as DOB
	,(cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2)  as int)) as yrmonth_dob
	,q.Gender,q.RaceEthnicity as FederalEthRace,q.[Language]  as PrimaryLanguage
,q.HomeLanguage,q.Disability,q.Gifted,q.LEPBilingual as Bilingual,0
from ospi.researchID_dim osp
left join ospi.person_dim op on op.int_researchID=osp.int_researchID
join (
 select int_researchID,dob,cast(null as int) as BirthCountryCode,Gender,RaceEthnicity,Language,HomeLanguage,Disability,Gifted,LEPBilingual
 , row_number() over (partition by int_researchID order by int_researchID,yrmonth desc,primaryschool desc,dateenrolledinschool desc,schoolcode) as row_num
 from ospi.ospi_0405
 ) q on q.int_researchID=osp.int_researchID and row_num=1
 where op.int_researchID is  null;
 go
 
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0405 osp where osp.int_researchID=ospi.person_dim.int_researchID and Gifted=1
 and fl_gifted=0
 go
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0506 osp where osp.int_researchID=ospi.person_dim.int_researchID and Gifted=1
 and fl_gifted=0
 go 
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0607 osp where osp.int_researchID=ospi.person_dim.int_researchID and Gifted=1
 and fl_gifted=0
 go
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0708 osp where osp.int_researchID=ospi.person_dim.int_researchID and Gifted=1
 and fl_gifted=0
 go
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0809 osp where osp.int_researchID=ospi.person_dim.int_researchID and Gifted=1
 and fl_gifted=0
 go 
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_0910 osp where osp.int_researchID=ospi.person_dim.int_researchID and GiftedFlag='Y'
  and fl_gifted=0 
 go 
 update ospi.person_dim
 set fl_gifted=1
 from ospi.ospi_1011 osp where osp.int_researchID=ospi.person_dim.int_researchID and GiftedFlag='Y'
  and fl_gifted=0   
go  
----

update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0405 osp where osp.int_researchID=ospi.person_dim.int_researchID and Disability=1
 and fl_disability=0
 
 update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0506 osp where osp.int_researchID=ospi.person_dim.int_researchID and Disability=1
  and fl_disability=0
  
update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0607 osp where osp.int_researchID=ospi.person_dim.int_researchID and Disability=1
  and fl_disability=0  
 
 update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0708 osp where osp.int_researchID=ospi.person_dim.int_researchID and Disability=1
  and fl_disability=0  
  
   update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0809 osp where osp.int_researchID=ospi.person_dim.int_researchID and Disability=1
  and fl_disability=0  
  
  
 update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_0910 osp where osp.int_researchID=ospi.person_dim.int_researchID and DisabilityFlag='Y'
  and fl_disability=0 
  
 update ospi.person_dim
 set fl_disability=1
 from ospi.ospi_1011 osp where osp.int_researchID=ospi.person_dim.int_researchID and DisabilityFlag='Y'
  and fl_disability=0   
 

update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0405 osp
where osp.int_researchID=ospi.person_dim.int_researchID and LEPBilingual>0
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0506 osp
where osp.int_researchID=ospi.person_dim.int_researchID and isnull(LEPBilingual,0)>0
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0607 osp
where osp.int_researchID=ospi.person_dim.int_researchID and isnull(LEPBilingual,0)>0
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0708 osp
where osp.int_researchID=ospi.person_dim.int_researchID and isnull(LEPBilingual,0)>0
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0809 osp
where osp.int_researchID=ospi.person_dim.int_researchID and isnull(LEPBilingual,0)>0
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_0910 osp
where osp.int_researchID=ospi.person_dim.int_researchID and BilingualFlag='Y'
and fl_bilingual=0
go
update ospi.person_dim
set fl_bilingual = 1
from ospi.ospi_1011 osp
where osp.int_researchID=ospi.person_dim.int_researchID and BilingualFlag='Y'
and fl_bilingual=0



insert into ospi.person_dim
([researchID]
           ,[int_researchID]
           ,[dob_yrmonth_date]
           ,[dob_yrmonth]
           ,[Gender]
           ,[FederalEthRaceID]
           ,[PrimaryLanguageID]
           ,[HomeLanguageID]
           ,[fl_disability]
           ,[fl_gifted]
           ,[fl_bilingual]
           ,[BirthCountryCode])
select pd.researchID
	  ,opd.int_researchID
	  ,brth_dte
	  ,year(brth_dte) * 100 + month(brth_dte)
	  ,sex
	  ,case when racecat='White' then 5
			when racecat='African American' then 3
			when racecat='Native American' then 1
			when racecat='Hispanic' then 4
			when racecat='Asian/PI' then 2
			when racecat='Unknown' then 8
			else 8 end
		,0 
		,0
		,0
		,0
		,0
		,0
from ospi.ospi_person pd
join ospi.researchID_Dim opd on opd.researchID=pd.researchID
left join ospi.person_dim prsn on prsn.researchID=pd.researchID
where prsn.researchID is null;
	  
	  
select * from ospi.person_dim where int_researchID=985901
update ospi.person_dim
set dob_yrmonth_date='1991-01-01 00:00:00.000',dob_yrmonth=199101
where int_researchID=985901


update ospi.person_dim 
set dob_yrmonth_date='1987-08-01 00:00:00.000'
	,dob_yrmonth=198708
where int_researchID=1439889
