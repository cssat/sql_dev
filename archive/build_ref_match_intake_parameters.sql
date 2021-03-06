USE [CA_ODS]
GO
/****** Object:  StoredProcedure [ref].[prod_build_ref_match_intake_parameters]    Script Date: 10/1/2013 10:42:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  procedure [ref].[prod_build_ref_match_intake_parameters]
as

if object_id(N'dbo.ref_match_intake_parameters',N'U') is not null drop table dbo.ref_match_intake_parameters

CREATE TABLE [dbo].ref_match_intake_parameters(
	int_param_key bigint,
	[param_key] varchar(8),
	cd_sib_age_grp int NOT NULL,
	[cd_race_census] [int] NOT NULL,
	[pk_gndr] [int] NOT NULL,
	cd_office [int] NOT NULL,
	[int_match_param_key] bigint,
	match_param_key varchar(8),
	[match_cd_sib_age_grp] [int] NOT NULL,
	[match_cd_race_census] [int] NOT NULL,
	match_cd_hispanic_latino_origin [int] NOT NULL,
	[match_pk_gndr] [int] NOT NULL,
	[match_cd_office] [int] NOT NULL,
	fl_in_tbl_intakes int not null default 0,
 PRIMARY KEY  
(
	int_param_key ASC,
	[int_match_param_key] asc,
	cd_office ASC,
	[match_cd_office] ASC
)
) ON [PRIMARY]


--select * from ref_match_intake_parameters

insert into dbo.ref_match_intake_parameters (int_param_key,param_key,cd_sib_age_grp,cd_race_census
			,pk_gndr,cd_office
			,[int_match_param_key],match_param_key,[match_cd_sib_age_grp],[match_cd_race_census]
			,[match_cd_hispanic_latino_origin]
			,[match_pk_gndr],[match_cd_office])

select   Q.*
from (select  
			 cast(concat('1' 
					, cast(age.age_grouping_cd as char(1))
					, case when rce.cd_race_census between 0 and 9 then concat('0' ,cast(rce.cd_race_census as char(1))) 
						else cast(rce.cd_race_census as char(2))  end
					, cast(gdr.pk_gndr as char(1))
					, case when ofc.cd_office_collapse between 0 and 9 then concat('00',cast(ofc.cd_office_collapse as char(1))) 
						when ofc.cd_office_collapse between 10 and 99 then concat('0',cast(ofc.cd_office_collapse as char(2))) 
						else cast(ofc.cd_office_collapse as char(3)) end  
				) as numeric(18,0)) as int_param_key
			 , concat('1' 
				, cast(age.age_grouping_cd as char(1))
				, case when rce.cd_race_census between 0 and 9 then '0' +  cast(rce.cd_race_census as char(1)) 
					else cast(rce.cd_race_census as char(2))  end
				, cast(gdr.pk_gndr as char(1))
				,   case when ofc.cd_office_collapse between 0 and 9 then concat('00',cast(ofc.cd_office_collapse as char(1))) 
						when ofc.cd_office_collapse between 10 and 99 then concat('0',cast(ofc.cd_office_collapse as char(2))) 
						else cast(ofc.cd_office_collapse as char(3)) end 
			) as param_key
			, age.age_grouping_cd as cd_sib_age_grp
			, rce.cd_race_census
			, gdr.pk_gndr
			, cd_office_collapse
			, cast(concat('1' 
					, cast(age.match_age_grouping_cd as char(1))
					, cast(rce.match_cd_race_census as char(1))
					, cast(rce.match_census_hispanic_latino_origin_cd as char(1))
					, cast(gdr.match_pk_gndr as char(1))
					,   case when ofc.match_cd_office between 1 and 9 then concat('00',cast(ofc.match_cd_office as char(1))) 
						when abs(ofc.match_cd_office) between 10 and 99 then concat('0',cast(abs(ofc.match_cd_office) as char(2))) 
						else cast(ofc.match_cd_office as char(3)) end 
				) as  numeric(18,0)) as int_match_param_key
			, concat('1' 
				, cast(age.match_age_grouping_cd as char(1))
				, cast(rce.match_cd_race_census as char(1))
				, cast(rce.match_census_hispanic_latino_origin_cd as char(1))
				, cast(gdr.match_pk_gndr as char(1))
				,  case when ofc.match_cd_office between 1 and 9 then concat('00',cast(ofc.match_cd_office as char(1))) 
						when abs(ofc.match_cd_office) between 10 and 99 then concat('0',cast(abs(ofc.match_cd_office) as char(2))) 
						else cast(ofc.match_cd_office as char(3)) end 
			) as match_param_key
			, age.match_age_grouping_cd 
			, rce.match_cd_race_census
			, rce.match_census_hispanic_latino_origin_cd
			, gdr.match_pk_gndr
			, ofc.match_cd_office
			
from ref_match_age_groupings_census age 
cross join dbo.ref_match_race_census rce 
--cross join dbo.ref_match_ethnicity_census eth
cross join dbo.ref_match_gender gdr
cross join (select distinct 0  as cd_office_collapse, (cd_office_collapse) as match_cd_office 
			from dbo.ref_xwalk_CD_OFFICE_DCFS
					where cd_office in (select cd_office from base.tbl_intakes)
					and cd_office <> 0
			union all
			select distinct cd_office_collapse, cd_office_collapse from dbo.ref_xwalk_CD_OFFICE_DCFS
					where cd_office in (select cd_office from base.tbl_intakes)
			and cd_office_collapse not in (0, -99)
			) ofc
) q 

update prm
set fl_in_tbl_intakes = 1
from base.tbl_intakes tce
--join dbo.ref_lookup_sib_age_grp age on age.cd_sib_age_grp=tce.cd_sib_age_grp
--join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
--join dbo.ref_lookup_gender G on G.pk_gndr=tce.pk_gndr
join (select distinct cd_office,cd_office_collapse from dbo.ref_xwalk_CD_OFFICE_DCFS) ofc 
		on ofc.cd_office=tce.cd_office
join dbo.ref_match_intake_parameters prm on prm.match_cd_sib_age_grp=tce.cd_sib_age_grp	
	and prm.match_cd_race_census=tce.cd_race_census
	--and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
	and prm.match_pk_gndr=tce.pk_gndr
	and prm.match_cd_office=ofc.cd_office_collapse;

							
-- now get the 'ALLS '
update prm
set fl_in_tbl_intakes = 1
from dbo.ref_match_intake_parameters prm  
join dbo.ref_match_intake_parameters prm2 on prm2.int_match_param_key=prm.int_match_param_key 
where prm.fl_in_tbl_intakes=0
and prm2.fl_in_tbl_intakes=1;