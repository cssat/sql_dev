USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_dep]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_dep] AS 
select ref_filter_dependency.bin_dep_cd AS bin_dep_cd,ref_filter_dependency.bin_dep_cd AS match_code 
from ref_filter_dependency where (ref_filter_dependency.bin_dep_cd <> 0) union select 0 ,ref_filter_dependency.bin_dep_cd AS match_code 
from ref_filter_dependency where (ref_filter_dependency.bin_dep_cd <> 0)
GO
