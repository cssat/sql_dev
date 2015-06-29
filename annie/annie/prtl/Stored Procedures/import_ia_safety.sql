CREATE PROCEDURE [prtl].[import_ia_safety]
AS
TRUNCATE TABLE prtl.ia_safety

INSERT prtl.ia_safety (
	cohort_begin_date
	,date_type
	,qry_type
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cd_sib_age_grp
	,cd_race_census
	,census_hispanic_latino_origin_cd
	,county_cd
	,init_ref
	,init_fnd_ref
	,cohort_ref_count
	,cohort_fnd_ref_count
	,case_founded_recurrence
	,case_repeat_referral
	,cnt_case
	,nxt_ref_within_min_month
	)
SELECT cohort_begin_date
	,date_type
	,qry_type
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cd_sib_age_grp
	,cd_race_census
	,census_hispanic_latino_origin_cd
	,county_cd
	,initref
	,initfndref
	,cohortrefcount
	,cohortfndrefcount
	,case_founded_recurrence
	,case_repeat_referral
	,cnt_case
	,nxt_ref_within_min_month
FROM ca_ods.prtl.prtl_pbcs2

UPDATE STATISTICS prtl.ia_safety
