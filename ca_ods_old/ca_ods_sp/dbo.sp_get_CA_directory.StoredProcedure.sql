USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_CA_directory]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE procedure [dbo].[sp_get_CA_directory] 
as 
select  dir ,ext FROM [dbo].[ca_file_location]


  

GO
