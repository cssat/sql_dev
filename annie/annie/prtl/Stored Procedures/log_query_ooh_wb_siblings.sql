CREATE PROCEDURE [prtl].[log_query_ooh_wb_siblings]
	@age_grouping_cd VARCHAR(20)
	,@pk_gender VARCHAR(10)
	,@cd_race_census VARCHAR(30)
	,@initial_cd_placement_setting VARCHAR(30)
	,@longest_cd_placement_setting VARCHAR(30)
	,@cd_county VARCHAR(200)
	,@bin_los_cd VARCHAR(30)
	,@bin_placement_cd VARCHAR(30)
	,@bin_ihs_service_cd VARCHAR(30)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	,@bin_dependency_cd VARCHAR(20)
AS
DECLARE @qry_id INT
	,@max_month_start DATETIME
	,@min_month_start DATETIME

DECLARE @tblqryid TABLE (qry_id INT);

SELECT @min_month_start = min_date_any
	,@max_month_start = max_date_any
FROM ref.lookup_max_date
WHERE id = 13; -- sp_ooh_wb_siblings

SET @qry_id = (
		SELECT TOP 1 qry_id
		FROM prtl.ooh_wb_siblings_params
		WHERE age_grouping_cd = @age_grouping_cd
			AND pk_gender = @pk_gender
			AND cd_race_census = @cd_race_census
			AND initial_cd_placement_setting = @initial_cd_placement_setting
			AND longest_cd_placement_setting = @longest_cd_placement_setting
			AND cd_county = @cd_county
			AND bin_los_cd = @bin_los_cd
			AND bin_placement_cd = @bin_placement_cd
			AND bin_ihs_service_cd = @bin_ihs_service_cd
			AND cd_reporter_type = @cd_reporter_type
			AND cd_access_type = @cd_access_type
			AND cd_allegation = @cd_allegation
			AND cd_finding = @cd_finding
			AND bin_dependency_cd = @bin_dependency_cd
		ORDER BY qry_ID DESC
		);

IF @qry_Id IS NULL
BEGIN
	INSERT INTO prtl.ooh_wb_siblings_params (
		age_grouping_cd
		,pk_gender
		,cd_race_census
		,initial_cd_placement_setting
		,longest_cd_placement_setting
		,cd_county
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_service_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,bin_dependency_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		)
	OUTPUT inserted.qry_id
	INTO @tblqryid
	SELECT @age_grouping_cd
		,@pk_gender
		,@cd_race_census
		,@initial_cd_placement_setting
		,@longest_cd_placement_setting
		,@cd_county
		,@bin_los_cd
		,@bin_placement_cd
		,@bin_ihs_service_cd
		,@cd_reporter_type
		,@cd_access_type
		,@cd_allegation
		,@cd_finding
		,@bin_dependency_cd
		,@min_month_start
		,@max_month_start
		,1 [cnt_qry]
		,GETDATE() [last_run_date];
END
ELSE
BEGIN
	UPDATE prtl.ooh_wb_siblings_params
	SET cnt_qry = cnt_qry + 1
		,last_run_date = GETDATE()
	WHERE qry_id = @qry_id;
END
