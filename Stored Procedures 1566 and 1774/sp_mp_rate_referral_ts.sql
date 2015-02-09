
DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_referral_ts`(p_date varchar(3000))
BEGIN
SELECT 
	CONVERT(start_date, DATE) AS 'Date' 
	,old_region_cd AS 'Region'
	,entry_point AS 'Access Type'
	,ROUND(referral_rate, 4) AS 'Referral Rate'
	,ROUND(trend, 4) AS 'Trend'
FROM rate_referrals_ts
WHERE start_date >= '2009-07-01'
ORDER BY
	old_region_cd
	,start_date asc
	,entry_point asc;
END$$
DELIMITER ;

