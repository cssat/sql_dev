USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_budg]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_budg] AS select ref_match_srvc_type_budget.cd_budget_poc_frc AS cd_budget_poc_frc,ref_match_srvc_type_budget.filter_service_budget AS match_code from ref_match_srvc_type_budget where (ref_match_srvc_type_budget.cd_budget_poc_frc <> 0) union select 0 ,ref_match_srvc_type_budget.filter_service_budget AS match_code from ref_match_srvc_type_budget where (ref_match_srvc_type_budget.cd_budget_poc_frc <> 0) union select 0 ,10000000 

GO
