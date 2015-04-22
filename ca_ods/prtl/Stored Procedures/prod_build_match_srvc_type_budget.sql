
CREATE procedure [prtl].[prod_build_match_srvc_type_budget] as 

if object_ID(N'dbo.ref_match_srvc_type_budget',N'U') is not null drop table dbo.ref_match_srvc_type_budget

create table dbo.ref_match_srvc_type_budget(filter_service_budget int,[fl_budget_C12] int,[fl_budget_C14] int,[fl_budget_C15] int
,[fl_budget_C16] int,[fl_budget_C18] int,[fl_budget_C19] int,[fl_uncat_svc] int,[cd_budget_poc_frc] int
,id_service_budget int
,primary key(filter_service_budget,cd_budget_poc_frc))

insert into dbo.ref_match_srvc_type_budget(filter_service_budget ,[fl_budget_C12] ,[fl_budget_C14] ,[fl_budget_C15] 
,[fl_budget_C16] ,[fl_budget_C18] ,[fl_budget_C19] ,[fl_uncat_svc],cd_budget_poc_frc)
SELECT distinct       power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
     
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      ,[fl_budget_C15]
      ,[fl_budget_C16]
      ,[fl_budget_C18]
      ,[fl_budget_C19]
      ,[fl_uncat_svc]
	  ,0

  FROM [base].[episode_payment_services]
  union 
  select distinct
   power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					--(fl_budget_C15 * 10000) + 
					--(fl_budget_C16 * 1000) + 
					--(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
     
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      --,[fl_budget_C15]
      --,[fl_budget_C16]
      --,[fl_budget_C18]
	  ,0 fl_budget_C15
	  ,0 fl_budget_C16
	  ,0 fl_budget_C18
      ,[fl_budget_C19]
      ,[fl_uncat_svc],0
	  from base.tbl_ihs_episodes
	  union
	  select distinct 
	  filter_service_budget_todate
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      ,[fl_budget_C15]
      ,[fl_budget_C16]
      ,[fl_budget_C18]
      ,[fl_budget_C19]
      ,[fl_uncat_svc],0
	  from base.placement_payment_services
	  where filter_service_budget_todate is not null;


	  if object_id('tempDB..#temp') is not null drop table #temp
	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  into #temp
	  from dbo.ref_match_srvc_type_budget ref
	  join (select 12 as cd_budget_poc_frc  ,1 as fl_budget_C12) q
	  on q.fl_budget_C12=ref.fl_budget_C12
	  UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	  join (select 14 as  cd_budget_poc_frc ,1 as fl_budget_C14) q on q.fl_budget_C14=ref.fl_budget_C14
	  UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	join (select 15 as cd_budget_poc_frc ,1 as fl_budget_C15) q on q.fl_budget_C15=ref.fl_budget_C15
	UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	join (select 16 as cd_budget_poc_frc ,1 as fl_budget_C16) q on ref.fl_budget_C16=q.fl_budget_C16
		UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	join (select 18 as cd_budget_poc_frc,1 as fl_budget_C18) q on ref.fl_budget_C18=q.fl_budget_C18
			UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	join (select 19 as cd_budget_poc_frc,1 as fl_budget_C19) q on q.fl_budget_C19=ref.fl_budget_C19
			UNION
	  	  select ref.filter_service_budget
			,ref.fl_budget_C12
			,ref.fl_budget_C14
			,ref.fl_budget_C15
			,ref.fl_budget_C16
			,ref.fl_budget_C18
			,ref.fl_budget_C19
			,ref.fl_uncat_svc
			,q.cd_budget_poc_frc
	  from dbo.ref_match_srvc_type_budget ref
	join (select 99 as cd_budget_poc_frc,1 as fl_uncat_svc) q on q.fl_uncat_svc=ref.fl_uncat_svc

	truncate table dbo.ref_match_srvc_type_budget

	insert into dbo.ref_match_srvc_type_budget(filter_service_budget ,[fl_budget_C12] ,[fl_budget_C14] ,[fl_budget_C15] 
,[fl_budget_C16] ,[fl_budget_C18] ,[fl_budget_C19] ,[fl_uncat_svc],cd_budget_poc_frc)

select filter_service_budget ,[fl_budget_C12] ,[fl_budget_C14] ,[fl_budget_C15] 
,[fl_budget_C16] ,[fl_budget_C18] ,[fl_budget_C19] ,[fl_uncat_svc],cd_budget_poc_frc  from #temp


insert into dbo.ref_match_srvc_type_budget (filter_service_budget ,[fl_budget_C12] ,[fl_budget_C14] ,[fl_budget_C15] 
,[fl_budget_C16] ,[fl_budget_C18] ,[fl_budget_C19] ,[fl_uncat_svc],cd_budget_poc_frc)
select power(10.0,7),
0 ,0 ,0 
,0 ,0 ,0 ,0,0;


	update ref
	set id_service_budget=  id_srvc
	from dbo.ref_match_srvc_type_budget ref
	join (select s.filter_service_budget,s.cd_budget_poc_frc
			,row_number() over (order by filter_service_budget ) as id_srvc
				  from dbo.ref_match_srvc_type_budget s) s on s.filter_service_budget=ref.filter_service_budget
				 


update prtl.prtl_tables_last_update
set last_build_date=getdate(),row_count=(select count(*) from dbo.ref_match_srvc_type_budget)
where tbl_id=50;

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_match_srvc_type_budget'

--select * from prtl.prtl_tables_last_update
