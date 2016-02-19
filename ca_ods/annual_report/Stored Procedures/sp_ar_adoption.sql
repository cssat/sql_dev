CREATE PROCEDURE annual_report.sp_ar_adoption (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,ROUND(adopt_in_365 * 100, 2) AS 'Percent'
FROM [annual_report].[non_cfsr_permanency]
ORDER BY dat_year
	,region
	,sex
	,race
	,age_cat;
