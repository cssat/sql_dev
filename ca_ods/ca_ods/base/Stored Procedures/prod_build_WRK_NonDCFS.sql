
/*****************************************************************************************************************/
-- Script Title: WRK_nonDCFS.sql
-- Author: J Messerly (Transcribing spss code written by D. Marshall)
-- CHANGES  --- DATE:  BY:  Description:
-- DATE: 2012-08-02  BY: J.Messerly Description: ADDED FL_VOID=0 
/*****************************************************************************************************************/
CREATE procedure [base].[prod_build_WRK_NonDCFS](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin
		if object_ID('tempDB..#Auth' ) is not null drop table #Auth;
		SELECT distinct  ID_PLACEMENT_CARE_AUTH_FACT, ID_PLCMNT_CARE_AUTHORITY, ID_CALENDAR_DIM_BEGIN, 
			ID_CALENDAR_DIM_END, ID_PEOPLE_DIM, pcaf.ID_PLACEMENT_CARE_AUTH_DIM, ID_PRSN  ,CD_PLACEMENT_CARE_AUTH
		   ,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)  as cust_begin
		   ,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END)  as cust_end
		  ,case when ID_CALENDAR_DIM_END = 0 then 999999 else datediff(dd, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) ,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END) ) end as custlos
		  ,case when  CD_PLACEMENT_CARE_AUTH in (3,4,5,6,10,11) then 0 else 1 end as custc
		  ,cast(0 as int) as backtoDCFS
		  ,row_number() over (
					partition by ID_PRSN,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)
								order by ID_PRSN
								,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)  asc
								 ,case when ID_CALENDAR_DIM_END = 0 then 999999 
									 else datediff(dd, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) 
													,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END) ) end  desc--,CD_PLACEMENT_CARE_AUTH desc
												) as cust_order
			into #AUTH
			FROM   dbo.PLACEMENT_CARE_AUTH_FACT   pcaf
			join dbo.PLACEMENT_CARE_AUTH_DIM pcad on pcad.ID_PLACEMENT_CARE_AUTH_DIM=pcaf.ID_PLACEMENT_CARE_AUTH_DIM
			WHERE CD_PLACEMENT_CARE_AUTH <>-99 and ID_PRSN >=0 
				and dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)  is not null
				and ID_CALENDAR_DIM_BEGIN >=19980101
				and FL_VOID=0
			order by ID_PRSN,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)  asc
		    
			delete from  #AUTH where cust_order <> 1
		    
		    
		  update #AUTH
		  set custlos = null where custlos=999999;
		  
		  update q2
		  set backtoDCFS =1
		  from #AUTH A
		  join (
				select *
				,row_number() over (partition by id_prsn order by id_prsn,cust_begin desc) as auth_sort
				from #AUTH 
				) lag 		on lag.id_prsn=a.id_prsn 
		  join (
				select *
				,row_number() over (partition by id_prsn order by id_prsn,cust_begin desc) as auth_sort
				from #AUTH ) q2 on q2.id_prsn=a.id_prsn and q2.auth_sort=lag.auth_sort + 1
						and q2.ID_PLACEMENT_CARE_AUTH_DIM=A.ID_PLACEMENT_CARE_AUTH_DIM
		where lag.custc=1 and  q2.custc=0 and lag.CD_PLACEMENT_CARE_AUTH <> 1;

		  update q2
		  set backtoDCFS =1
		  from #AUTH A
		  join (
				select *
				,row_number() over (partition by id_prsn order by id_prsn,cust_begin desc) as auth_sort
				from #AUTH 
				) lag2 		on lag2.id_prsn=a.id_prsn 
		  join (
				select *
				,row_number() over (partition by id_prsn order by id_prsn,cust_begin desc) as auth_sort
				from #AUTH 
				) lag 		on lag.id_prsn=a.id_prsn  and lag.auth_sort = lag2.auth_sort + 1
		  join (
				select *
				,row_number() over (partition by id_prsn order by id_prsn,cust_begin desc) as auth_sort
				from #AUTH ) q2 on q2.id_prsn=a.id_prsn and q2.auth_sort=lag2.auth_sort + 2
						and q2.ID_PLACEMENT_CARE_AUTH_DIM=A.ID_PLACEMENT_CARE_AUTH_DIM
		where q2.custc=0 and lag2.custc = 1 and lag.CD_PLACEMENT_CARE_AUTH = 1;



		if object_id(N'base.WRK_nonDCFS_All',N'U') is not null drop table base.WRK_nonDCFS_All;
		select distinct ID_PRSN,CUST_BEGIN
				,CUST_END,backtoDCFS
				,CD_PLACEMENT_CARE_AUTH
				,case CD_PLACEMENT_CARE_AUTH when  1 then  'Closed'
						when  2 then 'DCFS'
						when 3 then 'Other State'
						when 4 then 'Private Agency'
						when 5 then 'Tribal w/o IV-E'
						when 6 then 'Tribal with IV-E'
						when 7 then 'Parental'
						when 8 then '3rd Party' 
						when 9 then 'Court Ordered'
						when 10 then 'JRA'
						when 11 then 'Federal'
				end  as PLACEMENT_CARE_AUTH
				,1 as nondcfs_mark
				,cast(convert(varchar(10),getdate(),101) as datetime) as tbl_refresh_dt
		into base.WRK_nonDCFS_All
		from #AUTH
		where custc =0
		order by ID_PRSN,CUST_BEGIN;

		update base.WRK_nonDCFS_All
		set cust_end='12/31/9999'
		where cust_end is null;



		if object_ID('tempDB..#nondcfs') is not null drop table #nondcfs;

		select *,row_number() over (partition by id_prsn,CD_PLACEMENT_CARE_AUTH 
					order by id_prsn,CD_PLACEMENT_CARE_AUTH, cust_begin,cust_end) as cust_asc
				,row_number() over (partition by id_prsn,CD_PLACEMENT_CARE_AUTH 
					order by id_prsn,CD_PLACEMENT_CARE_AUTH, cust_begin desc ,cust_end desc) as cust_desc
		into #nondcfs
		 from base.WRK_nonDCFS_All
		 order by id_prsn,CD_PLACEMENT_CARE_AUTH
		 
		 
		 if object_ID('tempDB..#mult') is not null drop table #mult;
		 select * 
		 into #mult
		 from #nondcfs where not(cust_asc=1 and cust_desc=1) order by id_prsn,CD_PLACEMENT_CARE_AUTH,cust_asc
		 
		 
		 if object_ID('tempDB..#unq') is not null drop table #unq;
		 select * into #unq from #mult where cust_asc=1;
		 
		 
		 insert into #unq
		 select *
		from #nondcfs where (cust_asc=1 and cust_desc=1)

		declare @loopcnt int
		declare @loopstop int

		set @loopcnt=1;
		select @loopstop=max(cust_desc) from #mult;

		while @loopcnt < @loopstop
		begin
			-- concatenate dates for same person,auth
			update unq 
			set cust_end=m.cust_end,cust_asc=m.cust_asc,backtoDCFS=m.backtoDCFS
			from #unq unq
			join #mult  m 
				on  m.id_prsn=unq.id_prsn
					and m.CD_PLACEMENT_CARE_AUTH=unq.CD_PLACEMENT_CARE_AUTH
			where m.cust_asc=unq.cust_asc+1
				and (m.cust_begin <=unq.cust_end or dateadd(dd,-1,m.cust_begin)=unq.cust_end)
				
			-- if not concatenated insert into table
			insert into #unq
			select m.*
			from #mult m
			left join #unq unq on unq.id_prsn=m.id_prsn and unq.CD_PLACEMENT_CARE_AUTH=m.CD_PLACEMENT_CARE_AUTH
				and unq.cust_asc=m.cust_asc
			where unq.id_prsn is null
			and m.cust_asc=@loopcnt + 1;
			
			set @loopcnt=@loopcnt + 1;
		end


		truncate table base.WRK_nonDCFS_All;
		insert into base.WRK_nonDCFS_All
		SELECT [ID_PRSN]
			  ,[CUST_BEGIN]
			  ,[CUST_END]
			  ,[backtoDCFS]
			  ,[CD_PLACEMENT_CARE_AUTH]
			  ,[PLACEMENT_CARE_AUTH]
			  ,[nondcfs_mark]
			  ,cast(convert(varchar(10),getdate(),121) as datetime) 
		  FROM #unq
		  order by id_prsn,cust_begin,cust_end;

		  	update base.procedure_flow
			set last_run_date=getdate()
			where procedure_nm='prod_build_WRK_NonDCFS'
		end


else
begin
	select 'Need permission key to execute this --BUILDS nonDCFS custody table!' as [Warning]
end
