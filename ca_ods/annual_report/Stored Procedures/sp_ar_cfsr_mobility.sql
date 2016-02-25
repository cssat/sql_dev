CREATE PROCEDURE annual_report.sp_ar_cfsr_mobility (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,placement_stability AS 'Rate'
FROM [annual_report].[cfsr_permanency_placement_mobility];