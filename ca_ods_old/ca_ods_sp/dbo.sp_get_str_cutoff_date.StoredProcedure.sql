USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_str_cutoff_date]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure  [dbo].[sp_get_str_cutoff_date] 
as select  cutoff_date from ref_last_dw_transfer


GO
