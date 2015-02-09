DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_rate_referrals_order_ts`(p_date varchar(3000),p_cd_region varchar(100),p_nth_order varchar(100))
BEGIN

SELECT DISTINCT
	CONVERT(RR.start_date, DATE) AS 'Date'
	,RR.old_region_cd
	,LC.old_region AS 'Region'
	,RR.nth_order AS 'cd_order'
	,O.tx_order AS 'Order'
	,ROUND(RR.referral_rate, 2) AS 'Placement Rate'
	,ROUND(RR.trend, 2) AS 'Trend'
	,ROUND(RR.seasonal, 2) AS 'Seasonal'
FROM rate_referrals_order_specific_ts AS RR
	JOIN ref_filter_order AS O
		ON O.cd_order = RR.nth_order
	JOIN ref_lookup_county_region AS LC
		ON RR.old_region_cd = LC.old_region_cd
WHERE RR.start_date >= '2009-07-01'
	AND	find_in_set(RR.old_region_cd, p_cd_region) > 0
	AND find_in_set(RR.nth_order, p_nth_order) > 0
ORDER BY
	RR.old_region_cd
	,RR.start_date asc
	,RR.nth_order;
END$$
DELIMITER ;

DROP PROCEDURE `test_annie`.`sp_mp_rate_referrals_order_ts`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_referrals_order_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(start_date, DATE) AS 'Date'
	,old_region_cd AS 'Region'
	,nth_order - 1 AS 'Order'
	,ROUND(referral_rate, 2) AS 'Placement Rate'
	,ROUND(trend, 2) AS 'Trend'
FROM rate_referrals_order_specific_ts
WHERE start_date >= '2009-07-01'
ORDER BY
	old_region_cd
	,start_date asc
	,nth_order;
END$$
DELIMITER ;
