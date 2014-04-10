USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_fnd]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_fnd] AS 
select ref_match_finding.cd_finding AS cd_finding,ref_match_finding.filter_finding AS match_code from ref_match_finding where (ref_match_finding.cd_finding <> 0) union select 0 ,ref_match_finding.filter_finding AS match_code from ref_match_finding where (ref_match_finding.cd_finding <> 0) union select distinct 0 ,power(10,4) 
GO
