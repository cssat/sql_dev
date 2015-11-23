CREATE FUNCTION [prtl].[min_ooh_filter_date] (
	@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	,@bin_dependency_cd VARCHAR(20)
	)
RETURNS DATETIME
AS
BEGIN
	DECLARE @min_filter_date DATETIME
	DECLARE @access_type TABLE (cd_access_type TINYINT)
	DECLARE @allegation TABLE (cd_allegation TINYINT)
	DECLARE @finding TABLE (cd_finding TINYINT)
	DECLARE @bin_dependency TABLE (bin_dependency_cd TINYINT)

	INSERT @access_type (cd_access_type)
	SELECT CONVERT(TINYINT, arrValue)
	FROM prtl.fn_ReturnStrTableFromList(@cd_access_type, 0)

	INSERT @allegation (cd_allegation)
	SELECT CONVERT(TINYINT, arrValue)
	FROM prtl.fn_ReturnStrTableFromList(@cd_allegation, 0)

	INSERT @finding (cd_finding)
	SELECT CONVERT(TINYINT, arrValue)
	FROM prtl.fn_ReturnStrTableFromList(@cd_finding, 0)

	INSERT @bin_dependency (bin_dependency_cd)
	SELECT CONVERT(TINYINT, arrValue)
	FROM prtl.fn_ReturnStrTableFromList(@bin_dependency_cd, 0)

	SELECT @min_filter_date = MAX(db_min_filter_date)
	FROM (
		SELECT MAX(fat.min_filter_date) [db_min_filter_date]
		FROM ref.filter_access_type fat
		INNER JOIN @access_type at ON at.cd_access_type = fat.cd_access_type

		UNION

		SELECT MAX(fa.min_filter_date) [db_min_filter_date]
		FROM ref.filter_allegation fa
		INNER JOIN @allegation a ON a.cd_allegation = fa.cd_allegation

		UNION

		SELECT MAX(ff.min_filter_date) [db_min_filter_date]
		FROM ref.filter_finding ff
		INNER JOIN @finding f ON f.cd_finding = ff.cd_finding

		UNION

		SELECT MAX(fd.min_filter_date) [db_min_filter_date]
		FROM ref.filter_dependency fd
		INNER JOIN @bin_dependency bd ON bd.bin_dependency_cd = fd.bin_dependency_cd

		UNION

		SELECT CONVERT(DATETIME, '1/1/2000') [db_min_filter_date]
		) a

	RETURN @min_filter_date
END
