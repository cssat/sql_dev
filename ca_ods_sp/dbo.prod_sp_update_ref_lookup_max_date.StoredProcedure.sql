USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[prod_sp_update_ref_lookup_max_date]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[prod_sp_update_ref_lookup_max_date](@permission_key datetime)
as 

if @permission_key=(select top 1 cutoff_date from ref_last_dw_transfer)
begin
		if object_ID('tempDB..##ref') is not null drop table ##ref
		select * into #ref from ref_lookup_max_date;


		declare @cutoff_date datetime
		declare @max_date_Qtr datetime
		declare @max_date_yr datetime
		select @cutoff_date=dateadd(mm,-1,[month]) ,@max_date_Qtr=dateadd(mm,-3,[Quarter]),@max_date_yr=dateadd(yy,-1,[Year])
		from ref_last_DW_transfer join dbo.calendar_dim cd on cd.calendar_date=cutoff_date;



		update ref_lookup_max_date
		set max_date_all =dateadd(yy,-3,@max_date_yr)
		, max_date_any=@max_date_yr
		, max_date_yr=@max_date_yr
		where (id between 1 and 4)
			;
										

		update ref_lookup_max_date
		set max_date_all = dateadd(yy,-3,@max_date_qtr)
			,max_date_any=dateadd(mm,-3,@max_date_Qtr)
		, max_date_qtr=dateadd(mm,-3,@max_date_Qtr)
		, max_date_yr=@max_date_yr
		, min_date_any=dateadd(mm,3,dateadd(yy,-3,@max_date_qtr))
		where (id between 5 and 7) or (id between 10 and 11)
			;
										
										
		update ref_lookup_max_date
		set max_date_all =dateadd(yy,-4,@max_date_qtr)
			,max_date_any=dateadd(mm,-3,@max_date_Qtr)
		, max_date_qtr=dateadd(mm,-3,@max_date_Qtr)
		, max_date_yr=@max_date_yr
		where  id=8 ;
										


		update ref_lookup_max_date
		set max_date_all =dateadd(yy,-4,@max_date_qtr)
		, max_date_any=dateadd(mm,-3,@max_date_Qtr)
		, max_date_qtr=dateadd(mm,-3,@max_date_Qtr)
		, max_date_yr=@max_date_yr
		where  id=9;;



								
		update ref_lookup_max_date
		set max_date_all =@cutoff_date
		, max_date_any=@cutoff_date
		, max_date_qtr=@max_date_Qtr
		, max_date_yr=@max_date_yr
		where (id between 12 and 14)
			;
										
		update ref_lookup_max_date
		set max_date_all =@cutoff_date
		, max_date_any=@cutoff_date
		, max_date_qtr=@max_date_Qtr
		, max_date_yr=@max_date_yr
		where (id between 15 and 16 or id between 19 and 22)		

		update ref_lookup_max_date
		set max_date_all =@cutoff_date
		, max_date_any=@cutoff_date
		, max_date_qtr=@max_date_Qtr
		, max_date_yr=@max_date_yr
		where (id between 17 and 18) 
		


		/**

		declare @cutoff_date datetime
		declare @max_date_Qtr datetime
		declare @max_date_yr datetime
		select @cutoff_date=dateadd(mm,-1,[month]) ,@max_date_Qtr=dateadd(mm,-3,[Quarter]),@max_date_yr=dateadd(yy,-1,[Year])
		from ref_last_DW_transfer join calendar_dim cd on cd.calendar_date=cutoff_date;

		print @cutoff_date
		print @max_date_qtr
		print @max_date_yr
		print dateadd(mm,3,dateadd(yy,-4,@max_date_qtr))
		print dateadd(mm,3,dateadd(yy,-3,@max_date_qtr))

		SELECT TOP 1000 [id]
			  ,[procedure_name]
			  ,[max_date_all]
			  ,[max_date_any]
			  ,[max_date_qtr]
			  ,[max_date_yr]
			  ,[min_date_any]
		  FROM [dbCoreAdministrativeTables].[dbo].[ref_lookup_max_date]
		where  (id > = 15)
			**/
			
		--select 'old' as v,* from #ref
		--union all
		--select 'new',* from ref_lookup_max_date
		--order by [procedure_name],max_date_all

end

GO
