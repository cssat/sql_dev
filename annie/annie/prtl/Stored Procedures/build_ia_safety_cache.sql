CREATE PROCEDURE [prtl].[build_ia_safety_cache]
AS
TRUNCATE TABLE prtl.ia_safety_cache

IF EXISTS (
		SELECT *
		FROM sys.indexes i
		WHERE name = 'idx_ia_safety_cache'
			AND object_id = OBJECT_ID('prtl.ia_safety_cache')
		)
	DROP INDEX idx_ia_safety_cache ON prtl.ia_safety_cache

INSERT prtl.ia_safety_cache (
	row_id
	,month
	,qry_type
	,start_year
	,age_sib_group_cd
	,cd_race_census
	,cd_county
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	,among_first_cmpt_rereferred
	)
SELECT
	ROW_NUMBER() OVER(ORDER BY ia.qry_type
		,ia.cohort_begin_date
		,ia.age_sib_group_cd
		,ia.cd_race_census
		,ia.cd_county
		,ia.cd_access_type
		,ia.cd_reporter_type
		,ia.cd_allegation
		,ia.cd_finding
		,n.number
		) [row_id]
	,n.number [month]
	,ia.qry_type
	,YEAR(ia.cohort_begin_date) [start_year]
	,ia.age_sib_group_cd
	,ia.cd_race_census
	,ia.cd_county
	,ia.cd_reporter_type
	,ia.cd_access_type
	,ia.cd_allegation
	,ia.cd_finding
	,SUM(IIF(ia.total_families > 0, ia.cnt_case, 0)) / (ia.total_families * 1.00) * 100 [among_first_cmpt_rereferred]
FROM (
	SELECT qry_type
		,cohort_begin_date
		,nxt_ref_within_min_month
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_sib_group_cd
		,cd_race_census
		,cd_county
		,cnt_case
		,SUM(cnt_case) OVER(PARTITION BY qry_type, cohort_begin_date, age_sib_group_cd, cd_race_census, cd_county, cd_reporter_type, cd_access_type, cd_allegation, cd_finding) [total_families]
	FROM (
		SELECT CONVERT(TINYINT, ia.qry_type) [qry_type]
			,ia.cohort_begin_date
			,CONVERT(TINYINT, masg.age_sib_group_cd) [age_sib_group_cd]
			,CONVERT(TINYINT, mrc.cd_race_census) [cd_race_census]
			,CONVERT(TINYINT, mc.cd_county) [cd_county]
			,CONVERT(TINYINT, mrt.cd_reporter_type) [cd_reporter_type]
			,CONVERT(TINYINT, mat.cd_access_type) [cd_access_type]
			,CONVERT(TINYINT, ma.cd_allegation) [cd_allegation]
			,CONVERT(TINYINT, mf.cd_finding) [cd_finding]
			,SUM(ia.cnt_case) [cnt_case]
			,ia.nxt_ref_within_min_month
		FROM prtl.ia_safety ia
		INNER JOIN ref.match_age_sib_group_cd masg ON masg.age_sib_group_match_code = ia.cd_sib_age_grp
		INNER JOIN ref.match_cd_race_census mrc ON mrc.race_census_match_code = ia.cd_race_census
		INNER JOIN ref.match_cd_county mc ON mc.county_match_code = ia.county_cd
		INNER JOIN ref.match_cd_reporter_type mrt ON mrt.reporter_type_match_code = ia.cd_reporter_type
		INNER JOIN ref.match_cd_access_type mat ON mat.filter_access_type = ia.filter_access_type
		INNER JOIN ref.match_allegation ma ON ma.filter_allegation = ia.filter_allegation
		INNER JOIN ref.match_finding mf ON mf.filter_finding = ia.filter_finding
		GROUP BY ia.qry_type
			,ia.cohort_begin_date
			,masg.age_sib_group_cd
			,mrc.cd_race_census
			,mc.cd_county
			,mrt.cd_reporter_type
			,mat.cd_access_type
			,ma.cd_allegation
			,mf.cd_finding
			,ia.nxt_ref_within_min_month
		) ia
	) ia
INNER JOIN ref.lookup_max_date lmd ON ia.cohort_begin_date BETWEEN lmd.min_date_any AND lmd.max_date_any
	AND lmd.id = 6 -- sp_ia_safety
INNER JOIN ref.numbers n ON n.number >= ia.nxt_ref_within_min_month
	AND n.ia_safety_group = 1
INNER JOIN ref.last_dw_transfer dw ON dw.cutoff_date >= DATEADD(MONTH, 12 + n.number, ia.cohort_begin_date)
GROUP BY ia.qry_type
	,ia.cohort_begin_date
	,ia.age_sib_group_cd
	,ia.cd_race_census
	,ia.cd_county
	,ia.cd_reporter_type
	,ia.cd_access_type
	,ia.cd_allegation
	,ia.cd_finding
	,ia.total_families
	,n.number

CREATE NONCLUSTERED INDEX idx_ia_safety_cache ON prtl.ia_safety_cache (
	age_sib_group_cd
	,cd_race_census
	,cd_county
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	) INCLUDE (
	row_id
	,qry_type
	,start_year
	,month
	,among_first_cmpt_rereferred
	)

UPDATE STATISTICS prtl.ia_safety_cache
