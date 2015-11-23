CREATE PROCEDURE [setup].[populate_param_sets_geog]
AS
IF (
		SELECT COUNT(*)
		FROM prtl.param_sets_geog
		) = 0
BEGIN
	INSERT prtl.param_sets_geog (
		cd_county
		,cd_region_three
		,cd_region_six
		)
	SELECT cd_county
		,0 [cd_region_three]
		,0 [cd_region_six]
	FROM ref.lookup_county
	
	UNION ALL
	
	SELECT 0 [cd_county]
		,cd_region_three
		,0 [cd_region_six]
	FROM ref.lookup_region_three
	WHERE cd_region_three != 0
	
	UNION ALL
	
	SELECT 0 [cd_county]
		,0 [cd_region_three]
		,cd_region_six
	FROM ref.lookup_region_six
	WHERE cd_region_six != 0
	ORDER BY 1
		,2
		,3

    UPDATE STATISTICS prtl.param_sets_geog
END
