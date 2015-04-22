CREATE procedure [base].[prod_build_placement_payment_services] (@permission_key datetime)
	as
		if @permission_key=(select cutoff_date from dbo.ref_Last_DW_Transfer)
		begin

if OBJECT_ID(N'base.placement_payment_services',N'U') is not null truncate table  base.placement_payment_services
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'PK_placement_payment_services')
alter table  [base].[placement_payment_services] drop constraint [PK_placement_payment_services];

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
           ,[fl_dup_payment])
		select  
					  tcps.child [id_prsn_child]
					  , tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, iif(tcps.days_to_dsch>0,tcps.days_to_dsch + 1,iif(tcps.end_date <> '9999-12-31' and  tcps.end_date is not null,datediff(dd,tcps.begin_date,tcps.end_date) + 1,datediff(dd,tcps.begin_date,(select cutoff_date from ref_last_dw_transfer)))) [dur_days]
					, iif(end_date < getdate(),1,0)  [fl_close]
					, pf.id_payment_fact
					,  [srvc_begin_dt]
					,  [srvc_end_dt]
					, std.cd_srvc 
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 1 [srvc_match]
					, 1 [prv_match]
					, am_rate
					, am_units
					, am_total_paid  
					, isnull(pps.cd_budget_poc_frc,0) [cd_budget_poc_frc]
					, isnull(pps.tx_budget_poc_frc,'-') tx_budget_poc_frc
					, isnull(pps.cd_subctgry_poc_frc,0)[cd_subctgry_poc_frc]
					,  isnull(pps.tx_subctgry_poc_frc,'-')[tx_subctgry_poc_frc]
					, pps.fl_plc_svc
					, 0 [fl_dup_payment]
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
					, isnull(pps.cd_budget_poc_frc,0) 
					, isnull(pps.tx_budget_poc_frc,'-') 
					, isnull(pps.cd_subctgry_poc_frc,0)
					,  isnull(pps.tx_subctgry_poc_frc,'-')
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
           ,[fl_dup_payment])
		select  distinct
					  tcps.child
					  , tcps.begin_date [begin_date]
					, tcps.end_date [end_date]
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.id_provider_dim_caregiver
					, tcps.id_case
					, tcps.days_to_dsch + 1 [dur_days]
					, iif( end_date < getdate() , 1 , 0 )  [fl_close]
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
           ,[fl_dup_payment])
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
			from base.rptPlacement_Events tcps 
			 join #pay  pf on pf.ID_PRSN_CHILD=tcps.child
			 and pf.AM_TOTAL_PAID > 0 
				and [srvc_begin_dt] <= isnull(tcps.end_date,'12/31/3999') 
				and isnull([srvc_end_dt] ,'12/31/3999') >=  tcps.begin_date 
				AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
				AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)	
			  join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
			   join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
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
				[fl_dup_payment] [int] NULL)
			
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
				from base.rptPlacement_Events tcps 
				join #pay pf on pf.ID_CASE=tcps.ID_CASE 
					and (
					([srvc_begin_dt] < isnull(tcps.end_date,'12/31/3999') 
					and isnull([srvc_end_dt] ,'12/31/3999') >  tcps.begin_date )
					AND NOT(coalesce([srvc_end_dt],'1900-01-01')= tcps.begin_date )
					AND NOT(coalesce([srvc_begin_dt],'1900-01-01')=tcps.end_date)	)		
				join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
				 join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
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
  )
			select 
				 cp.id_prsn_child
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

	
	
   if OBJECT_ID('tempDB..#toDate') is not null drop table #toDate;
	SELECT id_placement_fact,id_payment_fact,id_removal_episode_fact
					,begin_date
					,end_date
					,svc_begin_date
					,svc_end_date
					,pps.cd_subctgry_poc_frc
					, max(case when pps.cd_subctgry_poc_frc=1 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_family_focused_services
					, max(case when pps.cd_subctgry_poc_frc=2 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_child_care
					, max(case when pps.cd_subctgry_poc_frc=3 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_therapeutic_services
					, max(case when pps.cd_subctgry_poc_frc=4 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_mh_services
					, max(case when pps.cd_subctgry_poc_frc=5 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_receiving_care
					, max(case when pps.cd_subctgry_poc_frc=6 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_family_home_placements
					, max(case when pps.cd_subctgry_poc_frc=7 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_behavioral_rehabiliation_services
					, max(case when pps.cd_subctgry_poc_frc=8 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_other_therapeutic_living_situations
					, max(case when pps.cd_subctgry_poc_frc=9 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_specialty_adolescent_services
					, max(case when pps.cd_subctgry_poc_frc=10 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_respite
					, max(case when pps.cd_subctgry_poc_frc=11 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_transportation
					, max(case when pps.cd_subctgry_poc_frc=12 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_clothing_incidentals
					, max(case when pps.cd_subctgry_poc_frc=13 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_sexually_aggressive_youth
					, max(case when pps.cd_subctgry_poc_frc=14 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_adoption_support
					, max(case when pps.cd_subctgry_poc_frc=15 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_various
					, max(case when pps.cd_subctgry_poc_frc=16 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_medical
					, max(case when pps.cd_subctgry_poc_frc=17 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_ihs_reun
					, max(case when pps.cd_subctgry_poc_frc=18 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_concrete_goods
					, cast(null as decimal(21,0)) [filter_service_category_todate]
					,pps.cd_budget_poc_frc
					, max(case when pps.cd_budget_poc_frc=12 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C12
					, max(case when pps.cd_budget_poc_frc=14 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C14
					, max(case when pps.cd_budget_poc_frc=15 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C15
					, max(case when pps.cd_budget_poc_frc=16 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C16
					, max(case when pps.cd_budget_poc_frc=18 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C18
					, max(case when pps.cd_budget_poc_frc=19 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_budget_C19
					, max(case when pps.cd_budget_poc_frc=99 then 1 else 0 end ) over (partition by id_removal_episode_fact	order by svc_begin_date,svc_end_date)  fl_uncat_svc
					, cast(null as decimal(18,0)) filter_service_budget_todate
		  into #toDate
		  FROM [base].[placement_payment_services] pps
		   join ref_service_cd_subctgry_poc srvc on srvc.cd_subctgry_poc_frc=pps.cd_subctgry_poc_frc
		   join  ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=pps.cd_budget_poc_frc;

		
		  update #toDate
		  set filter_service_category_todate= cast((select multiplier from ref_service_cd_subctgry_poc where cd_subctgry_poc_frc=0)
								+ fl_family_focused_services *   (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services') 
								+ fl_child_care *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_child_care')  
								+ fl_therapeutic_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services')  
								+ fl_mh_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_mh_services')  
								+ fl_receiving_care *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_receiving_care')  
								+ fl_family_home_placements *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_home_placements')  
								+ fl_behavioral_rehabiliation_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services')   
								+ fl_other_therapeutic_living_situations *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations')   
								+ fl_specialty_adolescent_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services')   
								+ fl_respite *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_respite')   
								+ fl_transportation *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_transportation')   
								+ fl_clothing_incidentals *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_clothing_incidentals')   
								+ fl_sexually_aggressive_youth *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_sexually_aggressive_youth')   
								+ fl_adoption_support *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_adoption_support')   
								+ fl_various *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_various')   
								+ fl_medical *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_medical') 
								+ fl_ihs_reun *    (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun')  
								+ fl_concrete_goods *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods')   as decimal(21,0))
				,filter_service_budget_todate =   cast((select multiplier from [ref_service_cd_budget_poc_frc] where cd_budget_poc_frc='0')
									 +  fl_budget_C12 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C12')
									 +  fl_budget_C14 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C14')
									 +  fl_budget_C15 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C15')
									 +  fl_budget_C16 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C16')
									 +  fl_budget_C18 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C18')
									 +  fl_budget_C19 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C19')
									 +  fl_uncat_svc *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_uncat_svc') as decimal(9,0));

 update pps
 set filter_service_category_todate=td.filter_service_category_todate
		 ,filter_service_budget_todate=td.filter_service_budget_todate
		 , pps. fl_family_focused_services=td.fl_family_focused_services
		, pps. fl_child_care=td.fl_child_care
		, pps. fl_therapeutic_services=td.fl_therapeutic_services
		, pps. fl_mh_services=td.fl_mh_services
		, pps. fl_receiving_care=td.fl_receiving_care
		, pps. fl_family_home_placements=td.fl_family_home_placements
		, pps. fl_behavioral_rehabiliation_services=td.fl_behavioral_rehabiliation_services
		, pps. fl_other_therapeutic_living_situations=td.fl_other_therapeutic_living_situations
		, pps. fl_specialty_adolescent_services=td.fl_specialty_adolescent_services
		, pps. fl_respite=td.fl_respite
		, pps. fl_transportation=td.fl_transportation
		, pps. fl_clothing_incidentals=td.fl_clothing_incidentals
		, pps. fl_sexually_aggressive_youth=td.fl_sexually_aggressive_youth
		, pps. fl_adoption_support=td.fl_adoption_support
		, pps. fl_various=td.fl_various
		, pps. fl_medical=td.fl_medical
		, pps.fl_ihs_reun=td.fl_ihs_reun
		, pps.fl_concrete_goods=td.fl_concrete_goods
		, pps. fl_budget_C12=td.fl_budget_C12
		, pps. fl_budget_C14=td.fl_budget_C14
		, pps. fl_budget_C15=td.fl_budget_C15
		, pps. fl_budget_C16=td.fl_budget_C16
		, pps. fl_budget_C18=td.fl_budget_C18
		, pps. fl_budget_C19=td.fl_budget_C19
		, pps. fl_uncat_svc=td.fl_uncat_svc
 from base.placement_payment_services pps 
 join #toDate td on pps.id_removal_episode_fact=td.id_removal_episode_fact
 and pps.id_payment_fact=td.id_payment_fact
 and pps.id_placement_fact=td.id_placement_fact
		 
delete pps
from base.placement_payment_services pps
join (
select pps.*,row_number() over (partition by pps.id_payment_fact order by id_placement_fact,svc_begin_date,svc_end_date) [row_num]
from base.placement_payment_services pps
join (
select id_payment_fact,count(*)   as cnt  from base.placement_payment_services
group by id_payment_fact having count(*) > 1) q on q.id_payment_fact=pps.id_payment_fact
)   del on del.id_payment_fact=pps.id_payment_fact
and del.id_placement_fact=pps.id_placement_fact
and del.row_num > 1


		
ALTER TABLE [base].[placement_payment_services] ADD CONSTRAINT PK_placement_payment_services PRIMARY KEY CLUSTERED 
(
	[id_payment_fact] ASC
)


update statistics base.placement_payment_services;

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_placement_payment_services'


		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
	






