USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_ihs]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_ihs] AS 
select distinct flt.bin_ihs_svc_cd AS bin_ihs_svc_cd,flt.bin_ihs_svc_cd AS match_code from ref_filter_ihs_services flt where (flt.bin_ihs_svc_cd <> 0) union all select distinct zr.bin_ihs_svc_cd AS bin_ihs_svc_cd,flt.bin_ihs_svc_cd AS bin_ihs_svc_cd from ref_filter_ihs_services flt ,ref_filter_ihs_services zr where ((flt.bin_ihs_svc_cd <> 0) and (zr.bin_ihs_svc_cd = 0))

GO
