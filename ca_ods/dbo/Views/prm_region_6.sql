CREATE VIEW [dbo].[prm_region_6]
AS
SELECT DISTINCT region_6_cd
	,region_6_cd [match]
FROM dbo.ref_lookup_county_region
WHERE region_6_cd != 0

UNION ALL

SELECT DISTINCT 0
	,region_6_cd [match]
FROM dbo.ref_lookup_county_region
WHERE region_6_cd != 0
