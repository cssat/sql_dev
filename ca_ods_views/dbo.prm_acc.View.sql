USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_acc]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_acc] AS 
select flt.cd_access_type AS cd_access_type,flt.filter_access_type AS match_code from ref_filter_access_type flt where (flt.cd_access_type <> 0) union select zr.cd_access_type AS cd_access_type,flt.filter_access_type AS filter_access_type from ref_filter_access_type flt , ref_filter_access_type zr where ((flt.cd_access_type <> 0) and (zr.cd_access_type = 0)) union select 0 ,100000 

GO
