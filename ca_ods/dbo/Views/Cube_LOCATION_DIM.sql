CREATE VIEW [dbo].[Cube_LOCATION_DIM]
AS
SELECT
	LD.ID_LOCATION_DIM
	,IIF(LD.ID_LOCATION_DIM = -1, -999, LD.CD_LCTN) [CD_LCTN]
	,LD.TX_LCTN
	,IIF(LD.ID_LOCATION_DIM = -1, -999, ISNULL(LD.CD_UNIT, -99)) [CD_UNIT]
	,ISNULL(LD.TX_UNIT, '-') [TX_UNIT]
	,LD.CD_ACTIVE
	,LD.CD_RGN
	,LD.CD_STATE
	,ISNULL(LD.CD_ZIP, '-99') [CD_ZIP]
	,LD.zip_5
	,ISNULL(LD.CD_CITY_TYPE, 'U') [CD_CITY_TYPE]
	,ISNULL(LD.TX_CITY_TYPE, 'Unknown') [TX_CITY_TYPE]
	,IIF(LD.ID_LOCATION_DIM = -1, -999, LD.CD_OFFICE) [CD_OFFICE]
	,LD.TX_OFFICE
	,IIF(OD.cd_office_collapse = -99, CONVERT(INT, CONVERT(VARCHAR, OD.cd_office_collapse) + CONVERT(VARCHAR, ABS(ISNULL(RLC.cd_region, LD.CD_REGION)))), OD.cd_office_collapse) [cd_office_collapse]
	,IIF(OD.cd_office_collapse = -99, OD.tx_office_collapse + ' - ' + IIF(ISNULL(RLC.cd_region, LD.CD_REGION) = 0, 'Failed', ISNULL(RLC.tx_region, LD.TX_REGION)), OD.tx_office_collapse) [tx_office_collapse]
	,IIF(LD.ID_LOCATION_DIM = -1, -999, IIF(LD.CD_CNTY = 41, -99, LD.CD_CNTY)) [CD_CNTY]
	,IIF(LD.CD_CNTY = 41, 'Unknown', LD.TX_CNTY) [TX_CNTY]
	,ISNULL(RLC.cd_region, LD.CD_REGION) [cd_region]
	,IIF(ISNULL(RLC.cd_region, LD.CD_REGION) = 0, 'Failed', ISNULL(RLC.tx_region, LD.TX_REGION)) [tx_region]
	,ISNULL(RLC.old_region_cd, LD.CD_REGION) [old_region_cd]
	,IIF(ISNULL(RLC.old_region_cd, LD.CD_REGION) = 0, 'Failed', ISNULL(RLC.old_region_tx, LD.TX_REGION)) [old_region_tx]
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
