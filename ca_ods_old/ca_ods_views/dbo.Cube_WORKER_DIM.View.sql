USE [CA_ODS]
GO
/****** Object:  View [dbo].[Cube_WORKER_DIM]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Cube_WORKER_DIM]
AS

SELECT
	WD.ID_WORKER_DIM
	,WD.ID_PRSN
	,WD.ID_WORKER_DIM_SUPERVISOR
	,WD.ID_PRSN_SPRV
	,WD.ID_RMTS_GROUP_COORD	
	,WD.ID_LOCATION_DIM_WORKER
	,WD.CD_JOB_CLS
	,WD.TX_JOB_CLS
	,WD.CD_RMTS_WRKR_TYP
	,WD.TX_RMTS_WRKR_TYP
	,WD.CD_STAT
	,WD.TX_STAT
	,WD.CD_UNT
	,WD.QT_WRK_MEASURE
	,WD.DT_BRTH
	,WD.ID_CYCLE
FROM dbo.WORKER_DIM WD
WHERE WD.IS_CURRENT = 1

UNION

SELECT
	WD.ID_WORKER_DIM
	,WD.ID_PRSN
	,WD.ID_WORKER_DIM_SUPERVISOR
	,WD.ID_PRSN_SPRV
	,WD.ID_RMTS_GROUP_COORD
	,WD.ID_LOCATION_DIM_WORKER
	,WD.CD_JOB_CLS
	,WD.TX_JOB_CLS
	,WD.CD_RMTS_WRKR_TYP
	,WD.TX_RMTS_WRKR_TYP
	,WD.CD_STAT
	,WD.TX_STAT
	,WD.CD_UNT
	,WD.QT_WRK_MEASURE
	,WD.DT_BRTH
	,WD.ID_CYCLE
FROM dbo.WORKER_DIM WD
WHERE WD.ID_WORKER_DIM = 0





GO
