USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_plc]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_plc] AS 
select distinct flt.bin_placement_cd AS bin_placement_cd,flt.bin_placement_cd AS match_code from ref_filter_nbr_placement flt where (flt.bin_placement_cd <> 0) union select distinct zr.bin_placement_cd AS bin_placement_cd,flt.bin_placement_cd AS bin_placement_cd from ref_filter_nbr_placement flt ,ref_filter_nbr_placement zr
 where ((flt.bin_placement_cd <> 0) and (zr.bin_placement_cd = 0))
GO
