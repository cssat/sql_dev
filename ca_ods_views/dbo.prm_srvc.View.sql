USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_srvc]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_srvc] AS select ref_match_srvc_type_category.cd_subctgry_poc_fr AS cd_subctgry_poc_frc,ref_match_srvc_type_category.filter_srvc_type AS match_code from ref_match_srvc_type_category where (ref_match_srvc_type_category.cd_subctgry_poc_fr <> 0) union select 0 ,ref_match_srvc_type_category.filter_srvc_type AS filter_srvc_type from ref_match_srvc_type_category where (ref_match_srvc_type_category.cd_subctgry_poc_fr <> 0) union select 0,10000000000000000 
GO
