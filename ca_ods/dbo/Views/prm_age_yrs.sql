

create view [dbo].[prm_age_yrs] as 
select -99 age_yr,number-1  match_age_yr
from numbers where number between 1 and 19
union select -99,-99
union
select number-1,number-1
from numbers where number between 1 and 19


