USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_child_episodes_after_ihs]    Script Date: 3/10/2014 1:21:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [base].[prod_update_rptPlacement_after_ihs] 
as



update tce
set  bin_ihs_svc_cd =3
from  base.rptPlacement tce

update tce
set  bin_ihs_svc_cd =1
from  base.rptPlacement tce
join base.tbl_ihs_episodes eps on  tce.id_intake_fact=eps.id_intake_fact and eps.days_from_rfrd_date <=90
and tbl_origin_cd in (2,3)


update tce
set  bin_ihs_svc_cd =2
from  base.rptPlacement tce
join base.tbl_ihs_episodes eps on  tce.id_intake_fact=eps.id_intake_fact  and eps.days_from_rfrd_date <=90
and tbl_origin_cd = 1 and bin_ihs_svc_cd <> 1

