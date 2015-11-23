CREATE PROCEDURE [setup].[populate_param_sets_ia]
AS
IF (
		SELECT COUNT(*)
		FROM prtl.param_sets_ia
		) = 0
BEGIN
	INSERT prtl.param_sets_ia (
		cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		)
	SELECT rt.cd_reporter_type
		,at.cd_access_type
		,al.cd_allegation
		,f.cd_finding
	FROM ref.filter_reporter_type rt
	CROSS JOIN ref.filter_access_type at
	CROSS JOIN ref.filter_allegation al
	CROSS JOIN ref.filter_finding f
	ORDER BY 1
		,2
		,3
		,4

    UPDATE STATISTICS prtl.param_sets_ia
END
