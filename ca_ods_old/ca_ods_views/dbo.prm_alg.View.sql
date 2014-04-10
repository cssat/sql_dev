USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_alg]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_alg] AS select ref_match_allegation.cd_allegation AS cd_allegation,ref_match_allegation.filter_allegation AS match_code from ref_match_allegation where (ref_match_allegation.cd_allegation <> 0) union select 0 ,flt.filter_allegation AS match_code from ref_match_allegation flt where (flt.cd_allegation <> 0) union select distinct 0 ,power(10,4) 
GO
