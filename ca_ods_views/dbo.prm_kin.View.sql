USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_kin]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[prm_kin] AS select 1 AS kincare,1 AS match_code union select 0 ,0  union select 0 ,1 



GO
