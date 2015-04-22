

create view [dbo].[vw_tbl_last_update]
as
select * ,ROW_NUMBER() over (order by last_build_date desc) [sort_key]
from prtl.prtl_tables_last_update 

