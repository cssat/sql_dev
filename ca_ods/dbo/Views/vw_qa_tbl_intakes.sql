﻿create view dbo.vw_qa_tbl_intakes 
as 
select id_case,intake_rank,id_intake_fact,rfrd_date,case_nxt_intake_dt,first_intake_date,latest_intake_date,nbr_intakes,nbr_cps_intakes,cnt_children_at_intake
 from base.tbl_intakes