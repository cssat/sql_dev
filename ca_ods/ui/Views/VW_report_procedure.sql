
create  view [UI].[VW_report_procedure] as 
select R.*,sp.*
from ui.report_stored_procedure rsp
join ui.report R on r.report_id=rsp.report_id
join ui.stored_procedure sp on rsp.sp_id=sp.sp_id