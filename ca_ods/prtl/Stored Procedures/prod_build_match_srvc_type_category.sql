-- exec [prtl].[prod_build_match_srvc_type_category]
CREATE procedure [prtl].[prod_build_match_srvc_type_category] as 

if object_id(N'dbo.ref_match_srvc_type_category',N'U') is not null drop table [ref_match_srvc_type_category]
CREATE TABLE [dbo].[ref_match_srvc_type_category](
	[filter_srvc_type] [decimal](21, 0) NOT NULL,
	[fl_family_focused_services] smallint NOT NULL,
	[fl_child_care] smallint NOT NULL,
	[fl_therapeutic_services] smallint NOT NULL,
	[fl_mh_services] smallint NOT NULL,
	[fl_receiving_care] smallint NOT NULL,
	[fl_family_home_placements] smallint NOT NULL,
	[fl_behavioral_rehabiliation_services] smallint NOT NULL,
	[fl_other_therapeutic_living_situations] smallint NOT NULL,
	[fl_specialty_adolescent_services] smallint NOT NULL,
	[fl_respite] smallint NOT NULL,
	[fl_transportation] smallint NOT NULL,
	[fl_clothing_incidentals] smallint NOT NULL,
	[fl_sexually_aggressive_youth] smallint NOT NULL,
	[fl_adoption_support] smallint NOT NULL,
	[fl_various] smallint NOT NULL,
	[fl_medical] smallint NOT NULL,
	fl_ihs_reun smallint not null,
	fl_concrete_goods smallint not null,
	cd_subctgry_poc_fr int not null default 0,
	int_filter_service_category int ,
 PRIMARY KEY  
(
	int_filter_service_category ASC,cd_subctgry_poc_fr asc
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
      ,[fl_medical]
	  ,fl_ihs_reun
	  ,fl_concrete_goods
	  ,int_filter_service_category)
SELECT distinct  (select multiplier from ref_service_cd_subctgry_poc  where cd_subctgry_poc_frc=0) + 
				   (eps.fl_family_focused_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services'))  + 
								(eps.fl_child_care *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_child_care' ) ) + 
								(eps.fl_therapeutic_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services' )  ) + 
								(eps.fl_mh_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_mh_services' )  ) + 
								(eps.fl_receiving_care * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_receiving_care' )  ) + 
								(eps.fl_family_home_placements * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_home_placements' )  ) + 
								(eps.fl_behavioral_rehabiliation_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services' )  ) + 
								(eps.fl_other_therapeutic_living_situations * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations' )  ) + 
								(eps.fl_specialty_adolescent_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services' )  ) + 
								(eps.fl_respite * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_respite' ) ) + 
								(eps.fl_transportation * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_transportation' )  ) + 
								(eps.fl_clothing_incidentals * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_clothing_incidentals' )  ) + 
								(eps.fl_sexually_aggressive_youth * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_sexually_aggressive_youth' )  ) + 
								(eps.fl_adoption_support * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_adoption_support' )  ) + 
								(eps.fl_various * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_various' )  ) + 
								(eps.fl_medical * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_medical' ) )  +
								(eps.fl_ihs_reun * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun' ) )  +
								(eps.fl_concrete_goods * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods' ) )  filter_service_category
      ,eps.[fl_family_focused_services]
      ,eps.[fl_child_care]
      ,eps.[fl_therapeutic_services]
      ,eps.[fl_mh_services]
      ,eps.[fl_receiving_care]
      ,eps.[fl_family_home_placements]
      ,eps.[fl_behavioral_rehabiliation_services]
      ,eps.[fl_other_therapeutic_living_situations]
      ,eps.[fl_specialty_adolescent_services]
      ,eps.[fl_respite]
      ,eps.[fl_transportation]
      ,eps.[fl_clothing_incidentals]
      ,eps.[fl_sexually_aggressive_youth]
      ,eps.[fl_adoption_support]
      ,eps.[fl_various]
      ,eps.[fl_medical]
	  ,eps.fl_ihs_reun
	  ,eps.fl_concrete_goods
	  ,xw.int_filter_service_category
  FROM [base].[episode_payment_services] eps
  join ref_service_category_flag_xwalk xw on 
			   eps.fl_family_focused_services = xw.fl_family_focused_services
			and eps.fl_child_care = xw.fl_child_care
			and eps.fl_therapeutic_services = xw.fl_therapeutic_services
			and eps.fl_mh_services = xw.fl_mh_services
			and eps.fl_receiving_care = xw.fl_receiving_care
			and eps.fl_family_home_placements = xw.fl_family_home_placements
			and eps.fl_behavioral_rehabiliation_services = xw.fl_behavioral_rehabiliation_services
			and eps.fl_other_therapeutic_living_situations = xw.fl_other_therapeutic_living_situations
			and eps.fl_specialty_adolescent_services = xw.fl_specialty_adolescent_services
			and eps.fl_respite = xw.fl_respite
			and eps.fl_transportation = xw.fl_transportation
			and eps.fl_clothing_incidentals = xw.fl_clothing_incidentals
			and eps.fl_sexually_aggressive_youth = xw.fl_sexually_aggressive_youth
			and eps.fl_adoption_support = xw.fl_adoption_support
			and eps.fl_various = xw.fl_various
			and eps.fl_medical = xw.fl_medical
			and eps.fl_ihs_reun = xw.fl_ihs_reun
			and eps.fl_concrete_goods = xw.fl_concrete_goods


							
  union  --- LEFT OFF HERE  --- HAVE TO FIX IHS Services
  select distinct  xw.filter_service_category
      ,eps.[fl_family_focused_services]
      ,eps.[fl_child_care]
      ,eps.[fl_therapeutic_services]
      --,eps.[fl_mh_services]
      --,eps.[fl_receiving_care]
      --,eps.[fl_family_home_placements]
	  ,0
	  ,0
	  ,0
      ,eps.[fl_behavioral_rehabiliation_services]
      ,eps.[fl_other_therapeutic_living_situations]
      ,eps.[fl_specialty_adolescent_services]
      ,eps.[fl_respite]
      ,eps.[fl_transportation]
      --,eps.[fl_clothing_incidentals]
      --,eps.[fl_sexually_aggressive_youth]
      --,eps.[fl_adoption_support]
      --,eps.[fl_various]
      --,eps.[fl_medical]
	  ,0
	  ,0
	  ,0
	  ,0
	  ,0
	  ,eps.fl_ihs_reun
	  ,eps.fl_concrete_goods
	  ,eps.int_filter_service_category
	  from base.tbl_ihs_episodes eps
  join ref_service_category_flag_xwalk xw 
		on xw.int_filter_service_category=eps.int_filter_service_category
	  union 
	  select distinct
	  filter_service_category_todate
      ,eps.[fl_family_focused_services]
      ,eps.[fl_child_care]
      ,eps.[fl_therapeutic_services]
      ,eps.[fl_mh_services]
      ,eps.[fl_receiving_care]
      ,eps.[fl_family_home_placements]
      ,eps.[fl_behavioral_rehabiliation_services]
      ,eps.[fl_other_therapeutic_living_situations]
      ,eps.[fl_specialty_adolescent_services]
      ,eps.[fl_respite]
      ,eps.[fl_transportation]
      ,eps.[fl_clothing_incidentals]
      ,eps.[fl_sexually_aggressive_youth]
      ,eps.[fl_adoption_support]
      ,eps.[fl_various]
      ,eps.[fl_medical]
	  ,eps.fl_ihs_reun
	  ,eps.fl_concrete_goods
	  ,xw.int_filter_service_category
  FROM [base].[placement_payment_services] eps
  join ref_service_category_flag_xwalk xw on 
			   eps.fl_family_focused_services = xw.fl_family_focused_services
			and eps.fl_child_care = xw.fl_child_care
			and eps.fl_therapeutic_services = xw.fl_therapeutic_services
			and eps.fl_mh_services = xw.fl_mh_services
			and eps.fl_receiving_care = xw.fl_receiving_care
			and eps.fl_family_home_placements = xw.fl_family_home_placements
			and eps.fl_behavioral_rehabiliation_services = xw.fl_behavioral_rehabiliation_services
			and eps.fl_other_therapeutic_living_situations = xw.fl_other_therapeutic_living_situations
			and eps.fl_specialty_adolescent_services = xw.fl_specialty_adolescent_services
			and eps.fl_respite = xw.fl_respite
			and eps.fl_transportation = xw.fl_transportation
			and eps.fl_clothing_incidentals = xw.fl_clothing_incidentals
			and eps.fl_sexually_aggressive_youth = xw.fl_sexually_aggressive_youth
			and eps.fl_adoption_support = xw.fl_adoption_support
			and eps.fl_various = xw.fl_various
			and eps.fl_medical = xw.fl_medical
			and eps.fl_ihs_reun = xw.fl_ihs_reun
			and eps.fl_concrete_goods = xw.fl_concrete_goods
	  where filter_service_category_todate is not null


	  if object_id('tempDB..#temp' ) is not null drop table #temp;

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	into #temp
	  from [ref_match_srvc_type_category] ref
	  join (select 1 as cd_subctgry_poc_fr,1 as fl_family_focused_services) q on q.fl_family_focused_services = ref.fl_family_focused_services
	   join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join	    (select 2 as cd_subctgry_poc_fr
					,1 as fl_child_care) q on q.fl_child_care=ref.fl_child_care 
  join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
	
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join		  (select 3 as cd_subctgry_poc_fr,1 as fl_therapeutic_services) q
	   on q.fl_therapeutic_services=ref.fl_therapeutic_services
	join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join		    (select 4 as cd_subctgry_poc_fr,1 as fl_mh_services
	  ) q on q.fl_mh_services=ref.fl_mh_services 
	  	join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join			  (select 5 as cd_subctgry_poc_fr,1 as fl_receiving_care) q on q.fl_receiving_care=ref.fl_receiving_care 
  join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join			    (select 6 as cd_subctgry_poc_fr,1 as fl_family_home_placements) q on q.fl_family_home_placements=ref.fl_family_home_placements
  join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join	 (select 7 as cd_subctgry_poc_fr,1 as fl_behavioral_rehabiliation_services) q on q.fl_behavioral_rehabiliation_services=ref.fl_behavioral_rehabiliation_services
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join				    (select 8 as cd_subctgry_poc_fr,1 as fl_other_therapeutic_living_situations) q on q.fl_other_therapeutic_living_situations=ref.fl_other_therapeutic_living_situations
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join	 (select 9 as cd_subctgry_poc_fr,1 as fl_specialty_adolescent_services) q on q.fl_specialty_adolescent_services=ref.fl_specialty_adolescent_services
  join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join					    (select 10 as cd_subctgry_poc_fr,1 as fl_respite) q on q.fl_respite=ref.fl_respite
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join	(select 11 as cd_subctgry_poc_fr,1 as fl_transportation) q on q.fl_transportation=ref.fl_transportation
  join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join		    (select 12 as cd_subctgry_poc_fr,1 as fl_clothing_incidentals) q on q.fl_clothing_incidentals=ref.fl_clothing_incidentals
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join  (select 13 as cd_subctgry_poc_fr,1 as fl_sexually_aggressive_youth) q on q.fl_sexually_aggressive_youth=ref.fl_sexually_aggressive_youth
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join    (select 14 as cd_subctgry_poc_fr,1 as fl_adoption_support) q on q.fl_adoption_support=ref.fl_adoption_support
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join	  (select 15 as cd_subctgry_poc_fr,1 as fl_various) q on q.fl_various=ref.fl_various
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join    (select 16 as cd_subctgry_poc_fr,1 as fl_medical) q on q.fl_medical=ref.fl_medical
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join    (select 17 as cd_subctgry_poc_fr,1 as fl_ihs_reun) q on q.fl_ihs_reun=ref.fl_ihs_reun
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category

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
			,ref.fl_ihs_reun
			,ref.fl_concrete_goods
			,q.cd_subctgry_poc_fr
			,xw.int_filter_service_category
	  from [ref_match_srvc_type_category] ref
	  join    (select 18 as cd_subctgry_poc_fr,1 as fl_concrete_goods) q on q.fl_concrete_goods=ref.fl_concrete_goods
	    join ref_service_category_flag_xwalk xw on 
			   ref.filter_srvc_type=xw.filter_service_category
	  
	  

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
	  ,fl_ihs_reun
	  ,fl_concrete_goods
	  ,cd_subctgry_poc_fr,int_filter_service_category)
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
	  ,fl_ihs_reun
	  ,fl_concrete_goods
	  ,cd_subctgry_poc_fr
	  ,int_filter_service_category
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
	  ,fl_ihs_reun
	  ,fl_concrete_goods
	  ,cd_subctgry_poc_fr
	  ,int_filter_service_category)
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
	  ,0
	  ,0
	  ,1

		
		
update prtl.prtl_tables_last_update
set last_build_date=getdate(),row_count=(select count(*) from ref_match_srvc_type_category)
where tbl_id=49;

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_match_srvc_type_category'
--  select * from prtl.prtl_tables_last_update