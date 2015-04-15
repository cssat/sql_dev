DROP PROCEDURE `test_annie`.`sp_mp_rate_placement_ts`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_placement_ts`()
BEGIN
SELECT 
	CONVERT(cohort_date, DATE) AS 'Month/Year of Placement'
	,old_region_cd AS 'Region'
	,entry_point AS 'Access Type'
	,ROUND(rate_placement, 2) AS 'Scatterplot (Actual Values)'
	,ROUND(trend, 2) AS 'Trend Line (Seasonally Adjusted)'
FROM test_annie.rate_placement_ts AS TD
WHERE cohort_date >= '2009-02-01';
END$$
DELIMITER ;


































