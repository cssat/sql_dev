



CREATE VIEW [dbo].[Cube_age_dim]
AS

SELECT
	age_mo
	,age_yr
	,census_child_group_cd
	,census_child_group_tx
	,census_20_group_cd
	,census_20_group_tx
	,census_all_group_cd
	,census_all_group_tx
	,developmental_age_cd
	,developmental_age_tx
	,school_age_cd
	,school_age_tx
	,ISNULL(cdc_age_cd, -99) [cdc_age_cd]
	,ISNULL(cdc_age_tx, 'OMIT') [cdc_age_tx]
	,ISNULL(cdc_census_mix_age_cd, -99) [cdc_census_mix_age_cd]
	,ISNULL(cdc_census_mix_age_tx, 'OMIT') [cdc_census_mix_age_tx]
FROM dbo.age_dim AD

UNION

SELECT
	-99 [age_mo]
	,-99 [age_year]
	,-99 [child_group_cd]
	,'OMIT' [child_group_tx]
	,-99 [census_20_group_cd]
	,'OMIT' [census_20_group_tx]
	,-99 [census_all_group_cd]
	,'OMIT' [census_all_group_tx]
	,-99 [develomental_age_cd]
	,'OMIT' [developmental_age_tx]
	,-99 [school_age_cd]
	,'OMIT' [school_age_tx]
	,-99 [cdc_age_cd]
	,'OMIT' [cdc_age_tx]
	,-99 [cdc_census_mix_age_cd]
	,'OMIT' [cdc_census_mix_age_tx]




