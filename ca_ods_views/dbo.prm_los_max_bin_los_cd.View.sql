USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_los_max_bin_los_cd]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_los_max_bin_los_cd] 
AS select distinct los.bin_los_cd [bin_los_cd]
		,mtch.bin_los_cd [match_code]
		from (ref_filter_los mtch join ref_filter_los los on((mtch.bin_los_cd >= los.bin_los_cd))) 
		where (mtch.bin_los_cd <> 0) 

GO
