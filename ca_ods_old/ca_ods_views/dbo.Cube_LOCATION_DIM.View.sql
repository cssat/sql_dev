USE [CA_ODS]
GO
/****** Object:  View [dbo].[Cube_LOCATION_DIM]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Cube_LOCATION_DIM]
AS
SELECT
	LD.ID_LOCATION_DIM
	,LD.CD_LCTN
	,LD.TX_LCTN
	,LD.CD_TOWN
	,LD.TX_TOWN
	,LD.CD_UNIT
	,LD.TX_UNIT
	,LD.CD_ACTIVE
	,LD.CD_RGN
	,LD.CD_STATE
	,ISNULL(LD.CD_ZIP, '-99') [CD_ZIP]
	,LD.zip_5
	,LD.CD_CITY_TYPE
	,LD.TX_CITY_TYPE
	,LD.ID_CYCLE
	,LD.CD_OFFICE
	,LD.TX_OFFICE
	,OD.cd_office_collapse
	,OD.tx_office_collapse
	,LD.CD_CNTY
	,LD.TX_CNTY
	,RCC.court_cd
	,RCC.court
	,RLC.cd_region
	,RLC.tx_region
	,RLC.old_region_cd
	,RLC.old_region_tx
FROM dbo.LOCATION_DIM LD
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,LD.TX_REGION [old_region_tx]
	FROM dbo.ref_lookup_county RLC
	LEFT JOIN dbo.LOCATION_DIM LD ON
		LD.CD_REGION = RLC.cd_region
			AND LD.IS_CURRENT = 1
	LEFT JOIN dbo.LOCATION_DIM OLD ON
		OLD.CD_REGION = RLC.old_region_cd
			AND LD.IS_CURRENT = 1
	GROUP BY
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION
		,RLC.old_region_cd
		,LD.TX_REGION
) RLC ON
	RLC.county_cd = LD.CD_CNTY
LEFT JOIN dbCoreAdministrativeTables.dbo.ref_county_court_xwalk RCC ON
	RCC.county_cd = LD.CD_CNTY
LEFT JOIN (
	SELECT
		cd_office
		,cd_office_collapse
		,tx_office_collapse
	FROM dbo.ref_xwalk_cd_office_dcfs
	GROUP BY
		cd_office
		,cd_office_collapse
		,tx_office_collapse
) OD ON
	OD.cd_office = LD.CD_OFFICE
WHERE LD.CD_LCTN IS NOT NULL



GO
