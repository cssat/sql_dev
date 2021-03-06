USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_lpl]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_lpl] 
AS select ref_lookup_placement.cd_plcm_setng [long_cd_plcm_setng],ref_lookup_placement.cd_plcm_setng [match_code] 
from ref_lookup_plcmnt  ref_lookup_placement
where (ref_lookup_placement.cd_plcm_setng <> 0)
 union select zr.cd_plcm_setng [long_cd_plcm_setng],fpl.cd_plcm_setng [match_code]
 from ref_lookup_plcmnt fpl , ref_lookup_plcmnt zr where ((fpl.cd_plcm_setng <> 0) and (zr.cd_plcm_setng = 0))

 
GO
