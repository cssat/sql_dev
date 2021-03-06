USE [dbCoreAdministrativeTables]
GO
/****** Object:  StoredProcedure [dbo].[prod_build_tbls_ihs_episode_services]    Script Date: 8/22/2013 12:20:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[prod_build_tbls_ihs_episode_services](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin
	set nocount on
	declare @chstart datetime
	declare @chend datetime
	declare @startLoop datetime
	declare @stopLoop datetime
	declare @cutoff_date datetime
	declare @date_type int
	declare @qry_type int
	declare @max_row int
	declare @row int
	declare @start_date datetime;
		
	select @cutoff_date=cutoff_date from ref_last_dw_transfer;
	set @start_date=cast('1/1/1997' as datetime)
		
		
	if object_ID('tempDB..##eps') is not null drop table ##eps
	
	select *,row_number() over (partition by id_case order by eps_begin,eps_end  asc) as sort_asc
	into ##eps
	from (
		select distinct id_case,state_custody_start_date as eps_begin
		,isnull(federal_discharge_date,'12/31/3999') as eps_end
		from tbl_child_episodes ) eps


		
-- start retrieving all assignments that are either designated 'out-of-home care' or cps for social workers
		
	if object_ID('tempDB..##ih_assgn_all') is not null drop table ##ih_assgn_all
	SELECT  distinct
			af.ID_CASE as id_case
		,  min(af.ID_ASSIGNMENT_FACT) as id_table_origin
		,  max(af.id_assignment_fact) as max_id_table_origin
		, count(*) as cnt_id_table_origin
		, dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) as ihs_begin_date
		, max(case when isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END),'12/31/3999') > coalesce(dt_case_cls,'12/31/3999')
					then dt_case_cls
		  else isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END),'12/31/3999') 
		  end )as ihs_end_date
		, cast(null as bigint) as case_sort
		, cast(null as datetime) as first_ihs_date
		, cast(null as datetime) as latest_ihs_date
		, cast(null as int) as fl_plcmnt_prior_ihs
		, cast(null as int) as fl_plcmnt_during_ihs
		, cast(null as datetime) as plcmnt_date
		, cast(0 as int)  as cd_office
		, cast(null as varchar(200)) as tx_office
		, cast(0 as int) as nbr_svc_authorized
		, cast(0 as int) as nbr_svc_paid 
		, cast(0 as numeric(18,2)) as total_amt_paid
		, cast(0 as int) as most_exp_cd_srvc
		, cast(null as varchar(200)) as most_exp_tx_srvc
		, cast(0 as numeric(18,2)) as total_most_exp_srvc
		, cast(0 as int) as fl_family_focused_services
		, cast(0 as int) as fl_child_care
		, cast(0 as int) as fl_therapeutic_services
		, cast(0 as int) as fl_mh_services
		, cast(0 as int) as fl_receiving_care
		, cast(0 as int) as fl_family_home_placements
		, cast(0 as int) as fl_behavioral_rehabiliation_services
		, cast(0 as int) as fl_other_therapeutic_living_situations
		, cast(0 as int) as fl_specialty_adolescent_services
		, cast(0 as int) as fl_respite
		, cast(0 as int) as fl_transportation
		, cast(0 as int) as fl_clothing_incidentals
		, cast(0 as int) as fl_sexually_aggressive_youth
		, cast(0 as int) as fl_adoption_support
		, cast(0 as int) as fl_various
		, cast(0 as int) as fl_medical
		, cast(0 as int) as fl_budget_C12
		, cast(0 as int) as fl_budget_C14
		, cast(0 as int) as fl_budget_C15
		, cast(0 as int) as fl_budget_C16
		, cast(0 as int) as fl_budget_C18
		, cast(0 as int) as fl_budget_C19
		, cast(0 as int) as fl_budget_unpd
		, aad.cd_asgn_type
		, aad.tx_asgn_type
		, cast(0 as int) as fl_force_begin_date
		, cast(0 as int) as fl_force_end_date
		, cast('assignment_fact' as varchar(50)) as tbl_origin 
		, cast(1 as int) as tbl_origin_cd
	into ##ih_assgn_all
	from  CA.ASSIGNMENT_FACT af
	join CA.ASSIGNMENT_ATTRIBUTE_DIM aad on af.ID_ASSIGNMENT_ATTRIBUTE_DIM=aad.ID_ASSIGNMENT_ATTRIBUTE_DIM
	join CA.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
	left join dbo.tbl_case_dim cd on cd.id_case=af.id_case
			and dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)<dt_case_cls
			and coalesce(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),'12/31/3999')>dt_case_opn
--	left join ca.location_dim ld on ld.id_location_dim=wd.id_location_dim_worker
	WHERE  af.id_calendar_dim_begin<= af.id_calendar_dim_end
			and (	(
				aad.CD_ASGN_RSPNS=7 
				and aad.CD_ASGN_CTGRY=1 
				and aad.CD_ASGN_TYPE in (9,8,5)  -- CFWS,FRS, FVS  select distinct tx_asgn_type from ##ihs_intk where CD_ASGN_TYPE in (9,8,5)
				and	
					(
						(
							aad.CD_ASGN_ROLE =2  --  select distinct TX_ASGN_ROLE from CA.ASSIGNMENT_ATTRIBUTE_DIM aad  where CD_ASGN_ROLE =2
							and  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
											> @start_date 
							and  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime)) 
									<= cast('2009-01-29' as datetime)
						)
					or (
							aad.CD_ASGN_ROLE=1 -- Primary after   select distinct TX_ASGN_ROLE from CA.ASSIGNMENT_ATTRIBUTE_DIM aad  where CD_ASGN_ROLE =1
							and isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
										> @start_date
						)
					)
				)
		or (
				CD_ASGN_CTGRY=1  and aad.CD_ASGN_TYPE=4  -- CASE/CPS select distinct tx_asgn_type from ##ihs_intk where CD_ASGN_TYPE in (4)
				and (
						(
							CD_ASGN_ROLE=2 
							AND isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
											<= cast('2009-01-29' as datetime)
							AND  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime)) 
										> @start_date
						)
					
					or (
						CD_ASGN_ROLE=1 
						and isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
									> @start_date
						)	
					)
			)
		)
	  group by af.ID_CASE,dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) ,aad.cd_asgn_type
		, aad.tx_asgn_type
	  order by af.ID_CASE,[ihs_begin_date],[ihs_end_date]

	
		
		--UPDATE THOSE WITH PLACEMENT PRIOR TO ASSGN_BEGIN
		 UPDATE IH
		 SET fl_plcmnt_prior_ihs=1
		 FROM ##ih_assgn_all IH
		 JOIN ##eps TCE ON TCE.ID_CASE=ih.id_case 
		 AND TCE.eps_begin  < IH.ihs_begin_date;
		 
		 
		 -- update those where the placement happens after initial assignment
		 -- force an end date for the assignment
		 UPDATE IH
		 SET fl_plcmnt_during_ihs=1
			,plcmnt_date= TCE.eps_begin
			,IH.ihs_end_date=tce.eps_begin
			,ih.fl_force_end_date=1
		 FROM ##ih_assgn_all IH
		 cross apply(select top 1 tce.eps_begin
					from  ##eps TCE 
					where TCE.ID_CASE=ih.id_case 
					AND TCE.eps_begin
					BETWEEN  IH.ihs_begin_date and coalesce(IH.ihs_end_date,'12/31/3999')
					order by tce.sort_asc ) tce

		--remove assignments for out of home services.  These are identified by all assignments occurring 
		-- between the eps begin and end date that are not the initial fl_plcmnt_during_ihs = 1
		delete ih
		from ##ih_assgn_all ih
		join ##eps 
			 q on ih.id_case=q.id_case
			and ih.ihs_begin_date between eps_begin and eps_end
		where fl_plcmnt_during_ihs <> 1 or fl_plcmnt_during_ihs is null

		-- now aggregate by end date ( this will get rid of segments contained within another with same end date)
		if object_id('tempDB..#ih_tmp') is not null drop table #ih_tmp
		SELECT id_case
			  ,min(id_table_origin) as id_table_origin
			  ,max(max_id_table_origin) as max_id_table_origin
			  ,sum(cnt_id_table_origin) as cnt_id_table_origin
			  ,min(ihs_begin_date) as ihs_begin_date
			  ,ihs_end_date
			  ,case_sort
			  ,first_ihs_date
			  ,latest_ihs_date
			  ,max(fl_plcmnt_prior_ihs) as fl_plcmnt_prior_ihs
			  ,max(fl_plcmnt_during_ihs)  as fl_plcmnt_during_ihs
			  ,min(plcmnt_date) as plcmnt_date --need to update federal discharge date
			  ,min(cd_office) as cd_office
			  ,tx_office
			  ,nbr_svc_authorized
			  ,nbr_svc_paid
			  ,total_amt_paid
			  ,most_exp_cd_srvc
			  ,most_exp_tx_srvc
			  ,total_most_exp_srvc
			 , max(fl_family_focused_services) as fl_family_focused_services
			 , max(fl_child_care) as fl_child_care
			 , max(fl_therapeutic_services) as fl_therapeutic_services
			 , max(fl_mh_services) as fl_mh_services
			 , max(fl_receiving_care) as fl_receiving_care
			 , max(fl_family_home_placements) as fl_family_home_placements
			 , max(fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
			 , max(fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
			 , max(fl_specialty_adolescent_services) as fl_specialty_adolescent_services
			 , max(fl_respite) as fl_respite
			 , max(fl_transportation) as fl_transportation
			 , max(fl_clothing_incidentals) as fl_clothing_incidentals
			 , max(fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
			 , max(fl_adoption_support) as fl_adoption_support
			 , max(fl_various) as fl_various
			 , max(fl_medical) as fl_medical
			 , max(fl_budget_C12) as fl_budget_C12
			 , max(fl_budget_C14) as fl_budget_C14
			 , max(fl_budget_C15) as fl_budget_C15
			 , max(fl_budget_C16) as fl_budget_C16
			 , max(fl_budget_C18) as fl_budget_C18
			 , max(fl_budget_C19) as fl_budget_C19
			 , max(fl_budget_unpd) as fl_budget_unpd		 
			  ,cd_asgn_type
			  ,tx_asgn_type
			  ,max(fl_force_begin_date) as fl_force_begin_date
			  ,max(fl_force_end_date) as fl_force_end_date
			  ,tbl_origin
			  ,tbl_origin_cd
			  into #ih_tmp
			from ##ih_assgn_all
			group by id_case
			  ,ihs_end_date
			  ,case_sort
			  ,first_ihs_date
			  ,latest_ihs_date
			  ,tx_office
			  ,nbr_svc_authorized
			  ,nbr_svc_paid
			  ,total_amt_paid
			  ,most_exp_cd_srvc
			  ,most_exp_tx_srvc
			  ,total_most_exp_srvc
			  ,cd_asgn_type
			  ,tx_asgn_type
			  ,tbl_origin
			  ,tbl_origin_cd
		

		truncate table ##ih_assgn_all
		insert into ##ih_assgn_all
		select * from #ih_tmp


 

		CREATE NONCLUSTERED INDEX  idx_temp_assgn_all on ##ih_assgn_all ([id_table_origin],max_id_table_origin)
		
		update ihs
		set case_sort=q.row_num
		from ##ih_assgn_all ihs
		join (	select *
				, row_number() over (partition by id_case order by ihs_begin_date asc
											,ihs_end_date desc) as row_num
				from  ##ih_assgn_all) q on q.id_table_origin=ihs.id_table_origin and q.max_id_table_origin=ihs.max_id_table_origin


		set nocount off
		declare @row_num int
		/****      merge assignment segments contained within  ************************************/
   		set @row_num=1
		while @row_num > 0
		begin	
				if object_ID('tempDB..#pieces') is not null drop table #pieces

				select distinct 1 as fl_curr,curr.*
				into #pieces
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
					and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
				union 
				select distinct 0, nxt.*
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
					and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
				order by [id_case],[case_sort],fl_curr
			
				
				set @row_num=@@ROWCOUNT
				if @row_num > 0
				begin
				-- first delete the segments that are currently there
						delete IH
						from ##ih_assgn_all ih
						join #pieces s on s.id_case=ih.id_case 
						and s.case_sort=ih.case_sort
						and s.id_table_origin=ih.id_table_origin 
						and s.max_id_table_origin=ih.max_id_table_origin
						and s.ihs_begin_date=ih.ihs_begin_date 
						and s.ihs_end_date=ih.ihs_end_date
		
		

						update curr
						set curr.cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
						from #pieces curr
						join #pieces nxt on curr.id_case=nxt.id_case 
							and curr.case_sort + 1 =nxt.case_sort
						left join #pieces dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
						where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
							  and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
						and curr.fl_curr=1 and nxt.fl_curr=0

		

						insert into ##ih_assgn_all
						select 
							   id_case
							  ,id_table_origin
							  ,max_id_table_origin
							  ,cnt_id_table_origin
							  ,ihs_begin_date
							  ,ihs_end_date
							  ,case_sort
							  ,first_ihs_date
							  ,latest_ihs_date
							  ,fl_plcmnt_prior_ihs
							  ,fl_plcmnt_during_ihs
							  ,plcmnt_date
							  ,cd_office
							  ,tx_office
							  ,nbr_svc_authorized
							  ,nbr_svc_paid
							  ,total_amt_paid
							  ,most_exp_cd_srvc
							  ,most_exp_tx_srvc
							  ,total_most_exp_srvc
							  ,fl_family_focused_services
							  ,fl_child_care
							  ,fl_therapeutic_services
							  ,fl_mh_services
							  ,fl_receiving_care
							  ,fl_family_home_placements
							  ,fl_behavioral_rehabiliation_services
							  ,fl_other_therapeutic_living_situations
							  ,fl_specialty_adolescent_services
							  ,fl_respite
							  ,fl_transportation
							  ,fl_clothing_incidentals
							  ,fl_sexually_aggressive_youth
							  ,fl_adoption_support
							  ,fl_various
							  ,fl_medical
							  ,fl_budget_C12
							  ,fl_budget_C14
							  ,fl_budget_C15
							  ,fl_budget_C16
							  ,fl_budget_C18
							  ,fl_budget_C19
							  ,fl_budget_unpd
							  ,cd_asgn_type
							  ,tx_asgn_type
							  ,fl_force_end_date
							  ,fl_force_begin_date
							  ,tbl_origin
							  ,tbl_origin_cd		
						from #pieces where fl_curr=1
			

				 end
				update ihs
				set case_sort=q.row_num
				from ##ih_assgn_all ihs
				join (	select *
						, row_number() over (partition by id_case order by ihs_begin_date asc
													,ihs_end_date desc) as row_num
						from  ##ih_assgn_all) q  on q.id_table_origin=ihs.id_table_origin and q.max_id_table_origin=ihs.max_id_table_origin

			  
		end




		/************************             merge overlapping assignment segments  ***********************************/
	    set @row_num=1
		while @row_num > 0
		begin	
				if object_ID('tempDB..#segs') is not null drop table #segs

				select 1 as fl_curr,curr.*
				into #segs
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				union 
				select 0, nxt.*
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				order by [id_case],[case_sort],fl_curr

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ih_assgn_all ih
				join #segs s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.id_table_origin=ih.id_table_origin 
				and s.max_id_table_origin=ih.max_id_table_origin
				and s.ihs_begin_date=ih.ihs_begin_date 
				and s.ihs_end_date=ih.ihs_end_date
		

				update curr
				set ihs_end_date=nxt.ihs_end_date
				, curr.cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
				, max_id_table_origin=case when nxt.max_id_table_origin > curr.id_table_origin then nxt.max_id_table_origin  else curr.id_table_origin  end
				from #segs curr
				join #segs nxt on curr.id_case=nxt.id_case and curr.case_sort + 1 =nxt.case_sort
				left join #segs dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				and curr.fl_curr=1 and nxt.fl_curr=0

		

				insert into ##ih_assgn_all
				select 
					   id_case
					  ,id_table_origin
					  ,max_id_table_origin
					  ,cnt_id_table_origin
					  ,ihs_begin_date
					  ,ihs_end_date
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,fl_plcmnt_prior_ihs
					  ,fl_plcmnt_during_ihs
					  ,plcmnt_date
					  ,cd_office
					  ,tx_office
					  ,nbr_svc_authorized
					  ,nbr_svc_paid
					  ,total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
					  ,fl_family_focused_services
					  ,fl_child_care
					  ,fl_therapeutic_services
					  ,fl_mh_services
					  ,fl_receiving_care
					  ,fl_family_home_placements
					  ,fl_behavioral_rehabiliation_services
					  ,fl_other_therapeutic_living_situations
					  ,fl_specialty_adolescent_services
					  ,fl_respite
					  ,fl_transportation
					  ,fl_clothing_incidentals
					  ,fl_sexually_aggressive_youth
					  ,fl_adoption_support
					  ,fl_various
					  ,fl_medical
					  ,fl_budget_C12
					  ,fl_budget_C14
					  ,fl_budget_C15
					  ,fl_budget_C16
					  ,fl_budget_C18
					  ,fl_budget_C19
					  ,fl_budget_unpd
					  ,cd_asgn_type
					  ,tx_asgn_type
					  ,fl_force_end_date
					  ,fl_force_begin_date
					  ,tbl_origin
					  ,tbl_origin_cd		
				from #segs where fl_curr=1


				update ihs
						set case_sort=q.row_num
						from ##ih_assgn_all ihs
						join (	select *
								, row_number() over (partition by id_case order by ihs_begin_date asc
															,ihs_end_date desc) as row_num
								from  ##ih_assgn_all) q on q.id_table_origin=ihs.id_table_origin
		end

		--get initial office of worker
			
		 UPDATE IH
		 SET cd_office = ld.cd_office
				,tx_office =ld.tx_office
		 FROM ##ih_assgn_all IH
		 join ca.assignment_fact af on ih.id_table_origin=af.id_assignment_fact
			join CA.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
			left join ca.location_dim ld on ld.id_location_dim=wd.id_location_dim_worker

--      select cd_office,tx_office,count(*) as cnt from ##ih_assgn_all group by cd_office,tx_office order by cd_office,tx_office
					
----------------------------------  AUTHORIZATIONS	---------------------------------------------  AUTHORIZATIONS	-------------------------------------------  AUTHORIZATIONS		
		
		 
		--	--**  construct parallel family in-home services 
		--if object_ID('tempDB..##ffserv') is not null drop table ##ffserv
		--select CD_SRVC,1 as FFSserv,cast('PCIT' as varchar(50)) as FFSserv_desc
		--into ##ffserv
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (74,76,85)
		--or CD_SRVC between 306 and  320
		--or CD_SRVC between 567 and  578

		--insert into ##ffserv
		--select CD_SRVC,2 as FFSserv,'Home-Based Services'
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (461,462,178000)
		--OR CD_SRVC between 171 and  173
		--OR CD_SRVC between 175 and  177
		--OR CD_SRVC between 249 and 252
		--OR CD_SRVC between 446 and  457
		--OR CD_SRVC between 579 and  581
		--OR CD_SRVC between 598 and  605
		--OR CD_SRVC between 1352 and 1354
		--OR CD_SRVC between 177009 and  177012
		--OR CD_SRVC between 179000 and  179009

		--insert into ##ffserv
		--select CD_SRVC,3 as FFSserv,'Family Preservation Services'
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC between 204 and  206
		--OR CD_SRVC between 243 and 245
		--OR CD_SRVC between 612 and 615
		--OR CD_SRVC between 109000 and  109002;

		--insert into ##ffserv
		--select CD_SRVC,4 as FFSserv,'Functional Family Therapy' 
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC between 215 and  218
		--OR CD_SRVC between 582 and  597

		--insert into ##ffserv
		--select CD_SRVC,5 as FFSserv,'Alternative Response Services'
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (410,616)


		--insert into ##ffserv
		--select CD_SRVC,6 as FFSserv,'INTENSIVE FAMILY PRESERVATION SVC (IFPS)'
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (1355,1356)
		--OR CD_SRVC between  430 and  435
		--OR CD_SRVC between  606 and  611
		--	OR CD_SRVC between  185001 and  185006

		--insert into ##ffserv
		--select CD_SRVC,7 as FFSserv,'misc'
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (411,444,566)

		--if object_ID('tempDB..##IHFFSsrvc') is not null drop table ##IHFFSsrvc
		--select 1 as IHFFSsrvc,CD_SRVC,cast('In Home Family Focused Service' as varchar(50)) as IHFFSsrvc_desc
		--into ##IHFFSsrvc
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (74,204,243,249,250,308,315,316,319,320,430,431,432,461,462,
		--	109000,185001,185002,185003);
		    
		--if object_ID('tempDB..##IHmiscsrvc') is not null drop table ##IHmiscsrvc
		--select 1 as IHmiscsrvc,CD_SRVC,cast('misc In Home Service' as varchar(50)) as IHmiscsrvc_desc
		--into ##IHmiscsrvc
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (3,6,9,12,13,35,81,88,93,96,99,104,108,115,120,122,125,128,131,264,
		---- removed cd_srvc 40
		----where CD_SRVC in (3,6,9,12,13,35,40,81,88,93,96,99,104,108,115,120,122,125,128,131,264,
		--	367,369,371,376,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,
		--	705,172000,173000,173002,173004,173005,173007,173010,173014,173016,173023,173028,173033,
		--	173039);
		    
		--	if object_ID('tempDB..##BRStype') is not null drop table ##BRStype
		--	select 1 as BRStype,CD_SRVC,cast('In Home'  as varchar(50)) as BRStype_desc
		--into ##BRStype
		--from CA.SERVICE_TYPE_DIM
		--where CD_SRVC in (42,45,48,51,52,56,58,59,61,63,64,81,268,271,273,1095,1097,1099,
		--   1110,1127,1130,1132,1133,1136,1138,1140,1142,1144,1146,1148,1150,1152,1154,1156,1158,
		--   1160,1162,1164,1166,1168,1170,1172,1174,1176,1178,1199,1202,1204,1213,1214,1215,1218,
		--   1220,1596,1603,1620,1623,1625,1627,1629,1631,1633,1635,1637,1639,1641,1643,1645,1647,
		--   1649,1651,1653,1655,1657,1659,1661,1663,1665,1667,1669,1672,1674,1676,1680,1681,1682,
		--   1685,1687,176001,176004,176006,176008,176010,176012,176014,176018,176020,176022,
		--   177000,177002,177004,177007);
		  
/**********************************************************************************************************************************************  now  */

		
		--declare @chstart datetime
		--declare @chend datetime
		--declare @startLoop datetime
		--declare @stopLoop datetime
		--declare @cutoff_date datetime
		--declare @date_type int
		--declare @qry_type int
		--declare @max_row int
		--declare @row int
		--declare @start_date datetime;
		--declare @row_num int
		--select @cutoff_date=cutoff_date from ref_last_dw_transfer;
		--set @start_date=cast('1/1/1997' as datetime)

/****************************************************   get all in-home authorizations by unique service begin date  ***********/		
		--get all in-home authorizations by unique service begin date
		if object_ID('tempDB..##ihs_auths_all') is not null drop table ##ihs_auths_all
		SELECT distinct 
				 af.id_case
				, min(af.id_authorization_fact) as min_id_authorization_fact
				, max(af.id_authorization_fact) as max_id_authorization_fact
				, count(*) as cnt_id_table_origin
				, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN) as [srvc_dt_begin]
				, max(isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')) as [srvc_dt_end]
				, cast(null as bigint) as case_sort
				, cast(null as datetime) as first_ihs_date
				, cast(null as datetime) as latest_ihs_date
				, cast(null as int) as fl_plcmnt_prior_ihs
				, cast(null as int) as fl_plcmnt_during_ihs
				, cast(null as datetime) as plcmnt_date
				, cast(null as int) as cd_office
				, cast(null as varchar(200)) as tx_office
				--, cast(count(distinct af.id_authorization_fact)  as int) as nbr_svc_authorized
				--, sum(case when ad.cd_auth_status=2 then 1 else 0 end) as nbr_svc_paid
				--, cast(sum(case when ad.cd_auth_status=2 then  af.am_total_paid else 0 end) as numeric(18,2)) as total_amt_paid
				, 0 as nbr_svc_authorized
				, 0 as nbr_svc_paid
				, cast(0  as numeric(18,2)) as total_amt_paid 
				, cast(0 as int) as most_exp_cd_srvc
				, cast(null as varchar(200)) as most_exp_tx_srvc
				, cast(0 as numeric(18,2)) as total_most_exp_srvc
				, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
				, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
				, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
				, max(case when sc.cd_subctgry_poc_frc=4 then 1 else 0 end) as fl_mh_services
				, max(case when sc.cd_subctgry_poc_frc=5 then 1 else 0 end) as fl_receiving_care
				, max(case when sc.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
				, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
				, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
				, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
				, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
				, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
				, max(case when sc.cd_subctgry_poc_frc=12 then 1 else 0 end) as fl_clothing_incidentals
				, max(case when sc.cd_subctgry_poc_frc=13 then 1 else 0 end) as fl_sexually_aggressive_youth
				, max(case when sc.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
				, max(case when sc.cd_subctgry_poc_frc=15 then 1 else 0 end) as fl_various
				, max(case when sc.cd_subctgry_poc_frc=16 then 1 else 0 end) as fl_medical
				, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
				, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
				, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
				, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
				, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
				, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
				, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end) as fl_budget_unpd
				--, cd_auth_status
				--, tx_auth_status
				, cast(0 as int) as fl_force_begin_date
				, cast(0 as int) as fl_force_end_date
				, cast('authorization_fact' as varchar(50)) as tbl_origin 
				, cast(2 as int) as tbl_origin_cd
			into ##ihs_auths_all
			FROM CA.AUTHORIZATION_FACT  af 
			join ca.authorization_dim ad on ad.id_authorization_dim=af.id_authorization_dim  
					and cd_auth_status in (1,2)
			join  CA.SERVICE_TYPE_DIM std on std.ID_SERVICE_TYPE_DIM =af.ID_SERVICE_TYPE_DIM
			join dbo.ref_service_category sc on sc.cd_srvc=std.cd_srvc and fl_ihs_svc=1
	--		join CA.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
			--join ca.location_dim ld on ld.id_location_dim=af.id_location_dim
			--left join ##ffserv ffs on ffs.CD_SRVC=std.CD_SRVC
			--left join ##IHFFSsrvc hffs on hffs.CD_SRVC=std.CD_SRVC
			--left join ##IHmiscsrvc ihm on ihm.CD_SRVC=std.CD_SRVC
			--left join ##BRStype brs on brs.CD_SRVC=std.CD_SRVC
			WHERE isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),'12/31/3999') >=@start_date
			and  af.id_case <> 0
				--and ( isnull(hffs.IHFFSsrvc,0)=1 
				--	or isnull(ihm.IHmiscsrvc,0) =1 
				--	or isnull(brs.BRStype,0)=1 
				--	or isnull(ffs.FFSserv,0)<>0)
			group by id_case,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN)
			--, cd_auth_status
			--, tx_auth_status

			-- get all the auth details for detail table
			if object_ID('tempDB..##ihs_auths_dtl') is not null drop table ##ihs_auths_dtl		
			select 
				cast(null as int) as id_ihs_episode
			    ,af.id_authorization_fact as dtl_id_authorization_fact
				,af.id_case
				,af.id_prsn_child
				,af.child_age
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN) as [srvc_dt_begin]
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END) as [srvc_dt_end]
				,ad.cd_auth_status
				,ad.tx_auth_status
				,sc.cd_srvc
				,sc.tx_srvc
				,af.am_rate
				,af.am_units
				,af.am_total_paid
				,af.id_chart_of_accounts_dim
				,af.id_source_funds_dim
				,af.id_service_type_dim
				,af.id_provider_dim_service
				,std.cd_unit_rate_type
				,std.tx_unit_rate_type
				,std.cd_srvc_ctgry
				,std.tx_srvc_ctgry
				,sc.cd_budget_poc_frc
				,sc.tx_budget_poc_frc
				,sc.cd_subctgry_poc_frc
				,sc.tx_subctgry_poc_frc
				, 0 as fl_delete
			into ##ihs_auths_dtl
			from ##ihs_auths_all auth
			join ca.authorization_fact af on af.id_authorization_fact between min_id_authorization_fact and max_id_authorization_fact
				and af.id_case=auth.id_case and dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN) =srvc_dt_begin
			join ca.authorization_dim ad on ad.id_authorization_dim=af.id_authorization_dim  and cd_auth_status in (1,2)
			join  CA.SERVICE_TYPE_DIM std on std.ID_SERVICE_TYPE_DIM =af.ID_SERVICE_TYPE_DIM
			join dbo.ref_service_category sc on sc.cd_srvc=std.cd_srvc and sc.fl_ihs_svc=1
			WHERE isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),'12/31/3999') >=@start_date
			and  af.id_case <> 0
				--and ( isnull(hffs.IHFFSsrvc,0)=1 
				--	or isnull(ihm.IHmiscsrvc,0) =1 
				--	or isnull(brs.BRStype,0)=1 
				--	or isnull(ffs.FFSserv,0)<>0)


		--UPDATE THOSE WITH PLACEMENT PRIOR TO srvc_dt_begin
		 UPDATE IH
		 SET ih.fl_plcmnt_prior_ihs=1
		 FROM ##ihs_auths_all IH
		 JOIN ##eps TCE ON TCE.ID_CASE=ih.id_case 
			AND TCE.eps_begin <  IH.srvc_dt_begin 
			
		 
		 --update ##ih_assgn_all
		 --set plcmnt_during_asgn=0,plcm_date=null
		 

		 UPDATE IH
		 SET ih.fl_plcmnt_during_ihs=1,plcmnt_date= TCE.eps_begin
			,srvc_dt_end=TCE.eps_begin
			,fl_force_end_date=1
		 FROM ##ihs_auths_all IH
		 cross apply(select top 1 tce.eps_begin
					from  ##eps TCE 
					where TCE.ID_CASE=ih.ID_CASE
					AND TCE.eps_begin
					BETWEEN  IH.srvc_dt_begin and coalesce(IH.srvc_dt_end,'12/31/3999')
					order by tce.sort_asc asc) tce

		--remove authorizations  for  out of home services
		delete ih
		---select state_custody_start_date,federal_discharge_date,ih.*
		from ##ihs_auths_all ih
		join ##eps
			 q on ih.id_case=q.id_case
		and ih.srvc_dt_begin between eps_begin and eps_end
		and ih.srvc_dt_end between eps_begin and eps_end
		where (fl_plcmnt_during_ihs <> 1 or fl_plcmnt_during_ihs is null)
		
		update  ih
		set fl_delete = 1
		---select state_custody_start_date,federal_discharge_date,ih.*
		from ##ihs_auths_dtl ih
		join ##eps
			 q on ih.id_case=q.id_case
		and ih.srvc_dt_begin between  eps_begin and eps_end
		and ih.srvc_dt_end between eps_begin and eps_end
		

	
/**************************************************************    get first start date for a unique END DATE  ***********************************/		
		
					if object_id('tempDB..#ihs') is not null drop table #ihs
					select 
					   id_case
					  ,min(min_id_authorization_fact) as min_id_authorization_fact
					  ,max(max_id_authorization_fact) as max_id_authorization_fact
					  ,sum(cnt_id_table_origin) as cnt_id_table_origin
					  ,min(srvc_dt_begin) as srvc_dt_begin 
					  ,srvc_dt_end
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,max(fl_plcmnt_prior_ihs) as fl_plcmnt_prior_ihs
					  ,max(fl_plcmnt_during_ihs) as fl_plcmnt_during_ihs
					  ,min(plcmnt_date) as plcmnt_date
					  ,min(cd_office) as cd_office
					  ,tx_office
					  ,sum(nbr_svc_authorized) as nbr_svc_authorized
					  ,sum([nbr_svc_paid]) as nbr_svc_paid
					  ,sum(total_amt_paid) as total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
					 , max(fl_family_focused_services) as fl_family_focused_services
					 , max(fl_child_care) as fl_child_care
					 , max(fl_therapeutic_services) as fl_therapeutic_services
					 , max(fl_mh_services) as fl_mh_services
					 , max(fl_receiving_care) as fl_receiving_care
					 , max(fl_family_home_placements) as fl_family_home_placements
					 , max(fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
					 , max(fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
					 , max(fl_specialty_adolescent_services) as fl_specialty_adolescent_services
					 , max(fl_respite) as fl_respite
					 , max(fl_transportation) as fl_transportation
					 , max(fl_clothing_incidentals) as fl_clothing_incidentals
					 , max(fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
					 , max(fl_adoption_support) as fl_adoption_support
					 , max(fl_various) as fl_various
					 , max(fl_medical) as fl_medical
					 , max(fl_budget_C12) as fl_budget_C12
					 , max(fl_budget_C14) as fl_budget_C14
					 , max(fl_budget_C15) as fl_budget_C15
					 , max(fl_budget_C16) as fl_budget_C16
					 , max(fl_budget_C18) as fl_budget_C18
					 , max(fl_budget_C19) as fl_budget_C19
					 , max(fl_budget_unpd) as fl_budget_unpd
					  ,max(fl_force_end_date) as fl_force_end_date
					  ,max(fl_force_begin_date) as fl_force_begin_date
					  ,tbl_origin
					  ,tbl_origin_cd
					into #ihs
					from ##ihs_auths_all
					group by id_case
							,srvc_dt_end
							,tx_office
							,case_sort
							,first_ihs_date
							,latest_ihs_date
							,most_exp_cd_srvc
							,most_exp_tx_srvc
							,total_most_exp_srvc
							,tbl_origin
							,tbl_origin_cd

	     truncate table ##ihs_auths_all

		 insert into ##ihs_auths_all
		 select * from #ihs
		 drop table #ihs

		
		
		update A1
		set case_sort=a2.row_num
		from ##ihs_auths_all a1
		join (select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* from ##ihs_auths_all) a2 
				on a2.min_id_authorization_fact=a1.min_id_authorization_fact 
				and a2.max_id_authorization_fact=a1.max_id_authorization_fact	
	
/**********************************************************    merge segments contained within prior  ***********************************/		
		
		
		set @row_num=1
		set nocount off
		
			set @row_num=1
			while @row_num > 0
			begin	
				if object_ID('tempDB..#segwi') is not null drop table #segwi
				select 1 as fl_curr,curr.*
				into #segwi
				from ##ihs_auths_all curr
				join ##ihs_auths_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				union 
				select 0, nxt.*
				from ##ihs_auths_all curr
				join ##ihs_auths_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				order by [id_case],[case_sort],fl_curr

				

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ihs_auths_all ih
				join #segwi s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.min_id_authorization_fact=ih.min_id_authorization_fact 
				and s.max_id_authorization_fact=ih.max_id_authorization_fact
				and s.srvc_dt_begin=ih.srvc_dt_begin 
				and s.srvc_dt_end=ih.srvc_dt_end

				-- now update end date 
				update curr
				set    max_id_authorization_fact=case when nxt.max_id_authorization_fact > curr.max_id_authorization_fact then nxt.max_id_authorization_fact else curr.max_id_authorization_fact end
					 , cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
					 , fl_family_focused_services=  case when nxt.fl_family_focused_services =1 then nxt.fl_family_focused_services else curr.fl_family_focused_services end
					 , fl_child_care=  case when nxt.fl_child_care =1 then nxt.fl_child_care else curr.fl_child_care end
					 , fl_therapeutic_services=  case when nxt.fl_therapeutic_services =1 then nxt.fl_therapeutic_services else curr.fl_therapeutic_services end
					 , fl_mh_services=  case when nxt.fl_mh_services =1 then nxt.fl_mh_services else curr.fl_mh_services end
					 , fl_receiving_care=  case when nxt.fl_receiving_care =1 then nxt.fl_receiving_care else curr.fl_receiving_care end
					 , fl_family_home_placements=  case when nxt.fl_family_home_placements =1 then nxt.fl_family_home_placements else curr.fl_family_home_placements end
					 , fl_behavioral_rehabiliation_services=  case when nxt.fl_behavioral_rehabiliation_services =1 then nxt.fl_behavioral_rehabiliation_services else curr.fl_behavioral_rehabiliation_services end
					 , fl_other_therapeutic_living_situations=  case when nxt.fl_other_therapeutic_living_situations =1 then nxt.fl_other_therapeutic_living_situations else curr.fl_other_therapeutic_living_situations end
					 , fl_specialty_adolescent_services=  case when nxt.fl_specialty_adolescent_services =1 then nxt.fl_specialty_adolescent_services else curr.fl_specialty_adolescent_services end
					 , fl_respite=  case when nxt.fl_respite =1 then nxt.fl_respite else curr.fl_respite end
					 , fl_transportation=  case when nxt.fl_transportation =1 then nxt.fl_transportation else curr.fl_transportation end
					 , fl_clothing_incidentals=  case when nxt.fl_clothing_incidentals =1 then nxt.fl_clothing_incidentals else curr.fl_clothing_incidentals end
					 , fl_sexually_aggressive_youth=  case when nxt.fl_sexually_aggressive_youth =1 then nxt.fl_sexually_aggressive_youth else curr.fl_sexually_aggressive_youth end
					 , fl_adoption_support=  case when nxt.fl_adoption_support =1 then nxt.fl_adoption_support else curr.fl_adoption_support end
					 , fl_various=  case when nxt.fl_various =1 then nxt.fl_various else curr.fl_various end
					 , fl_medical=  case when nxt.fl_medical =1 then nxt.fl_medical else curr.fl_medical end
					 , fl_budget_C12=  case when nxt.fl_budget_C12 =1 then nxt.fl_budget_C12 else curr.fl_budget_C12 end
					 , fl_budget_C14=  case when nxt.fl_budget_C14 =1 then nxt.fl_budget_C14 else curr.fl_budget_C14 end
					 , fl_budget_C15=  case when nxt.fl_budget_C15 =1 then nxt.fl_budget_C15 else curr.fl_budget_C15 end
					 , fl_budget_C16=  case when nxt.fl_budget_C16 =1 then nxt.fl_budget_C16 else curr.fl_budget_C16 end
					 , fl_budget_C18=  case when nxt.fl_budget_C18 =1 then nxt.fl_budget_C18 else curr.fl_budget_C18 end
					 , fl_budget_C19=  case when nxt.fl_budget_C19 =1 then nxt.fl_budget_C19 else curr.fl_budget_C19 end
					 , fl_budget_unpd=  case when nxt.fl_budget_unpd =1 then nxt.fl_budget_unpd else curr.fl_budget_unpd end
 					 , total_amt_paid = curr.total_amt_paid +  case when dup.id_case is null then nxt.total_amt_paid else 0 end
					 , nbr_svc_authorized = curr.nbr_svc_authorized +  case when dup.id_case is null then nxt.nbr_svc_authorized else 0 end
					 , nbr_svc_paid=curr.nbr_svc_paid +  case when dup.id_case is null then nxt.nbr_svc_paid else 0 end
					 , fl_plcmnt_during_ihs = case when nxt.fl_plcmnt_during_ihs = 1 then nxt.fl_plcmnt_during_ihs else curr.fl_plcmnt_during_ihs end
					 , fl_force_end_date = nxt.fl_force_end_date 
					 , plcmnt_date=case when nxt.plcmnt_date is not null then nxt.plcmnt_date else curr.plcmnt_date end
				from #segwi curr
				join #segwi nxt on curr.id_case=nxt.id_case and curr.case_sort + 1 =nxt.case_sort
				left join #segwi dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				and curr.fl_curr=1 and nxt.fl_curr=0


				insert into ##ihs_auths_all
				select 
					   id_case
					  ,min_id_authorization_fact
					  ,max_id_authorization_fact
					  ,cnt_id_table_origin
					  ,srvc_dt_begin
					  ,srvc_dt_end
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,fl_plcmnt_prior_ihs
					  ,fl_plcmnt_during_ihs
					  ,plcmnt_date
					  ,cd_office
					  ,tx_office
					  ,nbr_svc_authorized
					  ,[nbr_svc_paid]
					  ,total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
					  ,fl_family_focused_services
					  ,fl_child_care
					  ,fl_therapeutic_services
					  ,fl_mh_services
					  ,fl_receiving_care
					  ,fl_family_home_placements
					  ,fl_behavioral_rehabiliation_services
					  ,fl_other_therapeutic_living_situations
					  ,fl_specialty_adolescent_services
					  ,fl_respite
					  ,fl_transportation
					  ,fl_clothing_incidentals
					  ,fl_sexually_aggressive_youth
					  ,fl_adoption_support
					  ,fl_various
					  ,fl_medical
					  ,fl_budget_C12
					  ,fl_budget_C14
					  ,fl_budget_C15
					  ,fl_budget_C16
					  ,fl_budget_C18
					  ,fl_budget_C19
					  ,fl_budget_unpd
					  --,cd_asgn_type
					  --,tx_asgn_type
					  ,fl_force_end_date
					  ,fl_force_begin_date
					  ,tbl_origin
					  ,tbl_origin_cd		
				from #segwi where fl_curr=1




				update ihs
						set case_sort=q.row_num
						from ##ihs_auths_all ihs
						join 	(select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* 
							from ##ihs_auths_all
							) q on q.min_id_authorization_fact=ihs.min_id_authorization_fact
									and q.max_id_authorization_fact=ihs.max_id_authorization_fact
		end		
		
		

/**************************************************************************************    merge overlapping segments  ***********************************/

--		declare @row_num int
		set @row_num=1
		set nocount off
		
			set @row_num=1
			while @row_num > 0
			begin	
				if object_ID('tempDB..#seg') is not null drop table #seg
				select 1 as fl_curr,curr.*
				into #seg
				from ##ihs_auths_all curr
				join ##ihs_auths_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				union 
				select 0, nxt.*
				from ##ihs_auths_all curr
				join ##ihs_auths_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				order by [id_case],[case_sort],fl_curr

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ihs_auths_all ih
				join #seg s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.min_id_authorization_fact=ih.min_id_authorization_fact 
				and s.max_id_authorization_fact=ih.max_id_authorization_fact
				and s.srvc_dt_begin=ih.srvc_dt_begin 
				and s.srvc_dt_end=ih.srvc_dt_end

				-- now update end date 
				update curr
				set    max_id_authorization_fact=case when nxt.max_id_authorization_fact > curr.max_id_authorization_fact then nxt.max_id_authorization_fact else curr.max_id_authorization_fact end
					 , cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
					 , srvc_dt_end=nxt.srvc_dt_end
					 , fl_family_focused_services=  case when nxt.fl_family_focused_services =1 then nxt.fl_family_focused_services else curr.fl_family_focused_services end
					 , fl_child_care=  case when nxt.fl_child_care =1 then nxt.fl_child_care else curr.fl_child_care end
					 , fl_therapeutic_services=  case when nxt.fl_therapeutic_services =1 then nxt.fl_therapeutic_services else curr.fl_therapeutic_services end
					 , fl_mh_services=  case when nxt.fl_mh_services =1 then nxt.fl_mh_services else curr.fl_mh_services end
					 , fl_receiving_care=  case when nxt.fl_receiving_care =1 then nxt.fl_receiving_care else curr.fl_receiving_care end
					 , fl_family_home_placements=  case when nxt.fl_family_home_placements =1 then nxt.fl_family_home_placements else curr.fl_family_home_placements end
					 , fl_behavioral_rehabiliation_services=  case when nxt.fl_behavioral_rehabiliation_services =1 then nxt.fl_behavioral_rehabiliation_services else curr.fl_behavioral_rehabiliation_services end
					 , fl_other_therapeutic_living_situations=  case when nxt.fl_other_therapeutic_living_situations =1 then nxt.fl_other_therapeutic_living_situations else curr.fl_other_therapeutic_living_situations end
					 , fl_specialty_adolescent_services=  case when nxt.fl_specialty_adolescent_services =1 then nxt.fl_specialty_adolescent_services else curr.fl_specialty_adolescent_services end
					 , fl_respite=  case when nxt.fl_respite =1 then nxt.fl_respite else curr.fl_respite end
					 , fl_transportation=  case when nxt.fl_transportation =1 then nxt.fl_transportation else curr.fl_transportation end
					 , fl_clothing_incidentals=  case when nxt.fl_clothing_incidentals =1 then nxt.fl_clothing_incidentals else curr.fl_clothing_incidentals end
					 , fl_sexually_aggressive_youth=  case when nxt.fl_sexually_aggressive_youth =1 then nxt.fl_sexually_aggressive_youth else curr.fl_sexually_aggressive_youth end
					 , fl_adoption_support=  case when nxt.fl_adoption_support =1 then nxt.fl_adoption_support else curr.fl_adoption_support end
					 , fl_various=  case when nxt.fl_various =1 then nxt.fl_various else curr.fl_various end
					 , fl_medical=  case when nxt.fl_medical =1 then nxt.fl_medical else curr.fl_medical end
					 , fl_budget_C12=  case when nxt.fl_budget_C12 =1 then nxt.fl_budget_C12 else curr.fl_budget_C12 end
					 , fl_budget_C14=  case when nxt.fl_budget_C14 =1 then nxt.fl_budget_C14 else curr.fl_budget_C14 end
					 , fl_budget_C15=  case when nxt.fl_budget_C15 =1 then nxt.fl_budget_C15 else curr.fl_budget_C15 end
					 , fl_budget_C16=  case when nxt.fl_budget_C16 =1 then nxt.fl_budget_C16 else curr.fl_budget_C16 end
					 , fl_budget_C18=  case when nxt.fl_budget_C18 =1 then nxt.fl_budget_C18 else curr.fl_budget_C18 end
					 , fl_budget_C19=  case when nxt.fl_budget_C19 =1 then nxt.fl_budget_C19 else curr.fl_budget_C19 end
					 , fl_budget_unpd=  case when nxt.fl_budget_unpd =1 then nxt.fl_budget_unpd else curr.fl_budget_unpd end
 					 , total_amt_paid = curr.total_amt_paid +  case when dup.id_case is null then nxt.total_amt_paid else 0 end
					 , nbr_svc_authorized = curr.nbr_svc_authorized +  case when dup.id_case is null then nxt.nbr_svc_authorized else 0 end
					 , nbr_svc_paid=curr.nbr_svc_paid +  case when dup.id_case is null then nxt.nbr_svc_paid else 0 end
					 , fl_plcmnt_during_ihs = case when nxt.fl_plcmnt_during_ihs = 1 then nxt.fl_plcmnt_during_ihs else curr.fl_plcmnt_during_ihs end
					 , fl_force_end_date = nxt.fl_force_end_date 
					 , plcmnt_date=case when nxt.plcmnt_date is not null then nxt.plcmnt_date else curr.plcmnt_date end
				from #seg curr
				join #seg nxt on curr.id_case=nxt.id_case and curr.case_sort + 1 =nxt.case_sort 
				left join #seg dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				and curr.fl_curr=1 and nxt.fl_curr=0


				insert into ##ihs_auths_all
				select 
					   id_case
					  ,min_id_authorization_fact
					  ,max_id_authorization_fact
					  ,cnt_id_table_origin
					  ,srvc_dt_begin
					  ,srvc_dt_end
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,fl_plcmnt_prior_ihs
					  ,fl_plcmnt_during_ihs
					  ,plcmnt_date
					  ,cd_office
					  ,tx_office
					  ,nbr_svc_authorized
					  ,[nbr_svc_paid]
					  ,total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
					  ,fl_family_focused_services
					  ,fl_child_care
					  ,fl_therapeutic_services
					  ,fl_mh_services
					  ,fl_receiving_care
					  ,fl_family_home_placements
					  ,fl_behavioral_rehabiliation_services
					  ,fl_other_therapeutic_living_situations
					  ,fl_specialty_adolescent_services
					  ,fl_respite
					  ,fl_transportation
					  ,fl_clothing_incidentals
					  ,fl_sexually_aggressive_youth
					  ,fl_adoption_support
					  ,fl_various
					  ,fl_medical
					  ,fl_budget_C12
					  ,fl_budget_C14
					  ,fl_budget_C15
					  ,fl_budget_C16
					  ,fl_budget_C18
					  ,fl_budget_C19
					  ,fl_budget_unpd
					  --,cd_asgn_type
					  --,tx_asgn_type
					  ,fl_force_end_date
					  ,fl_force_begin_date
					  ,tbl_origin
					  ,tbl_origin_cd		
				from #seg where fl_curr=1

				update ihs
						set case_sort=q.row_num
						from ##ihs_auths_all ihs
						join 	(select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* 
							from ##ihs_auths_all
							) q on q.min_id_authorization_fact=ihs.min_id_authorization_fact
									and q.max_id_authorization_fact=ihs.max_id_authorization_fact
		end

		UPDATE IH
		 SET cd_office = ld.cd_office
				,tx_office =ld.tx_office
		 FROM ##ihs_auths_all IH
		 join ca.authorization_fact af on ih.min_id_authorization_fact=af.id_authorization_fact
			left join ca.location_dim ld on ld.id_location_dim=af.id_location_dim
----------------------------------------------------------------------------------------- clean up
		
		delete  from ##ihs_auths_dtl where fl_delete=1
		
		
		
	
/******************************************************************************************  FINAL TABLE **/

				
				if OBJECT_ID('tempDB..##tbl_ihs_episodes') is not null drop table ##tbl_ihs_episodes
				select cast(null as int) as id_ihs_episode,*,0 as dtl_min_id_authorization_fact
				,0 as dtl_max_id_authorization_fact
				,cast(null as int) as id_intake_fact
				,cast(null as int) as cd_sib_age_grp
				,cast(null as int) as cd_race_census_hh
				,cast(null as int) as census_hispanic_latino_origin_cd
				into ##tbl_ihs_episodes
				from ##ih_assgn_all

				alter table ##tbl_ihs_episodes
				alter column id_case int not null

				alter table ##tbl_ihs_episodes
				alter column ihs_begin_date datetime not null
	
				alter table ##tbl_ihs_episodes
				add primary key (id_case,ihs_begin_date)


				CREATE NONCLUSTERED INDEX idx_temp_case_id_inc_dates
				ON ##tbl_ihs_episodes ([id_case],[id_table_origin],[max_id_table_origin])
				INCLUDE ([ihs_begin_date],[ihs_end_date])

				-- update authorizations contained within assignment start and stop date
				update ihs
				set   dtl_min_id_authorization_fact=auth.min_id_authorization_fact
					, dtl_max_id_authorization_fact=auth.max_id_authorization_fact
					 , most_exp_cd_srvc = null --authcd.most_exp_cd_srvc
					 , most_exp_tx_srvc=null --authcd.most_exp_tx_srvc
					 , total_most_exp_srvc = null --auth.total_most_exp_srvc
					 , total_amt_paid=auth.total_amt_paid
					 , nbr_svc_authorized=auth.nbr_svc_authorized
					 , nbr_svc_paid=auth.nbr_svc_paid
					 , fl_family_focused_services = auth.fl_family_focused_services
					 , fl_child_care = auth.fl_child_care
					 , fl_therapeutic_services = auth.fl_therapeutic_services
					 , fl_mh_services = auth.fl_mh_services
					 , fl_receiving_care = auth.fl_receiving_care
					 , fl_family_home_placements = auth.fl_family_home_placements
					 , fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					 , fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					 , fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					 , fl_respite = auth.fl_respite
					 , fl_transportation = auth.fl_transportation
					 , fl_clothing_incidentals = auth.fl_clothing_incidentals
					 , fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					 , fl_adoption_support = auth.fl_adoption_support
					 , fl_various = auth.fl_various
					 , fl_medical = auth.fl_medical
					 , fl_budget_C12 = auth.fl_budget_C12
					 , fl_budget_C14 = auth.fl_budget_C14
					 , fl_budget_C15 = auth.fl_budget_C15
					 , fl_budget_C16 = auth.fl_budget_C16
					 , fl_budget_C18 = auth.fl_budget_C18
					 , fl_budget_C19 = auth.fl_budget_C19
					 , fl_budget_unpd = auth.fl_budget_unpd
					 , tbl_origin_cd=3
					 , tbl_origin='both'
				from ##tbl_ihs_episodes ihs
				join  (select	ihs.id_case
							,ihs.ihs_begin_date
							,ihs.ihs_end_date
							, min(min_id_authorization_fact) as min_id_authorization_fact
							, max(max_id_authorization_fact) as max_id_authorization_fact
							 , sum(auth.total_amt_paid) as total_amt_paid
							 , sum(auth.nbr_svc_authorized) as nbr_svc_authorized
							 , sum(auth.nbr_svc_paid) as nbr_svc_paid
							 , max(auth.fl_family_focused_services) as fl_family_focused_services
							 , max(auth.fl_child_care) as fl_child_care
							 , max(auth.fl_therapeutic_services) as fl_therapeutic_services
							 , max(auth.fl_mh_services) as fl_mh_services
							 , max(auth.fl_receiving_care) as fl_receiving_care
							 , max(auth.fl_family_home_placements) as fl_family_home_placements
							 , max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							 , max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							 , max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							 , max(auth.fl_respite) as fl_respite
							 , max(auth.fl_transportation) as fl_transportation
							 , max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							 , max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							 , max(auth.fl_adoption_support) as fl_adoption_support
							 , max(auth.fl_various) as fl_various
							 , max(auth.fl_medical) as fl_medical
							 , max(auth.fl_budget_C12) as fl_budget_C12
							 , max(auth.fl_budget_C14) as fl_budget_C14
							 , max(auth.fl_budget_C15) as fl_budget_C15
							 , max(auth.fl_budget_C16) as fl_budget_C16
							 , max(auth.fl_budget_C18) as fl_budget_C18
							 , max(auth.fl_budget_C19) as fl_budget_C19
							 , max(auth.fl_budget_unpd) as fl_budget_unpd
						from ##tbl_ihs_episodes ihs
						join  ##ihs_auths_all  auth on auth.id_case=ihs.id_case 
							and auth.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
							and auth.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
						group by ihs.id_case
							,ihs.ihs_begin_date
							,ihs.ihs_end_date
					)  auth on auth.id_case=ihs.id_case 
					and ihs.ihs_begin_date=auth.ihs_begin_date
					and ihs.ihs_end_date=auth.ihs_end_date
			



				--insert those authorizations with no overlapping assignment dates
				insert into ##tbl_ihs_episodes
				select 
						cast(null as int)	 
					  , auth.id_case
					  , auth.min_id_authorization_fact
					  , auth.max_id_authorization_fact
					  , auth.cnt_id_table_origin
					  , auth.srvc_dt_begin
					  , auth.srvc_dt_end
					  , auth.case_sort
					  , auth.first_ihs_date
					  , auth.latest_ihs_date
					  , auth.fl_plcmnt_prior_ihs
					  , auth.fl_plcmnt_during_ihs
					  , auth.plcmnt_date
					  , auth.cd_office
					  , auth.tx_office
					  , auth.nbr_svc_authorized
					  , auth.nbr_svc_paid
					  , auth.total_amt_paid
					  , auth.most_exp_cd_srvc
					  , auth.most_exp_tx_srvc
					  , auth.total_most_exp_srvc
					  , auth.fl_family_focused_services
					  , auth.fl_child_care
					  , auth.fl_therapeutic_services
					  , auth.fl_mh_services
					  , auth.fl_receiving_care
					  , auth.fl_family_home_placements
					  , auth.fl_behavioral_rehabiliation_services
					  , auth.fl_other_therapeutic_living_situations
					  , auth.fl_specialty_adolescent_services
					  , auth.fl_respite
					  , auth.fl_transportation
					  , auth.fl_clothing_incidentals
					  , auth.fl_sexually_aggressive_youth
					  , auth.fl_adoption_support
					  , auth.fl_various
					  , auth.fl_medical
					  , auth.fl_budget_C12
					  , auth.fl_budget_C14
					  , auth.fl_budget_C15
					  , auth.fl_budget_C16
					  , auth.fl_budget_C18
					  , auth.fl_budget_C19
					  , auth.fl_budget_unpd
					  , null
					  , null
					  , auth.fl_force_end_date
					  , auth.fl_force_begin_date
					  , auth.tbl_origin
					  , auth.tbl_origin_cd	
				 	,min_id_authorization_fact
					,max_id_authorization_fact 
					,null
					,null
					,null
					,null
				from ##ihs_auths_all  auth
				left join ##tbl_ihs_episodes assg on auth.id_case=assg.id_case
					and auth.srvc_dt_begin between assg.ihs_begin_date and assg.ihs_end_date
					and auth.srvc_dt_end   between assg.ihs_begin_date and assg.ihs_end_date
				left join ##tbl_ihs_episodes assn on auth.id_case=assn.id_case
					and auth.srvc_dt_begin between assn.ihs_begin_date and assn.ihs_end_date
				left join ##tbl_ihs_episodes asst on auth.id_case=asst.id_case
					and auth.srvc_dt_end between asst.ihs_begin_date and asst.ihs_end_date
				left join ##tbl_ihs_episodes wi on auth.id_case=wi.id_case
					and auth.srvc_dt_end > wi.ihs_end_date 
					and auth.srvc_dt_begin < wi.ihs_begin_date 
				where (assg.id_case is null and assn.id_case is null and asst.id_case is null and wi.id_case is null)

			update eps
			set case_sort=q.row_num
			from ##tbl_ihs_episodes eps
			join (select row_number()  over (partition by id_case order by ihs_begin_date,ihs_end_date) as row_num,*
					from ##tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin





			-- force/lengthen ihs_end_date in order to associate services
			update ihs
			set   dtl_min_id_authorization_fact=auth.min_id_authorization_fact
				, dtl_max_id_authorization_fact=auth.max_id_authorization_fact
				, ihs_end_date=auth.srvc_dt_end
					, most_exp_cd_srvc = null
					, most_exp_tx_srvc=null
					, total_most_exp_srvc = null
					, total_amt_paid=auth.total_amt_paid
					, nbr_svc_authorized=auth.nbr_svc_authorized
					, nbr_svc_paid=auth.nbr_svc_paid
					, fl_family_focused_services = auth.fl_family_focused_services
					, fl_child_care = auth.fl_child_care
					, fl_therapeutic_services = auth.fl_therapeutic_services
					, fl_mh_services = auth.fl_mh_services
					, fl_receiving_care = auth.fl_receiving_care
					, fl_family_home_placements = auth.fl_family_home_placements
					, fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					, fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					, fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					, fl_respite = auth.fl_respite
					, fl_transportation = auth.fl_transportation
					, fl_clothing_incidentals = auth.fl_clothing_incidentals
					, fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					, fl_adoption_support = auth.fl_adoption_support
					, fl_various = auth.fl_various
					, fl_medical = auth.fl_medical
					, fl_budget_C12 = auth.fl_budget_C12
					, fl_budget_C14 = auth.fl_budget_C14
					, fl_budget_C15 = auth.fl_budget_C15
					, fl_budget_C16 = auth.fl_budget_C16
					, fl_budget_C18 = auth.fl_budget_C18
					, fl_budget_C19 = auth.fl_budget_C19
					, fl_budget_unpd = auth.fl_budget_unpd
					, tbl_origin_cd=3
					, tbl_origin='both'
			--select ihs.ihs_begin_date,ihs.ihs_end_date,auth.*
			from ##tbl_ihs_episodes ihs
			join  (select	ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date
						, max(auth.srvc_dt_end) as srvc_dt_end
						, min(auth.min_id_authorization_fact) as min_id_authorization_fact
						, max(auth.max_id_authorization_fact) as max_id_authorization_fact
							, sum(auth.total_amt_paid) as total_amt_paid
							, sum(auth.nbr_svc_authorized) as nbr_svc_authorized
							, sum(auth.nbr_svc_paid) as nbr_svc_paid
							, max(auth.total_most_exp_srvc) as total_most_exp_srvc
							, max(auth.fl_family_focused_services) as fl_family_focused_services
							, max(auth.fl_child_care) as fl_child_care
							, max(auth.fl_therapeutic_services) as fl_therapeutic_services
							, max(auth.fl_mh_services) as fl_mh_services
							, max(auth.fl_receiving_care) as fl_receiving_care
							, max(auth.fl_family_home_placements) as fl_family_home_placements
							, max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							, max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							, max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							, max(auth.fl_respite) as fl_respite
							, max(auth.fl_transportation) as fl_transportation
							, max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							, max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							, max(auth.fl_adoption_support) as fl_adoption_support
							, max(auth.fl_various) as fl_various
							, max(auth.fl_medical) as fl_medical
							, max(auth.fl_budget_C12) as fl_budget_C12
							, max(auth.fl_budget_C14) as fl_budget_C14
							, max(auth.fl_budget_C15) as fl_budget_C15
							, max(auth.fl_budget_C16) as fl_budget_C16
							, max(auth.fl_budget_C18) as fl_budget_C18
							, max(auth.fl_budget_C19) as fl_budget_C19
							, max(auth.fl_budget_unpd) as fl_budget_unpd
					from ##tbl_ihs_episodes ihs
					left join  ##ihs_auths_all  aut on aut.id_case=ihs.id_case 
						and aut.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
						and aut.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
					left join ##ihs_auths_all auth on ihs.id_case=auth.id_case
		  				and auth.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
												and auth.srvc_dt_end > ihs.ihs_end_date
					left join ##tbl_ihs_episodes ihs2 on ihs2.id_case=ihs.id_case
						and ihs2.case_sort=ihs.case_sort + 1 
									
					where aut.id_case is null  and auth.id_case is not null 
					and (ihs2.id_case is null or  (ihs2.id_case is not null and ihs2.ihs_begin_date
						> auth.srvc_dt_end))
					group by ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date	
										)  auth on auth.id_case=ihs.id_case 
										and ihs.ihs_begin_date=auth.ihs_begin_date
										and ihs.ihs_end_date=auth.ihs_end_date

				

/**************************************************************************             unique id_ihs_episode   **/
			update eps
			set id_ihs_episode=q.row_num
			from ##tbl_ihs_episodes eps
			join (select row_number()  over (order by id_case,ihs_begin_date,ihs_end_date) as row_num,*
					from ##tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin


			update dtl
			set id_ihs_episode = null
			from ##ihs_auths_dtl dtl

			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_auths_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.srvc_dt_end between eps.ihs_begin_date and eps.ihs_end_date

			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_auths_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.id_ihs_episode is null


			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_auths_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_end between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.id_ihs_episode is null

			update dtl
			set id_ihs_episode = lrgseg.id_ihs_episode
			from ##ihs_auths_dtl dtl
			join ##ihs_auths_dtl lrgseg on dtl.id_case=lrgseg.id_case
			and dtl.srvc_dt_begin between lrgseg.srvc_dt_begin and  lrgseg.srvc_dt_end
			and dtl.srvc_dt_end between lrgseg.srvc_dt_begin and  lrgseg.srvc_dt_end
			where dtl.id_ihs_episode is null and lrgseg.id_ihs_episode is not null


			-- only want detail rolling up to one episode
			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_auths_dtl dtl
			join (
			select eps.id_ihs_episode ,eps.ihs_begin_date,eps.ihs_end_date,dtl.dtl_id_authorization_fact,row_number() over
			(partition by dtl_id_authorization_fact,auth.srvc_dt_begin order by ihs_begin_date asc) as row_num
			from ##ihs_auths_dtl dtl
			join ##ihs_auths_all auth on auth.id_case=dtl.id_case 
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and eps.ihs_begin_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and eps.ihs_end_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and dtl.id_ihs_episode is null
				and eps.plcmnt_date is null
				-- where dtl_id_authorization_fact in (8828632,9861488,9868174,10308943,10348044)
				) eps 
				on eps.dtl_id_authorization_fact=dtl.dtl_id_authorization_fact
			where row_num=1 and dtl.id_ihs_episode is null
				
			
			delete from ##ihs_auths_dtl where id_ihs_episode is null

			-- these are end dated placements	
			

	CREATE NONCLUSTERED INDEX  idx_id_ihs_episodes
		ON ##tbl_ihs_episodes ([id_ihs_episode])
	
	

	-- update most expensive
			update ihs
			set   most_exp_cd_srvc = q.cd_srvc
					, most_exp_tx_srvc=q.tx_srvc
					, total_most_exp_srvc = q.total_most_exp_srvc	
			from ##tbl_ihs_episodes ihs
			join (
				select auth.*,row_number() over( partition by ihs.id_case,ihs.ihs_begin_date
							,ihs.ihs_end_date order by auth.total_most_exp_srvc desc) as row_sort
				from ##tbl_ihs_episodes ihs
				join  (
						select	ihs.id_ihs_episode
								, auth.cd_srvc
								, auth.tx_srvc
 								, sum(auth.am_total_paid) as total_most_exp_srvc
						from ##tbl_ihs_episodes ihs
							join  ##ihs_auths_dtl  auth on auth.id_ihs_episode=ihs.id_ihs_episode 
						--where ihs.id_case=81785 and id_table_origin=8200531 and max_id_table_origin=8483336
					--	where ihs.id_case=553396
					  where auth.cd_auth_status=2
					  and auth.id_ihs_episode is not null
						group by ihs.id_ihs_episode
								, auth.cd_srvc
								, auth.tx_srvc
											)  auth 
											 on auth.id_ihs_episode=ihs.id_ihs_episode 
							
				) q on q.id_ihs_episode=ihs.id_ihs_episode
						and q.row_sort=1



		



		update IH
		set total_amt_paid=q.total_amt_paid
			,nbr_svc_authorized=q.nbr_svc_authorized
			,nbr_svc_paid=q.nbr_svc_paid
			,dtl_min_id_authorization_fact=q.min_id_authorization_fact
			,dtl_max_id_authorization_fact=q.max_id_authorization_fact
			,cnt_id_table_origin = case when tbl_origin_cd=2 then q.cnt_id_table_origin else ih.cnt_id_table_origin end
		--select q.*,ih.*
		from ##tbl_ihs_episodes IH
		join (select dtl.id_case,ih.id_ihs_episode
				,sum(case when dtl.cd_auth_status in (1,2) then 1 else 0 end) as nbr_svc_authorized
						,sum(case when dtl.cd_auth_status =2 then 1 else 0 end) as nbr_svc_paid
						,sum(case when dtl.cd_auth_status = 2 then dtl.am_total_paid else 0 end) as total_amt_paid
						,count(distinct dtl.dtl_id_authorization_fact) as cnt_id_table_origin
						,min(dtl.dtl_id_authorization_fact) as min_id_authorization_fact
						,max(dtl.dtl_id_authorization_fact) as max_id_authorization_fact
			FROM ##tbl_ihs_episodes ih
			join ##ihs_auths_dtl dtl on ih.id_ihs_episode=dtl.id_ihs_episode 
			where dtl.id_ihs_episode is not null
			group by dtl.id_case,ih.id_ihs_episode
			) q	on q.id_case=ih.id_case and q.id_ihs_episode=ih.id_ihs_episode

--		 where q.id_case=39486 and ih.id_case=39486



		update eps
		set first_ihs_date=frst_date,latest_ihs_date=last_date,fl_plcmnt_prior_ihs=isnull(eps.fl_plcmnt_prior_ihs,0)
			,fl_plcmnt_during_ihs=isnull(fl_plcmnt_during_ihs,0)
		from ##tbl_ihs_episodes eps
		join (select id_case, min(ihs_begin_date) as frst_date
			   , max(ihs_begin_date) as last_date
			   from ##tbl_ihs_episodes
			   group by id_case) q on q.id_case=eps.id_case

		update eps
		set id_intake_fact=null  --  q.id_intake_fact
		from ##tbl_ihs_episodes eps

		update eps
		set id_intake_fact=q.id_intake_fact
			, cd_sib_age_grp=q.cd_sib_age_grp
			, cd_race_census_hh=q.cd_race_census
			, census_hispanic_latino_origin_cd=q.census_hispanic_latino_origin_cd
		from ##tbl_ihs_episodes eps
		join (		
			select datediff(dd,inv_ass_start,ihs_begin_date)  as diff_days_intk_ihs
				, intk.inv_ass_start
				, intk.inv_ass_stop 
				, intk.id_intake_fact
				, intk.cd_sib_age_grp
				, intk.cd_race_census
				, intk.census_hispanic_latino_origin_cd
				, eps.id_ihs_episode
				, eps.id_case
				, eps.ihs_begin_date
				, eps.ihs_end_date
				, row_number() over (partition by eps.id_ihs_episode,eps.id_case
					 order by datediff(dd,inv_ass_start,ihs_begin_date)  asc ) as case_intk_sort
			from ##tbl_ihs_episodes eps join tbl_intakes intk
				on intk.id_case=eps.id_case
					and intk.cd_final_decision=1
					and intk.fl_reopen_case=0
			where  inv_ass_start < =ihs_begin_date
					and ((intk.CD_INVS_DISP IN (3,4) and intk.cd_asgn_type=4 ) or intk.cd_asgn_type in (9,8,5))
					) q on q.id_case=eps.id_case and q.id_ihs_episode=eps.id_ihs_episode
		where q.case_intk_sort=1 and diff_days_intk_ihs between 0 and 183




if object_ID(N'tbl_ihs_episodes',N'U') is not null  truncate table tbl_ihs_episodes;
insert into dbo.tbl_ihs_episodes(
[id_ihs_episode]
      ,[id_case]
      ,[case_sort]
      ,[ihs_begin_date]
      ,[ihs_end_date]
      ,[first_ihs_date]
      ,[latest_ihs_date]
      ,[cd_office]
      ,[tx_office]
      ,[fl_plcmnt_prior_ihs]
      ,[fl_plcmnt_during_ihs]
      ,[plcmnt_date]
      ,[nbr_svc_authorized]
      ,[nbr_svc_paid]
      ,[total_amt_paid]
      ,[most_exp_cd_srvc]
      ,[most_exp_tx_srvc]
      ,[total_most_exp_srvc]
      ,[fl_family_focused_services]
      ,[fl_child_care]
      ,[fl_therapeutic_services]
      ,[fl_mh_services]
      ,[fl_receiving_care]
      ,[fl_family_home_placements]
      ,[fl_behavioral_rehabiliation_services]
      ,[fl_other_therapeutic_living_situations]
      ,[fl_specialty_adolescent_services]
      ,[fl_respite]
      ,[fl_transportation]
      ,[fl_clothing_incidentals]
      ,[fl_sexually_aggressive_youth]
      ,[fl_adoption_support]
      ,[fl_various]
      ,[fl_medical]
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      ,[fl_budget_C15]
      ,[fl_budget_C16]
      ,[fl_budget_C18]
      ,[fl_budget_C19]
      ,[fl_budget_unpd]
      ,[cd_asgn_type]
      ,[tx_asgn_type]
      ,[fl_force_begin_date]
      ,[fl_force_end_date]
      ,[min_id_table_origin]
      ,[max_id_table_origin]
      ,[cnt_id_table_origin]
      ,[dtl_min_id_authorization_fact]
      ,[dtl_max_id_authorization_fact]
      ,[tbl_origin]
      ,[tbl_origin_cd]
      ,[id_intake_fact]
	  ,cd_sib_age_grp
	  ,cd_race_census_hh
	  ,census_hispanic_latino_origin_cd_hh)
SELECT id_ihs_episode
      ,[id_case]
      ,[case_sort]
      ,[ihs_begin_date]
      ,[ihs_end_date]
      ,[first_ihs_date]
      ,[latest_ihs_date]
      ,[cd_office]
      ,[tx_office]
      ,[fl_plcmnt_prior_ihs]
      ,[fl_plcmnt_during_ihs]
      ,[plcmnt_date]
      ,[nbr_svc_authorized]
      ,[nbr_svc_paid]
      ,[total_amt_paid]
      ,[most_exp_cd_srvc]
      ,[most_exp_tx_srvc]
      ,[total_most_exp_srvc]
      ,[fl_family_focused_services]
      ,[fl_child_care]
      ,[fl_therapeutic_services]
      ,[fl_mh_services]
      ,[fl_receiving_care]
      ,[fl_family_home_placements]
      ,[fl_behavioral_rehabiliation_services]
      ,[fl_other_therapeutic_living_situations]
      ,[fl_specialty_adolescent_services]
      ,[fl_respite]
      ,[fl_transportation]
      ,[fl_clothing_incidentals]
      ,[fl_sexually_aggressive_youth]
      ,[fl_adoption_support]
      ,[fl_various]
      ,[fl_medical]
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      ,[fl_budget_C15]
      ,[fl_budget_C16]
      ,[fl_budget_C18]
      ,[fl_budget_C19]
      ,[fl_budget_unpd]
      ,[cd_asgn_type]
      ,[tx_asgn_type]
      ,[fl_force_begin_date]
      ,[fl_force_end_date]
      ,[id_table_origin]
      ,[max_id_table_origin]
      ,[cnt_id_table_origin]
      ,[dtl_min_id_authorization_fact]
      ,[dtl_max_id_authorization_fact]
      ,[tbl_origin]
      ,[tbl_origin_cd]
      ,[id_intake_fact]
	  ,cd_sib_age_grp
	  ,cd_race_census_hh
	  ,census_hispanic_latino_origin_cd
  FROM ##tbl_ihs_episodes 


  

if object_ID(N'tbl_ihs_services',N'U') is not null  truncate table tbl_ihs_services;
insert into dbo.tbl_ihs_services
([id_ihs_episode]
      ,[dtl_id_authorization_fact]
      ,[id_case]
      ,[id_prsn_child]
      ,[child_age]
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_auth_status]
      ,[tx_auth_status]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
      ,[id_chart_of_accounts_dim]
      ,[id_source_funds_dim]
      ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      ,[dur_days]
      ,[ihs_rank]
	  ,fl_no_auth)
select [id_ihs_episode]
      ,[dtl_id_authorization_fact]
      ,[id_case]
      ,[id_prsn_child]
      ,[child_age]
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_auth_status]
      ,[tx_auth_status]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
      ,[id_chart_of_accounts_dim]
      ,[id_source_funds_dim]
      ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      , case when srvc_dt_end is not null and srvc_dt_end <> '12/31/3999' then datediff(dd,[srvc_dt_begin],[srvc_dt_end]) else null end
      , rank() over (partition by id_case order by srvc_dt_begin) as [ihs_rank]
	  ,0
	from ##ihs_auths_dtl
	

	



declare @max_auth_id int
select @max_auth_id=max(id_authorization_fact) from ca.authorization_fact

insert into dbo.tbl_ihs_services
([id_ihs_episode]
      ,[dtl_id_authorization_fact]
      ,[id_case]
      ,[id_prsn_child]
      ,[child_age]
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_auth_status]
      ,[tx_auth_status]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
      ,[id_chart_of_accounts_dim]
      ,[id_source_funds_dim]
      ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      ,[dur_days]
      ,[ihs_rank]
	  ,fl_no_auth)
select eps.[id_ihs_episode]
      ,@max_auth_id + eps.[id_ihs_episode]
      ,[id_case]
      ,null
      ,null
      ,ihs_begin_date
      ,ihs_end_date
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      , null
      , 1
	  , 1
	from dbo.tbl_ihs_episodes eps
	join (select id_ihs_episode from dbo.tbl_ihs_episodes 
		except 
		select id_ihs_episode from dbo.tbl_ihs_services) q on q.id_ihs_episode=eps.id_ihs_episode


-- now delete any ihs episodes that are contained within an out of home care episode
if object_id('tempDB..#tmp_ihs_eps') is not null drop table #tmp_ihs_eps
select id_ihs_episode 
into #tmp_ihs_eps 
from tbl_ihs_episodes ihs  
join tbl_child_episodes tce on tce.id_case=ihs.id_case
and tce.state_custody_start_date < ihs.ihs_end_date
and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
union
select id_ihs_episode 
from tbl_ihs_episodes ihs  
join tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
and tce.state_custody_start_date < ihs.ihs_end_date
and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 

--and (ihs_begin_date between state_custody_start_date and isnull(federal_discharge_date,'12/31/3999')
--and ihs_end_date  between state_custody_start_date and isnull(federal_discharge_date,'12/31/3999'))
--union
--select id_ihs_episode from tbl_ihs_episodes ihs  join tbl_child_episodes tce on tce.id_case=ihs.id_case
--and tce.state_custody_start_date < ihs.ihs_end_date
--and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date
--and NOT(ihs_begin_date between state_custody_start_date and isnull(federal_discharge_date,'12/31/3999')
--and (ihs_end_date  between state_custody_start_date and isnull(federal_discharge_date,'12/31/3999')))

delete eps from tbl_ihs_episodes eps
join #tmp_ihs_eps ihs on eps.id_ihs_episode=ihs.id_ihs_episode


delete dtl from tbl_ihs_services dtl
join #tmp_ihs_eps ihs on dtl.id_ihs_episode=ihs.id_ihs_episode

update statistics tbl_ihs_episodes

update statistics tbl_ihs_services

--select eps.id_ihs_episode,hdr_paid,dtl_paid
--from (select cast((eps.total_amt_paid) as numeric(18,2)) as hdr_paid,eps.id_ihs_episode from tbl_ihs_episodes eps ) eps
--join (select id_ihs_episode, cast(sum(srv.am_total_paid) as numeric(18,2)) as dtl_paid from tbl_ihs_services srv 
--	  where cd_auth_status=2 group by srv.id_ihs_episode) q
--on q.id_ihs_episode=eps.id_ihs_episode
--where  dtl_paid <>hdr_paid


--if object_ID('tempDB..#yrmo') is not null drop table #yrmo	
--select distinct [month] as strt_dt, EOMONTH([month])  as end_dt,year([month]) * 100 + month([month]) as yrmo	
--into #yrmo	
--from ca.calendar_dim where id_calendar_dim between 20090101 and 20120601	
--order by [month]	
	
----select * from #yrmo	

--select mo.*,a.cnt_first,b.cnt_entries,c.cnt_exits
--from 
--(select 	
--	yrmo,count(*) as cnt_month_srvc
--from tbl_ihs_episodes eps	
--join #yrmo on ihs_begin_date <= end_dt	
--	and ihs_end_date >=strt_dt
--where id_intake_fact is not null	
--group by yrmo	
--) mo,
--(
--select 	
--	yrmo,count(*) as cnt_first
--from tbl_ihs_episodes eps	
--join #yrmo on ihs_begin_date < strt_dt	
--	and ihs_end_date >=strt_dt
--where id_intake_fact is not null	
--group by yrmo	
--	) a,
--(
--select year(ihs_begin_date) * 100 + month(ihs_begin_date) as yrmo,count(*) as cnt_entries
--from dbo.tbl_ihs_episodes
--where year(ihs_begin_date) * 100 + month(ihs_begin_date) >=200901 and id_intake_fact is not null
--group by year(ihs_begin_date) * 100 + month(ihs_begin_date)
--) b,
--(
--select year(ihs_end_date) * 100 + month(ihs_end_date) as yrmo,count(*) as cnt_exits
--from dbo.tbl_ihs_episodes
--where year(ihs_end_date) * 100 + month(ihs_end_date) >=200901 and id_intake_fact is not null
--group by year(ihs_end_date) * 100 + month(ihs_end_date)
--) c
--where  mo.yrmo=b.yrmo
--	and mo.yrmo=c.yrmo
--	and mo.yrmo=a.yrmo
--	order by mo.yrmo

end