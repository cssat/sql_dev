USE [CA_ODS]
GO
/****** Object:  StoredProcedure [ref].[prod_build_ref_match_ooh_parameters]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [ref].[prod_build_ref_match_ooh_parameters]
as

if object_id(N'dbo.ref_match_ooh_parameters',N'U') is not null drop table dbo.ref_match_ooh_parameters

CREATE TABLE [dbo].ref_match_ooh_parameters(
	int_param_key bigint,
	[param_key] varchar(9),
	[age_grouping_cd] [int] NOT NULL,
	[cd_race_census] [int] NOT NULL,
	--cd_hispanic_latino_origin [int] NOT NULL,
	[pk_gndr] [int] NOT NULL,
	[init_cd_plcm_setng] [int] NOT NULL,
	long_cd_plcm_setng [int] NOT NULL,
	[county_cd] [int] NOT NULL,
	[int_match_param_key] bigint,
	match_param_key varchar(9),
	[match_age_grouping_cd] [int] NOT NULL,
	[match_cd_race_census] [int] NOT NULL,
	match_cd_hispanic_latino_origin [int] NOT NULL,
	[match_pk_gndr] [int] NOT NULL,
	[match_init_cd_plcm_setng] [int] NOT NULL,
	[match_long_cd_plcm_setng] [int] NOT NULL,
	[match_county_cd] [int] NOT NULL,
	fl_in_tbl_child_episodes int not null default 0,
 PRIMARY KEY  
(
	int_param_key ASC,
	[int_match_param_key] asc,
	[county_cd] ASC,
	[match_county_cd] ASC
)
) ON [PRIMARY]


--select * from ref_match_ooh_parameters

insert into dbo.ref_match_ooh_parameters (int_param_key,param_key,age_grouping_cd,cd_race_census
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd
			,[int_match_param_key],match_param_key,[match_age_grouping_cd],[match_cd_race_census]
			,[match_cd_hispanic_latino_origin]
			,[match_pk_gndr],[match_init_cd_plcm_setng],[match_long_cd_plcm_setng],[match_county_cd])

select   Q.*
from (select  
			 cast(concat('1' 
				, cast(age.age_grouping_cd as char(1))
				, case when rce.cd_race_census between 0 and 9 then '0' +  cast(rce.cd_race_census as char(1)) 
					else cast(rce.cd_race_census as char(2))  end
		--		, cast(eth.cd_hispanic_latino_origin as char(1))
				, cast(gdr.pk_gndr as char(1))
				, cast(fpl.init_cd_plcm_setng as char(1))
				, cast(lpl.longest_cd_plcm_setng as char(1))
				,  case when cnty.county_cd between 0 and 9 then concat('0',cast(cnty.county_cd as char(1))) 
						when cnty.county_cd = -99 or county_cd > 39 then '99'
						else cast(cnty.county_cd as char(2)) end 
				) as numeric(18,0)) as int_param_key
			 , concat('1' 
				, cast(age.age_grouping_cd as char(1))
				, case when rce.cd_race_census between 0 and 9 then '0' +  cast(rce.cd_race_census as char(1)) 
					else cast(rce.cd_race_census as char(2))  end
		--		, cast(eth.cd_hispanic_latino_origin as char(1))
				, cast(gdr.pk_gndr as char(1))
				, cast(fpl.init_cd_plcm_setng as char(1))
				, cast(lpl.longest_cd_plcm_setng as char(1))
				,  case when cnty.county_cd between 0 and 9 then concat('0',cast(cnty.county_cd as char(1))) 
						when cnty.county_cd = -99 or county_cd > 39 then '99'
						else cast(cnty.county_cd as char(2)) end 
			) as param_key
			, age.age_grouping_cd 
			, rce.cd_race_census
	--		, eth.cd_hispanic_latino_origin
			, gdr.pk_gndr
			, fpl.init_cd_plcm_setng
			, lpl.longest_cd_plcm_setng
			, county_cd
			, cast(concat('1' 
					, cast(age.match_age_grouping_cd as char(1))
					, cast(rce.match_cd_race_census as char(1))
					, cast(rce.match_census_hispanic_latino_origin_cd as char(1))
					, cast(gdr.match_pk_gndr as char(1))
					, cast(fpl.match_init_cd_plcm_setng as char(1))
					, cast(lpl.match_longest_cd_plcm_setng as char(1))
					,  case when cnty.match_county_cd between 1 and 9 then concat('0',cast(cnty.match_county_cd as char(1))) 
							when cnty.match_county_cd = -99 or match_county_cd > 39 then '99'
							else cast(cnty.match_county_cd as char(2)) end 
				) as  numeric(18,0)) as int_match_param_key
			, concat('1' 
				, cast(age.match_age_grouping_cd as char(1))
				, cast(rce.match_cd_race_census as char(1))
				, cast(rce.match_census_hispanic_latino_origin_cd as char(1))
				, cast(gdr.match_pk_gndr as char(1))
				, cast(fpl.match_init_cd_plcm_setng as char(1))
				, cast(lpl.match_longest_cd_plcm_setng as char(1))
				,  case when cnty.match_county_cd between 1 and 9 then concat('0',cast(cnty.match_county_cd as char(1))) 
						when (cnty.match_county_cd = -99 or match_county_cd > 39 ) then '99'
						else cast(cnty.match_county_cd as char(2)) end 
			) as match_param_key
			, age.match_age_grouping_cd 
			, rce.match_cd_race_census
			, rce.match_census_hispanic_latino_origin_cd
			, gdr.match_pk_gndr
			, fpl.match_init_cd_plcm_setng
			, lpl.match_longest_cd_plcm_setng
			, cnty.match_county_cd

from ref_match_age_groupings_census age 
cross join dbo.ref_match_race_census rce 
--cross join dbo.ref_match_ethnicity_census eth
cross join dbo.ref_match_gender gdr
cross join dbo.ref_match_init_cd_plcm_setng fpl
cross join dbo.ref_match_longest_cd_plcm_setng lpl
cross join dbo.ref_match_county_cd cnty 
) q 




update prm
set fl_in_tbl_child_episodes = 1
from base.tbl_child_episodes tce
join age_dim age on age.age_mo=tce.age_eps_begin_mos 
join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
join dbo.ref_lookup_placement_event longplc on longplc.id_plcmnt_evnt=tce.longest_id_plcmnt_evnt
join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
join dbo.ref_match_ooh_parameters prm on prm.age_grouping_cd=age.census_child_group_cd	
	and prm.match_cd_race_census=tce.cd_race_census
	--and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
	and prm.match_pk_gndr=g.pk_gndr
	and prm.match_init_cd_plcm_setng=frstplc.cd_plcm_setng
	and prm.match_long_cd_plcm_setng=longplc.cd_plcm_setng
	and prm.match_county_cd=tce.Removal_County_Cd

							


-- now get the 'ALLS '
update prm
set fl_in_tbl_child_episodes = 1
from dbo.ref_match_ooh_parameters prm  
join dbo.ref_match_ooh_parameters prm2 on prm2.int_match_param_key=prm.int_match_param_key 
where prm.fl_in_tbl_child_episodes=0
and prm2.fl_in_tbl_child_episodes=1;

CREATE NONCLUSTERED INDEX idx_ooh_parameters
ON [dbo].[ref_match_ooh_parameters] ([fl_in_tbl_child_episodes],[match_county_cd])
INCLUDE ([int_param_key],[age_grouping_cd],[cd_race_census],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[match_age_grouping_cd],[match_cd_race_census],[match_pk_gndr],[match_init_cd_plcm_setng],[match_long_cd_plcm_setng])

CREATE NONCLUSTERED INDEX idx_demog_params_match4
ON [dbo].[ref_match_ooh_parameters] ([age_grouping_cd],[match_cd_race_census]
,[match_cd_hispanic_latino_origin]
,[match_pk_gndr],[match_init_cd_plcm_setng],[match_long_cd_plcm_setng],[match_county_cd])
INCLUDE ([int_param_key],[county_cd],[int_match_param_key])


CREATE NONCLUSTERED INDEX idx_param_match898
ON [dbo].[ref_match_ooh_parameters] ([age_grouping_cd],[match_cd_race_census]
,[match_cd_hispanic_latino_origin]
,[match_pk_gndr],[match_init_cd_plcm_setng],[match_long_cd_plcm_setng],[match_county_cd])
INCLUDE ([int_match_param_key])


CREATE NONCLUSTERED INDEX idx_age_fl_int_tbl_child_episodes_covering_rest
ON [dbo].[ref_match_ooh_parameters] ([age_grouping_cd],[match_age_grouping_cd],[fl_in_tbl_child_episodes])
INCLUDE ([int_param_key],[cd_race_census],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[match_cd_race_census],[match_cd_hispanic_latino_origin],[match_pk_gndr],[match_init_cd_plcm_setng],[match_long_cd_plcm_setng],[match_county_cd])


CREATE NONCLUSTERED INDEX idx_ooh_parameters_54321
ON [dbo].[ref_match_ooh_parameters] ([long_cd_plcm_setng],[match_long_cd_plcm_setng],[fl_in_tbl_child_episodes])
INCLUDE ([int_param_key],[age_grouping_cd],[cd_race_census],[pk_gndr],[init_cd_plcm_setng],[county_cd],[int_match_param_key],[match_age_grouping_cd],[match_cd_race_census],[match_cd_hispanic_latino_origin],[match_pk_gndr],[match_init_cd_plcm_setng],[match_county_cd])

GO
