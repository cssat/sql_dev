CREATE PROCEDURE annual_report.sp_ar_reports (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(fiscal_year, 10, 1) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,report_rate AS 'Rate'
FROM [annual_report].[non_cfsr_safety]
ORDER BY fiscal_year
	,region
	,sex
	,race
	,age_cat;
