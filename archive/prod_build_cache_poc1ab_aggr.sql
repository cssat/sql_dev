USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_cache_poc1ab_aggr]    Script Date: 9/12/2013 12:15:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_cache_poc1ab_aggr]
as

SET NOCOUNT on
if object_ID('tempDB..##cache_poc1ab') is not null drop table ##cache_poc1ab

select *
into ##cache_poc1ab
from prtl.cache_poc1ab_params;

--truncate table cache_poc1ab_aggr_prior;
--INSERT INTO cache_poc1ab_aggr_prior
--select * from cache_poc1ab_aggr;

truncate table  prtl.cache_poc1ab_params_prior
insert into prtl.cache_poc1ab_params_prior
select * from prtl.cache_poc1ab_params

truncate table prtl.cache_poc1ab_aggr;
truncate table prtl.cache_poc1ab_params



declare @qry_ID int
DECLARE @age_grouping_cd varchar(30)
DECLARE @race_cd varchar(30)
DECLARE @ethnicity_cd varchar(30)
DECLARE @gender_cd varchar(10)
DECLARE @init_cd_plcm_setng varchar(30)
DECLARE @long_cd_plcm_setng varchar(30)
declare @county_cd varchar(200) 
declare @max_bin_los_cd varchar(30) 
declare @bin_placement_cd varchar(30) 
declare @bin_ihs_svc_cd varchar(30) 
declare @cd_reporter_type varchar(100) 
declare @filter_access_type varchar(30) 
declare @filter_allegation varchar(30) 
declare @filter_finding varchar(30)
declare @filter_service_category varchar(100) 
declare @filter_service_budget varchar(100) 
DECLARE @bin_dep_cd varchar(30)


declare @max_qry_id int
declare @dates varchar(300)
declare @cutoff_date datetime
declare @enddate datetime
declare @end_date char(10);
declare @begin_date char(10);

set @begin_date='2000-01-01'

set @bin_dep_cd='0,1,2,3'

select @cutoff_date=cutoff_date from dbo.ref_last_dw_transfer;

select @enddate=dateadd(mm,-1,[Month]) from dbo.calendar_dim where calendar_date=@cutoff_date;
set @end_date=convert(char(10),@enddate,121)

set @dates=( @begin_date + ',' + @end_date)



set @qry_ID=1
select @max_qry_ID=max(qry_id) from ##cache_poc1ab;

if @max_qry_id is not null
begin
	while @qry_ID <=@max_qry_ID
	begin

			select @age_grouping_cd=age_Grouping_cd
			,@ethnicity_cd=cd_race
			,@gender_cd=pk_gndr
			,@init_cd_plcm_setng=init_cd_plcm_setng
			,@long_cd_plcm_setng=long_cd_plcm_setng
			,@county_cd=county_cd
			from ##cache_poc1ab where qry_ID=@qry_ID
			if @age_grouping_cd is not null
			begin
			exec prtl.cache_poc1ab_counts_insert_only 
							@dates
							,@age_grouping_cd
							,@race_cd
							,@ethnicity_cd
							,@gender_cd
							,@init_cd_plcm_setng
							,@long_cd_plcm_setng
							,@County_Cd
							, @max_bin_los_cd 
							, @bin_placement_cd 
							, @bin_ihs_svc_cd 
							, @cd_reporter_type 
							, @fl_cps_invs 
							, @fl_phys_abuse 
							, @fl_sexual_abuse 
							, @fl_neglect 
							, @fl_any_legal 
							, @fl_founded_phys_abuse 
							, @fl_founded_sexual_abuse 
							, @fl_founded_neglect 
							, @fl_found_any_legal 
							, @fl_family_focused_services 
							, @fl_child_care 
							, @fl_therapeutic_services 
							, @fl_mh_services 
							, @fl_receiving_care 
							, @fl_family_home_placements 
							, @fl_behavioral_rehabiliation_services 
							, @fl_other_therapeutic_living_situations 
							, @fl_specialty_adolescent_services 
							, @fl_respite 
							, @fl_transportation 
							, @fl_clothing_incidentals 
							, @fl_sexually_aggressive_youth 
							, @fl_adoption_support 
							, @fl_various 
							, @fl_medical 
							, @fl_budget_C12 
							, @fl_budget_C14 
							, @fl_budget_C15 
							, @fl_budget_C16 
							, @fl_budget_C18 
							, @fl_budget_C19 
							, @fl_uncat_svc 
												
			
			end
			set @qry_ID = @qry_ID + 1;
			print '@qry_ID= ' + str(@qry_ID)

	end


end
else
	select 'ERROR _ ##cache_poc1ab is empty!'
