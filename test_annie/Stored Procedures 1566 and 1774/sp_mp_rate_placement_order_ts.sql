

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_placement_order_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(cohort_date, DATE) AS 'Cohort Date'
	,old_region_cd AS 'Region'
	,nth_order - 1 as 'Order'
	,ROUND(placement_rate, 2) AS 'Scatterplot Values'
	,ROUND(trend, 2) AS 'Trend Line Values'
FROM rate_placement_order_specific_ts AS RPO
	JOIN ref_filter_order AS O
		ON RPO.nth_order = O.cd_order
WHERE cohort_date >= '2009-07-01'
ORDER BY
	old_region_cd
	,cohort_date asc
	,nth_order;
END$$
DELIMITER ;














