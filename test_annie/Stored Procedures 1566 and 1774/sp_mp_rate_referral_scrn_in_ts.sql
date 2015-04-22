DROP PROCEDURE `test_annie`.`sp_mp_rate_referral_scrn_in_ts`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_referral_scrn_in_ts`()
BEGIN
SELECT 
	CONVERT(start_date, DATE) AS 'Month/Year of Screened-In Report'
	,old_region_cd AS 'Region'
	,entry_point AS 'Access Type'
	,ROUND(referral_rate, 2) AS 'Scatterplot (Actual Values)'
	,ROUND(trend, 2) AS 'Trend Line (Seasonally Adjusted)'
FROM rate_referrals_scrn_in_ts
WHERE start_date >= '2009-02-01'
ORDER BY
	old_region_cd
	,start_date asc
	,entry_point;
END$$
DELIMITER ;