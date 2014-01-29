USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_tbl_intake_grouper]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [base].[prod_build_tbl_intake_grouper]
as
set nocount on
if object_ID('tempDB..#intakes') is not null drop table #intakes
select row_number() over (partition by id_case order by id_case,rfrd_date,intake_rank,id_intake_fact) as case_sort
,row_number() over ( order by id_case,rfrd_date,intake_rank,id_intake_fact) as intake_grouper
,0 as fl_group_with_prior,*
into #intakes
from base.tbl_intakes where cd_final_decision = 1 
order by id_case,inv_ass_start,intake_rank


update intk
set fl_group_with_prior=1
from #intakes intk
join #intakes pr_intk on pr_intk.case_sort=intk.case_sort-1 and intk.id_case=pr_intk.id_case
where intk.inv_ass_start between pr_intk.inv_ass_start and pr_intk.inv_ass_stop
	and intk.inv_ass_stop between pr_intk.inv_ass_start and pr_intk.inv_ass_stop

	


--alter table #intakes
--alter column case_sort bigint not null
--go
--alter table #intakes
--add primary key(id_case,case_sort)
--go

declare @rowcount int
set @rowcount=10
while @rowcount > 0
begin
	update intk
	set intk.intake_grouper=pr_intk.intake_grouper
	from #intakes intk
	join #intakes pr_intk on intk.id_case=pr_intk.id_case and pr_intk.case_sort=  intk.case_sort-1 and intk.fl_group_with_prior=1
	where intk.intake_grouper <> pr_intk.intake_grouper and pr_intk.fl_ooh_after_this_referral <> 1
	
	set @rowcount=@@ROWCOUNT
end 



if object_ID(N'base.tbl_intake_grouper',N'U') is not null drop table base.tbl_intake_grouper
create table base.tbl_intake_grouper (intake_grouper int not null,id_case int not null, id_intake_fact int not null
,primary key(id_intake_fact))

create index idx_intake_grouper on base.tbl_intake_grouper(id_intake_fact) include(intake_grouper,id_case)
insert into base.tbl_intake_grouper(id_intake_fact,intake_grouper,id_case)
select distinct id_intake_fact,intake_grouper,id_case 
from #intakes



GO
