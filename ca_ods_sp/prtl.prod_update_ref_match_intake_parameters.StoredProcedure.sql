USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_update_ref_match_intake_parameters]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [prtl].[prod_update_ref_match_intake_parameters]
as


update prm
set fl_in_tbl_intakes = 0
from dbo.ref_match_intake_parameters prm


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
	and prm.match_cd_office=ofc.cd_office_collapse;
GO
