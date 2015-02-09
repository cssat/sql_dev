DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_rate_placement_order_ts`(p_date varchar(3000),p_cd_region varchar(100),p_nth_order varchar(100))
BEGIN

SELECT 
	CONVERT(RPO.cohort_date, DATE) AS 'Cohort Date'
	,RPO.old_region_cd
	,LC.old_region AS 'Region'
	,RPO.nth_order as 'cd_order'
	,o.tx_order AS 'Order'
	,rpo.cnt_nth_order_placement_cases AS 'cnt_households'
	,rpo.cnt_prior_order_si_referrals AS 'cnt_si_referrals'
	,ROUND(RPO.placement_rate, 2) AS 'Placement Rate'
	,ROUND(RPO.trend, 2) AS 'Trend'
	,ROUND(RPO.seasonal, 2) AS 'Seasonal'
FROM rate_placement_order_specific_ts AS RPO
	JOIN ref_filter_order AS O
		ON RPO.nth_order = O.cd_order
	JOIN ref_lookup_region AS LC
		ON RPO.old_region_cd = LC.old_region_cd
WHERE cohort_date >= '2009-07-01'
	AND	find_in_set(RPO.old_region_cd, p_cd_region) > 0
	AND find_in_set(RPO.nth_order , p_nth_order) > 0
ORDER BY
	RPO.old_region_cd
	,RPO.cohort_date asc
	,RPO.nth_order;
END$$
DELIMITER ;

CALL `test_annie`.`sp_rate_placement_order_ts`('0', '0', '1');

DROP PROCEDURE `test_annie`.`sp_mp_rate_placement_order_ts`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_placement_order_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(cohort_date, DATE) AS 'Cohort Date'
	,old_region_cd AS 'Region'
	,nth_order - 1 as 'Order'
	-- ,o.tx_order AS 'Order'
	,ROUND(placement_rate, 2) AS 'Placement Rate'
	,ROUND(trend, 2) AS 'Trend'
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

CALL `test_annie`.`sp_mp_rate_placement_order_ts`('0');

