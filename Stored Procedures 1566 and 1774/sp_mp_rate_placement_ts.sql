DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_rate_placement_ts`(p_date varchar(3000), p_cd_region varchar(200),p_entry_point varchar(30))
BEGIN
SELECT 
	CONVERT(TD.cohort_date, DATE) AS 'Cohort Date'
	,TD.old_region_cd
	,LC.old_region AS 'Region'
	,TD.entry_point AS 'cd_access_type'
	,A.tx_access_type AS 'Access type desc'
	,ROUND(TD.rate_placement, 2) AS 'Placement Rate'
	,ROUND(TD.trend, 2) AS 'Trend'
	,ROUND(TD.seasonal, 2) AS 'Seasonal'
FROM test_annie.rate_placement_ts AS TD
	LEFT JOIN ref_filter_access_type AS A
		ON TD.entry_point = A.cd_access_type
	LEFT JOIN ref_lookup_region AS LC
		ON TD.old_region_cd = LC.old_region_cd
WHERE cohort_date >= '2009-07-01'
	AND	find_in_set(TD.old_region_cd, p_cd_region) > 0
	AND find_in_set(TD.entry_point, p_entry_point) > 0
ORDER BY
	TD.old_region_cd
	,TD.cohort_date asc
	,TD.entry_point;
END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_placement_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(cohort_date, DATE) AS 'Cohort Date'
	,old_region_cd AS 'Region'
	,entry_point AS 'cd_access_type'
	,ROUND(rate_placement, 2) AS 'Placement Rate'
	,ROUND(trend, 2) AS 'Trend'
FROM test_annie.rate_placement_ts AS TD
WHERE cohort_date >= '2009-07-01';
END$$
DELIMITER ;































