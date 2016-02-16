CREATE PROCEDURE prtl.prod_build_order_specific_placement_rate
AS
IF OBJECT_ID('tempDB..#cases_from_intakes_placements') IS NOT NULL
	DROP TABLE #cases_from_intakes_placements

SELECT DISTINCT 0 date_type
	,2 qry_type
	,intk.id_intake_fact
	,intk.county_cd
	,intk.id_case
	,q.id_case id_case_removal
	,intk.rfrd_date
	,q.removal_dt
	,DATEFROMPARTS(YEAR(intk.rfrd_date), MONTH(intk.rfrd_date), DAY(0)) cohort_date
INTO #cases_from_intakes_placements
FROM (
	SELECT id_case
		,id_intake_fact
		,intake_county_cd county_cd
		,rfrd_date -- , (select top 1 removal_dt from base.rptPlacement plc where plc.id_intake_fact is not null and plc.id_intake_fact=intk.id_intake_fact order by removal_dt)  removal_dt
	FROM base.tbl_intakes intk
	WHERE id_case > 0
		AND EXISTS (
			SELECT id_case
			FROM base.tbl_household_children chld
			WHERE chld.id_intake_fact = intk.id_intake_fact
				AND age_at_referral_dt < 18
				AND id_case > 0
			)
	) intk
LEFT JOIN (
	SELECT id_case
		,id_intake_fact
		,(
			SELECT TOP 1 rfrd_date
			FROM base.tbl_intakes intk
			WHERE intk.id_intake_fact = plc.id_intake_fact
			) rfrd_date
		,removal_dt
	FROM base.rptPlacement plc
	WHERE id_intake_fact IS NOT NULL
		AND age_at_removal_mos < (18 * 12)
	) q ON q.id_intake_fact = intk.id_intake_fact

IF OBJECT_ID('tempDB..#case_placement_rankings') IS NOT NULL
	DROP TABLE #case_placement_rankings

SELECT p1.cohort_date
	,p1.id_case
	,p1.county_cd
	,p1.id_intake_fact
	,p1.rfrd_date
	,(
		SELECT COUNT(DISTINCT p2.id_intake_fact)
		FROM #cases_from_intakes_placements p2
		WHERE p2.removal_dt IS NOT NULL
			AND p2.id_case = p1.id_case
			AND p2.rfrd_date < p1.rfrd_date
		) prior_placement_rank
INTO #case_placement_rankings
FROM #cases_from_intakes_placements p1
ORDER BY p1.id_case
	,p1.rfrd_date ASC

/** qa
SELECT *
FROM #case_placement_rankings
ORDER BY id_case
	,rfrd_date

SELECT *
FROM #case_placement_rankings
WHERE id_case = 65037
ORDER BY id_case
	,rfrd_date

SELECT *
FROM #cases_from_intakes_placements
WHERE id_case = 65037
ORDER BY id_case
	,rfrd_date
**/
TRUNCATE TABLE prtl.rate_placement_order_specific

INSERT INTO prtl.rate_placement_order_specific (
	date_type
	,qry_type
	,cohort_date
	,nth_order
	,county_cd
	,cnt_nth_order_placement_cases
	,cnt_prior_order_si_referrals
	,placement_rate
	)
SELECT 0 date_type
	,2 qry_type
	,mnth.cohort_date
	,nth_order.number nth_order
	,cnty.county_cd
	,COALESCE(cnt_case, 0) cnt_nth_order_placement_cases
	,COALESCE(cnt_prior_case, 0) cnt_prior_order_si_referrals
	,IIF(cnt_prior_case != 0
		AND cnt_case != 0, cnt_case / (cnt_prior_case * 1.0000) * 1000, NULL) placement_rate
FROM (
	SELECT DISTINCT [Month] cohort_date
	FROM Calendar_dim
		,ref_last_dw_transfer
	WHERE [Month] BETWEEN '2000-01-01'
			AND DATEADD(mm, - 1, cutoff_date)
	) mnth
JOIN ref_lookup_county cnty ON cnty.county_cd BETWEEN 0
		AND 39
JOIN numbers nth_order ON nth_order.number BETWEEN 1
		AND 3
LEFT JOIN (
	SELECT 0 date_type
		,2 qry_type
		,cohort_date
		,cnty.cd_cnty "county_cd"
		,prior_placement_rank AS nth_order_plcmnt
		,COUNT(DISTINCT id_case) cnt_case
	FROM #case_placement_rankings
	JOIN prm_cnty cnty ON cnty.match_code = county_cd
	GROUP BY cohort_date
		,cnty.cd_cnty
		,prior_placement_rank
	) cases_with_plcm ON cases_with_plcm.county_cd = cnty.county_cd
	AND cases_with_plcm.cohort_date = mnth.cohort_date
	AND nth_order.number = cases_with_plcm.nth_order_plcmnt
LEFT JOIN (
	SELECT 0 date_type
		,2 qry_type
		,cohort_date
		,cnty.cd_cnty "county_cd"
		,prior_placement_rank AS nth_order_plcmnt
		,COUNT(DISTINCT id_case) cnt_prior_case
	FROM #case_placement_rankings
	JOIN prm_cnty cnty ON cnty.match_code = county_cd
	GROUP BY cohort_date
		,cnty.cd_cnty
		,prior_placement_rank
		--		order by prior_placement_rank,cnty.cd_cnty,cohort_date
	) cases_prior_plcm ON cases_prior_plcm.county_cd = cnty.county_cd
	AND cases_prior_plcm.cohort_date = mnth.cohort_date
	AND nth_order.number = cases_prior_plcm.nth_order_plcmnt + 1
WHERE mnth.cohort_date >= '2004-01-01'
ORDER BY cnty.county_cd
	,number
	,mnth.cohort_date
