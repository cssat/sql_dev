DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_referral_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(start_date, DATE) AS 'Month/Year of Report' 
	,old_region_cd AS 'Region'
	,entry_point AS 'Access Type'
	,ROUND(referral_rate, 2) AS 'Scatterplot (Actual Values)'
	,ROUND(trend, 2) AS 'Trend Line (Seasonal Variation)'
FROM rate_referrals_ts
WHERE start_date >= '2009-07-01'
ORDER BY
	old_region_cd
	,start_date asc
	,entry_point asc;
END$$
DELIMITER ;
