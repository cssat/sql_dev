USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_match_srvc_type_category]    Script Date: 5/22/2014 11:22:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [prtl].[prod_build_match_srvc_type_category] as 

if object_id(N'dbo.ref_match_srvc_type_category',N'U') is not null drop table [ref_match_srvc_type_category]
CREATE TABLE [dbo].[ref_match_srvc_type_category](
	[filter_srvc_type] [decimal](18, 0) NOT NULL,
	[fl_family_focused_services] [int] NOT NULL,
	[fl_child_care] [int] NOT NULL,
	[fl_therapeutic_services] [int] NOT NULL,
	[fl_mh_services] [int] NOT NULL,
	[fl_receiving_care] [int] NOT NULL,
	[fl_family_home_placements] [int] NOT NULL,
	[fl_behavioral_rehabiliation_services] [int] NOT NULL,
	[fl_other_therapeutic_living_situations] [int] NOT NULL,
	[fl_specialty_adolescent_services] [int] NOT NULL,
	[fl_respite] [int] NOT NULL,
	[fl_transportation] [int] NOT NULL,
	[fl_clothing_incidentals] [int] NOT NULL,
	[fl_sexually_aggressive_youth] [int] NOT NULL,
	[fl_adoption_support] [int] NOT NULL,
	[fl_various] [int] NOT NULL,
	[fl_medical] [int] NOT NULL,
	cd_subctgry_poc_fr int not null default 0,
	id_service_category int,
 PRIMARY KEY  
(
	[filter_srvc_type] ASC,cd_subctgry_poc_fr asc
)) ON [PRIMARY]




insert into dbo.[ref_match_srvc_type_category] ( [filter_srvc_type]
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
      ,[fl_medical])
SELECT distinct power(10.0,16) + 
				   (fl_family_focused_services * power(10.0,15) ) + 
								(fl_child_care * power(10.0,14) ) + 
								(fl_therapeutic_services * power(10.0,13) ) + 
								(fl_mh_services * power(10.0,12) ) + 
								(fl_receiving_care * power(10.0,11) ) + 
								(fl_family_home_placements * power(10.0,10) ) + 
								(fl_behavioral_rehabiliation_services * power(10.0,9) ) + 
								(fl_other_therapeutic_living_situations * power(10.0,8) ) + 
								(fl_specialty_adolescent_services * power(10.0,7) ) + 
								(fl_respite * power(10.0,6) ) + 
								(fl_transportation * power(10.0,5) ) + 
								(fl_clothing_incidentals * power(10.0,4) ) + 
								(fl_sexually_aggressive_youth * power(10.0,3) ) + 
								(fl_adoption_support * power(10.0,2) ) + 
								(fl_various * power(10.0,1) ) + 
								(fl_medical * 1) as filter_service_category
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
  FROM [base].[episode_payment_services]
  union 
  select distinct
  power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1) as filter_service_category
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
	  from base.tbl_ihs_episodes
	  union 
	  select distinct
	  filter_service_category_todate
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
	  from base.placement_payment_services
	  where filter_service_category_todate is not null

	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	into #temp
	  from [ref_match_srvc_type_category] ref
	  join (select 1 as cd_subctgry_poc_fr,1 as fl_family_focused_services) q on q.fl_family_focused_services = ref.fl_family_focused_services

	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join	    (select 2 as cd_subctgry_poc_fr
					,1 as fl_child_care) q on q.fl_child_care=ref.fl_child_care 
	
	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join		  (select 3 as cd_subctgry_poc_fr,1 as fl_therapeutic_services) q
	   on q.fl_therapeutic_services=ref.fl_therapeutic_services
	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join		    (select 4 as cd_subctgry_poc_fr,1 as fl_mh_services
	  ) q on q.fl_mh_services=ref.fl_mh_services 
	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join			  (select 5 as cd_subctgry_poc_fr,1 as fl_receiving_care) q on q.fl_receiving_care=ref.fl_receiving_care 
	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join			    (select 6 as cd_subctgry_poc_fr,1 as fl_family_home_placements) q on q.fl_family_home_placements=ref.fl_family_home_placements
		insert into #temp
		  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join	 (select 7 as cd_subctgry_poc_fr,1 as fl_behavioral_rehabiliation_services) q on q.fl_behavioral_rehabiliation_services=ref.fl_behavioral_rehabiliation_services
		insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join				    (select 8 as cd_subctgry_poc_fr,1 as fl_other_therapeutic_living_situations) q on q.fl_other_therapeutic_living_situations=ref.fl_other_therapeutic_living_situations
	 	insert into #temp
	 	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join	 (select 9 as cd_subctgry_poc_fr,1 as fl_specialty_adolescent_services) q on q.fl_specialty_adolescent_services=ref.fl_specialty_adolescent_services
	  		insert into #temp
		  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join					    (select 10 as cd_subctgry_poc_fr,1 as fl_respite) q on q.fl_respite=ref.fl_respite
	  	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join	(select 11 as cd_subctgry_poc_fr,1 as fl_transportation) q on q.fl_transportation=ref.fl_transportation
	  	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join		    (select 12 as cd_subctgry_poc_fr,1 as fl_clothing_incidentals) q on q.fl_clothing_incidentals=ref.fl_clothing_incidentals
	 	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join  (select 13 as cd_subctgry_poc_fr,1 as fl_sexually_aggressive_youth) q on q.fl_sexually_aggressive_youth=ref.fl_sexually_aggressive_youth
	  	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join    (select 14 as cd_subctgry_poc_fr,1 as fl_adoption_support) q on q.fl_adoption_support=ref.fl_adoption_support
	  	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join	  (select 15 as cd_subctgry_poc_fr,1 as fl_various) q on q.fl_various=ref.fl_various
	  	insert into #temp
	  	  select ref.filter_srvc_type
			,ref.fl_family_focused_services
			,ref.fl_child_care
			,ref.fl_therapeutic_services
			,ref.fl_mh_services
			,ref.fl_receiving_care
			,ref.fl_family_home_placements
			,ref.fl_behavioral_rehabiliation_services
			,ref.fl_other_therapeutic_living_situations
			,ref.fl_specialty_adolescent_services
			,ref.fl_respite
			,ref.fl_transportation
			,ref.fl_clothing_incidentals
			,ref.fl_sexually_aggressive_youth
			,ref.fl_adoption_support
			,ref.fl_various
			,ref.fl_medical
			,q.cd_subctgry_poc_fr
	  from [ref_match_srvc_type_category] ref
	  join    (select 16 as cd_subctgry_poc_fr,1 as fl_medical) q on q.fl_medical=ref.fl_medical

	  truncate table [ref_match_srvc_type_category]
	  insert into [ref_match_srvc_type_category] ( [filter_srvc_type]
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
	  ,cd_subctgry_poc_fr)
	  select  [filter_srvc_type]
      ,[fl_family_focused_services]
      ,[fl_child_care]
      ,fl_therapeutic_services
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
	  ,cd_subctgry_poc_fr
	   from #temp

	    insert into [ref_match_srvc_type_category] ( [filter_srvc_type]
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
	  ,cd_subctgry_poc_fr)
		select (select multiplier from ref_service_cd_subctgry_poc where cd_subctgry_poc_frc=0)
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
	  ,0


	update ref
	set id_service_category=  id_srvc
	from ref_match_srvc_type_category ref
	join (select s.filter_srvc_type,row_number() over (order by [filter_srvc_type]
   ) as id_srvc
				  from ref_match_srvc_type_category s) s on s.filter_srvc_type=ref.filter_srvc_type
		

update prtl.prtl_tables_last_update
set last_build_date=getdate(),row_count=(select count(*) from ref_match_srvc_type_category)
where tbl_id=49;

--  select * from prtl.prtl_tables_last_update