select max(last_enr_mnth) from ##myTbl


--select  dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') ,count(distinct ospi_person.researchID) as cnt
--from ospi_person
--join (
--select researchID,int_researchID from ospi_person
--except
--select researchID,int_researchID from ospi_person_dim) q on q.researchID=ospi_person.researchID
--group by  dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') 
--order by dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') desc


--select dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') 
--	,ospi_person.*
--from ospi_person
--join (
--select researchID,int_researchID from ospi_person
--except
--select researchID,int_researchID from ospi_person_dim) q on q.researchID=ospi_person.researchID
----group by  dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') 
--order by dbo.fnc_datediff_yrs(brth_dte,'2004-08-31') desc



insert into ospi_researchID (researchID)
select researchID from ospi_person
except
select researchID from ospi_researchID


