DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_placement_order_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(cohort_date, DATE) AS 'Month/Year of Ordered Placement'
	,old_region_cd AS 'Region'
	,nth_order - 1 as 'Order'
	-- ,o.tx_order AS 'Order'
	,ROUND(placement_rate, 2) AS 'Scatterplot (Actual Values)'
	,ROUND(trend, 2) AS 'Trend Line (Seasonal Variation)'
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
