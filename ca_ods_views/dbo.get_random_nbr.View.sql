USE [CA_ODS]
GO
/****** Object:  View [dbo].[get_random_nbr]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[get_random_nbr]
AS
SELECT RAND() rndResult

GO
