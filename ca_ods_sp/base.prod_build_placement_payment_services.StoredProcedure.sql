USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_placement_payment_services]    Script Date: 3/29/2014 3:24:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	ALTER procedure [base].[prod_build_placement_payment_services] (@permission_key datetime)
	as

		if @permission_key=(select cutoff_date from dbo.ref_Last_DW_Transfer)
		begin

			if OBJECT_ID(N'base.placement_payment_services',N'U') is not null drop table  base.placement_payment_services
			CREATE TABLE [base].[placement_payment_services](
				[id_prsn_child] [int] NULL,
				begin_date [datetime] NOT NULL,
				end_date [datetime] NULL,
				[id_removal_episode_fact] [int] NOT NULL,
				[id_placement_fact] [int] NOT NULL,
				[id_provider_dim_caregiver]  [int] NOT NULL,
				[id_case] [int] NULL,
				[dur_days] [int] NULL,
				[fl_close] [smallint] NULL,
				[id_payment_fact] [int] NULL,
				[svc_begin_date] [date] NULL,
				[svc_end_date] [date] NULL,
				[pymt_cd_srvc] [int] NULL,
				[pymt_tx_srvc] [varchar](200) NULL,
				[fl_primary_srvc] [int] NULL,
				[srvc_match] [int] NULL,
				[prov_match] [int] NULL,
				[rate][decimal](18,6) NULL,
				[unit][decimal](18,6) NULL,
				[total_paid] [decimal](18, 2) NULL,
				[cd_budget_poc_frc] int ,
				[tx_budget_poc_frc] varchar(200),
				[cd_subctgry_poc_frc] int,
				[tx_subctgry_poc_frc] varchar(200),
				[fl_plc_svc] int,
			--	tx_program_index varchar(10),
				[fl_dup_payment] [int] NULL,
				plcm_pymnt_sort_asc int,
				filter_service_category_todate int,
				filter_budget_category_todate int
			) ON [PRIMARY];

if object_id('tempDB..#pay') is not null drop table #pay;
  select id_payment_fact
  ,dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) [srvc_begin_dt]
 , dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)[srvc_end_dt]
					, pf.ID_SERVICE_TYPE_DIM [id_service_type_dim]
					,pf.id_case
					,pf.ID_PROVIDER_DIM_SERVICE [id_provider_dim_service]
					,pf.ID_PRSN_CHILD [id_prsn_child]
					,pf.AM_RATE [am_rate]
					,pf.AM_UNITS [am_units]
					,pf.AM_TOTAL_PAID [am_total_paid]
			into #pay
			from payment_fact pf
			where exists (select * from base.rptPlacement 
			where rptPlacement.child=pf.ID_PRSN_CHILD)
			and pf.AM_TOTAL_PAID > 0
			and  (dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) >='2000-01-01'
				or isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >'2000-01-01' )
				
create index idx_pay on #pay(id_prsn_child,[srvc_begin_dt],[srvc_end_dt]) 
	include(id_provider_dim_service,id_service_type_dim);
	/*******  STEP 1   match person provider cd_srvc dates  ******************************************************/
		insert into base.placement_payment_services
		select  
					  tcps.child [id_prsn_child]
					  , tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch + 1 [dur_days]
					, case when end_date < getdate() then 1 else 0 end [fl_close]
					, pf.id_payment_fact
					,  [srvc_begin_dt]
					,  [srvc_end_dt]
					, std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 1 as srvc_match
					, 1 as prv_match
					, am_rate
					, am_units
					, am_total_paid  
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0 [fl_dup_payment]
					,0
					,0
					,0
			from base.rptPlacement_Events tcps 
			-- FIRST JOIN ON TBL_CHILD_PLACEMENT_SETTINGS CD_SRVC
			 join #pay pf on pf.id_prsn_child=tcps.child 
			 and pf.id_provider_dim_service=tcps.id_provider_dim_caregiver
			 and [srvc_begin_dt] <= isnull(tcps.end_date,'12/31/3999') 
				and isnull([srvc_end_dt] ,'12/31/3999') >=  tcps.begin_date 
				AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
				AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)							
				join dbo.service_type_dim std 
					on std.ID_SERVICE_TYPE_DIM=pf.id_service_type_dim
						  and tcps.cd_srvc=std.cd_srvc
				join dbo.ref_service_category pps 
					on pps.cd_srvc=std.cd_srvc 
					and pps.fl_plc_svc=1
				where not exists( select *
					from base.tbl_ihs_services ihs 
					where  ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT )
				group by  tcps.child 
					  , tcps.begin_date 
					, tcps.end_date 
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch
					,pf.id_payment_fact
					,pf.srvc_begin_dt
					,pf.srvc_end_dt
					,std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					,am_rate
					, am_units
					, am_total_paid  
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc;

			update PP 
			set [fl_dup_payment] = 1
			from base.placement_payment_services PP
			 join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact
						,abs(datediff(dd,begin_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact
					, pps.id_prsn_child,pps.id_removal_episode_fact
					,pps.begin_date,pps.end_date,pps.pymt_cd_srvc
					,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date
					 from  base.placement_payment_services pps
					 join (
							select id_payment_fact,count(*) as cnt
							  from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1;
		


	
		
			delete PP from base.placement_payment_services PP where fl_dup_payment=1
			
			
		
	/*******  STEP 2   		--now match on child dates provider but NOT service  ********************************/

		insert into base.placement_payment_services
		select  distinct
					  tcps.child
					  , tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch + 1 [dur_days]
					, case when end_date < getdate() then 1 else 0 end [fl_close]
					, pf.id_payment_fact
					, [srvc_begin_dt]
					, [srvc_end_dt]
					, std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 1 as prv_match
					, am_rate
					, am_units
					, am_total_paid  
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0
					,0
					,0
					,0
			from base.rptPlacement_Events tcps 
			 join #pay pf on pf.ID_PRSN_CHILD=tcps.child 
				and pf.AM_TOTAL_PAID>0
				and pf.id_provider_dim_service=tcps.id_provider_dim_caregiver
				and [srvc_begin_dt] <= isnull(tcps.end_date,'12/31/3999') 
				and isnull([srvc_end_dt] ,'12/31/3999') >=  tcps.begin_date 
				AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
				AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)	
			join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
			join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc  and pps.fl_plc_svc=1
			 where  not exists( select *
							from base.tbl_ihs_services ihs 
							where  ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT )
				and not exists(select * 
				from base.placement_payment_services plc 
				where plc.id_payment_fact=pf.id_payment_fact );

		update PP 
			set [fl_dup_payment] = 1
			from base.placement_payment_services PP
			 join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact
						,abs(datediff(dd,begin_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact
					, pps.id_prsn_child,pps.id_removal_episode_fact
					,pps.begin_date,pps.end_date,pps.pymt_cd_srvc
					,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date
					 from  base.placement_payment_services pps
					 join (
							select id_payment_fact,count(*) as cnt
							  from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
			
	
		
	
			delete PP from base.placement_payment_services PP where fl_dup_payment=1
	

	/*******  STEP 3   		last match child & dates no provider no service ***************************************/

			insert into base.placement_payment_services
			select distinct 
					  tcps.child
					, tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch + 1 [dur_days]
					, case when end_date < getdate() then 1 else 0 end [fl_close]
					, pf.id_payment_fact
					, [srvc_begin_dt]
					, [srvc_end_dt]
					, std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 0 as prv_match
					, am_rate
					, am_units
					, am_total_paid  
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0
					,0
					,0
					,0
			from base.rptPlacement_Events tcps 
			 join #pay  pf on pf.ID_PRSN_CHILD=tcps.child
			 and pf.AM_TOTAL_PAID > 0 
				and [srvc_begin_dt] <= isnull(tcps.end_date,'12/31/3999') 
				and isnull([srvc_end_dt] ,'12/31/3999') >=  tcps.begin_date 
				AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
				AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)	
			  join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
			  left join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
		 where  not exists( select *
									from base.tbl_ihs_services ihs 
									where  ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT )
						and not exists(select * 
						from base.placement_payment_services plc 
						where plc.id_payment_fact=pf.id_payment_fact );
	
		update PP 
			set [fl_dup_payment] = 1
			from base.placement_payment_services PP
			 join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact
						,abs(datediff(dd,begin_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact
					, pps.id_prsn_child,pps.id_removal_episode_fact
					,pps.begin_date,pps.end_date,pps.pymt_cd_srvc
					,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date
					 from  base.placement_payment_services pps
					 join (
							select id_payment_fact,count(*) as cnt
							  from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1;
			

			 delete PP from base.placement_payment_services PP where fl_dup_payment=1
	

			-- get case payments

				if object_ID('tempDB..#casepay') is not null drop table #casepay
				CREATE TABLE #casepay(
				[id_prsn_child] [int] NULL,
				[begin_date] [datetime] NOT NULL,
				[end_date] [datetime] NULL,
				[id_removal_episode_fact] [int] NOT NULL,
				[id_placement_fact] [int] NOT NULL,
				[id_provider_dim_caregiver]  [int] NOT NULL,
				[id_case] [int] NULL,
				[dur_days] [int] NULL,
				[fl_close] [smallint] NULL,
				[id_payment_fact] [int] NULL,
				[svc_begin_date] [date] NULL,
				[svc_end_date] [date] NULL,
				[pymt_cd_srvc] [int] NULL,
				[pymt_tx_srvc] [varchar](200) NULL,
				[fl_primary_srvc] [int] NULL,
				[srvc_match] [int] NULL,
				[prov_match] [int] NULL,
				[rate][decimal](18,6) NULL,
				[unit][decimal](18,6) NULL,
				[total_paid] [decimal](18, 2) NULL,
				[cd_budget_poc_frc] int ,
				[tx_budget_poc_frc] varchar(200),
				[cd_subctgry_poc_frc] int,
				[tx_subctgry_poc_frc] varchar(200),
				[fl_plc_svc] int,
			--	tx_program_index varchar(10),
				[fl_dup_payment] [int] NULL,
				plcm_sort_asc int,
				filter_service_category_todate int,
				filter_budget_category_todate int)
			
				truncate table #pay;
				 insert into #pay
				  select id_payment_fact
  ,dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) [srvc_begin_dt]
 , dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)[srvc_end_dt]
					, pf.ID_SERVICE_TYPE_DIM [id_service_type_dim]
					,pf.id_case
					,pf.ID_PROVIDER_DIM_SERVICE [id_provider_dim_service]
					,pf.ID_PRSN_CHILD [id_prsn_child]
					,pf.AM_RATE [am_rate]
					,pf.AM_UNITS [am_units]
					,pf.AM_TOTAL_PAID [am_total_paid]
			from payment_fact pf
			where exists (select * from base.rptPlacement 
						where rptPlacement.id_case=pf.id_case)
				and pf.ID_PRSN_CHILD is null
				and pf.AM_TOTAL_PAID > 0
			and  (dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) >='2000-01-01'
				or isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >'2000-01-01' )
			
				insert into #casepay							
					select distinct 
					  tcps.child [id_prsn_child]
					, tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch + 1 [dur_days]
					, case when end_date < getdate() then 1 else 0 end [fl_close]
					, pf.id_payment_fact
					, [srvc_begin_dt]
					, [srvc_end_dt]
					, std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 1 as prv_match
					, am_rate
					, am_units
					, am_total_paid  
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0
					,0
					,0
					,0
				from base.rptPlacement_Events tcps 
				join #pay pf on pf.ID_CASE=tcps.ID_CASE 
					and (
					([srvc_begin_dt] < isnull(tcps.end_date,'12/31/3999') 
					and isnull([srvc_end_dt] ,'12/31/3999') >  tcps.begin_date )
					AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
					AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)	)		
				join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
				left join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
		 where  not exists( select *
									from base.tbl_ihs_services ihs 
									where  ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT )
						and not exists(select * 
						from base.placement_payment_services plc 
						where plc.id_payment_fact=pf.id_payment_fact );


			update PP 
			set [fl_dup_payment] = 1
			from #casepay PP
			 join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact
						,abs(datediff(dd,begin_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact
					, pps.id_prsn_child,pps.id_removal_episode_fact
					,pps.begin_date,pps.end_date,pps.pymt_cd_srvc
					,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date
					 from  #casepay  pps
					 join (
							select id_payment_fact,count(*) as cnt
							  from  #casepay
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
			

				delete PP from #casepay PP where fl_dup_payment=1
 
			insert into base.placement_payment_services
		          ([id_prsn_child]
           ,[begin_date]
           ,[end_date]
           ,[id_removal_episode_fact]
           ,[id_placement_fact]
           ,[id_provider_dim_caregiver]
           ,[id_case]
           ,[dur_days]
           ,[fl_close]
           ,[id_payment_fact]
           ,[svc_begin_date]
           ,[svc_end_date]
           ,[pymt_cd_srvc]
           ,[pymt_tx_srvc]
           ,[fl_primary_srvc]
           ,[srvc_match]
           ,[prov_match]
           ,[rate]
           ,[unit]
           ,[total_paid]
           ,[cd_budget_poc_frc]
           ,[tx_budget_poc_frc]
           ,[cd_subctgry_poc_frc]
           ,[tx_subctgry_poc_frc]
           ,[fl_plc_svc]
           ,[fl_dup_payment]
		  	, plcm_pymnt_sort_asc 
			, filter_service_category_todate 
			, filter_budget_category_todate  )
			select 
				 CP.id_prsn_child
				, cp.begin_date
				, cp.end_date
				, cp.id_removal_episode_fact
				, cp.id_placement_fact
				, cp.id_provider_dim_caregiver
				, cp.id_case
				, cp.dur_days
				, cp.fl_close
				, cp.id_payment_fact
				, cp.svc_begin_date
				, cp.svc_end_date
				, cp.pymt_cd_srvc
				, cp.pymt_tx_srvc
				, cp.fl_primary_srvc
				, cp.srvc_match
				, cp.prov_match
				, cp.rate
				, cp.unit
				, cp.total_paid
				, cp.cd_budget_poc_frc
				, cp.tx_budget_poc_frc
				, cp.cd_subctgry_poc_frc
				, cp.tx_subctgry_poc_frc
				, cp.fl_plc_svc	
				, cp.fl_dup_payment	
				, 0
				, 0
				, 0
			from #casepay cp
			WHERE not exists(select * 
						from base.placement_payment_services plc 
						where plc.id_payment_fact=cp.id_payment_fact )
					and 	CP.fl_dup_payment = 0 
					and   cp.total_paid > 0 ;
	

/***************  
update to table base.placement_payment_services
fields: 	plcm_pymnt_sort_asc int,
				filter_service_category_todate int,
				filter_budget_category_todate int
*************************************/

update pps
set plcm_pymnt_sort_asc=q.row_num
from base.placement_payment_services  pps
join (select *
		, ROW_NUMBER() over (partition by id_removal_episode_fact
					order by begin_date asc,end_date asc,pps.svc_begin_date,pps.svc_end_date) as row_num
			from base.placement_payment_services  pps
		) q on q.id_placement_fact=pps.id_placement_fact
and q.id_payment_fact=pps.id_payment_fact
	
	create index idx_filters_to_date 
		on base.placement_payment_services(id_removal_episode_fact,begin_date,end_date,svc_begin_date,svc_end_date) include(id_placement_fact,id_payment_fact,cd_subctgry_poc_frc,cd_budget_poc_frc);

   if OBJECT_ID('tempDB..#toDate') is not null drop table #toDate;
	SELECT id_placement_fact,id_payment_fact,id_removal_episode_fact
					,begin_date
					,end_date
					,svc_begin_date
					,svc_end_date
					, max( power(10.0,16) + 
					 (case when pps.cd_subctgry_poc_frc=1 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=2 then 1 else 0 end)  * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=3 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=4 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=5 then 1 else 0 end)  * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=6 then 1 else 0 end)   * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=7 then 1 else 0 end)   * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=8 then 1 else 0 end)   * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=9 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=10 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=11 then 1 else 0 end)   * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=12 then 1 else 0 end)  * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=13 then 1 else 0 end)   * srvc.cd_multiplier + 
					 (case when pps.cd_subctgry_poc_frc=14 then 1 else 0 end)  * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=15 then 1 else 0 end)   * srvc.cd_multiplier+ 
					 (case when pps.cd_subctgry_poc_frc=16 then 1 else 0 end) * srvc.cd_multiplier)
					 OVER (PARTITION BY  id_removal_episode_fact
									order by begin_date,end_date,svc_begin_date,svc_end_date)  [filter_service_category_todate]   
					, max( power(10.0,7) + (case when pps.cd_budget_poc_frc=12 then 1 else 0 end) * bud.cd_multiplier + 
					 (case when pps.cd_budget_poc_frc=14 then 1 else 0 end) * bud.cd_multiplier + 
					 (case when pps.cd_budget_poc_frc=15 then 1 else 0 end)  * bud.cd_multiplier + 
					 (case when pps.cd_budget_poc_frc=16 then 1 else 0 end) * bud.cd_multiplier  + 
					 (case when pps.cd_budget_poc_frc=18 then 1 else 0 end)  * bud.cd_multiplier  + 
					 (case when pps.cd_budget_poc_frc=19 then 1 else 0 end)  * bud.cd_multiplier + 
					 (case when pps.cd_budget_poc_frc=99 then 1 else 0 end) * bud.cd_multiplier ) 
					 	 OVER (PARTITION BY  id_removal_episode_fact
									order by begin_date,end_date,svc_begin_date,svc_end_date) [filter_service_budget_todate]
		  into #toDate
		  FROM [base].[placement_payment_services] pps
		  join [ref_service_cd_subctgry_poc] srvc on srvc.cd_subctgry_poc_frc=pps.cd_subctgry_poc_frc
		  join  ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=pps.cd_budget_poc_frc;

		  update pps
		  set filter_service_category_todate=td.filter_service_category_todate
				,filter_budget_category_todate=td.filter_service_budget_todate
		  from [base].[placement_payment_services] pps
		  join #toDate td on pps.id_placement_fact=td.id_placement_fact
			and pps.id_payment_fact=td.id_payment_fact;
		

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
	





