USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_rpt]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_rpt] AS select flt.cd_reporter_type AS cd_reporter_type,flt.cd_reporter_type AS match_code from ref_filter_reporter_type flt where (flt.cd_reporter_type > 0) union select zr.cd_reporter_type AS cd_reporter_type,flt.cd_reporter_type AS cd_reporter_type from ref_filter_reporter_type flt , ref_filter_reporter_type zr
where ((flt.cd_reporter_type <> 0) and (zr.cd_reporter_type = 0))

GO
