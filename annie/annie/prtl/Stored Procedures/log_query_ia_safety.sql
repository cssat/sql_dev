CREATE PROCEDURE [prtl].[log_query_ia_safety]
	@age_sib_group_cd VARCHAR(20)
	,@cd_race_census VARCHAR(30)
	,@cd_county VARCHAR(1000)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
AS
DECLARE @qry_id INT
	,@max_month_start DATETIME
	,@min_month_start DATETIME

DECLARE @tblqryid TABLE (qry_id INT);

SELECT @min_month_start = min_date_any
	,@max_month_start = max_date_any
FROM ref.lookup_max_date
WHERE id = 6; -- sp_ia_safety

SET @qry_id = (
		SELECT TOP 1 qry_id
		FROM prtl.ia_safety_params
		WHERE age_sib_group_cd = @age_sib_group_cd
			AND cd_race_census = @cd_race_census
			AND cd_county = @cd_county
			AND cd_reporter_type = @cd_reporter_type
			AND cd_access_type = @cd_access_type
			AND cd_allegation = @cd_allegation
			AND cd_finding = @cd_finding
		ORDER BY qry_ID DESC
		);

IF @qry_Id IS NULL
BEGIN
	INSERT INTO prtl.ia_safety_params (
		age_sib_group_cd
		,cd_race_census
		,cd_county
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		)
	OUTPUT inserted.qry_id
	INTO @tblqryid
	SELECT @age_sib_group_cd
		,@cd_race_census
		,@cd_county
		,@cd_reporter_type
		,@cd_access_type
		,@cd_allegation
		,@cd_finding
		,@min_month_start
		,@max_month_start
		,1
		,GETDATE();

	SELECT TOP 1 @qry_id = qry_id
	FROM @tblqryid;
END
ELSE
BEGIN
	UPDATE prtl.ia_safety_params
	SET cnt_qry = cnt_qry + 1
		,last_run_date = GETDATE()
	WHERE qry_id = @qry_id;
END
