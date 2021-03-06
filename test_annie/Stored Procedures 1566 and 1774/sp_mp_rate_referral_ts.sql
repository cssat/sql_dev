DROP PROCEDURE `test_annie`.`sp_mp_rate_referral_ts`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_referral_ts`()
BEGIN
SELECT 
	CONVERT(start_date, DATE) AS 'Month/Year of Report' 
	,old_region_cd AS 'Region'
	,entry_point AS 'Access Type'
	,ROUND(referral_rate, 2) AS 'Scatterplot (Actual Values)'
	,ROUND(trend, 2) AS 'Trend Line (Seasonally Adjusted)'
FROM rate_referrals_ts
WHERE start_date >= '2009-02-01'
ORDER BY
	old_region_cd
	,start_date asc
	,entry_point asc;
END$$
DELIMITER ;
