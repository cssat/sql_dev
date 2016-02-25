CREATE PROCEDURE annual_report.sp_ar_cfsr_permanency_re_entry (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,cd_discharge AS 'Discharge Type'
	,re_entry AS 'Percent'
FROM [annual_report].[cfsr_permanency]
WHERE cd_discharge != 2
	AND cd_discharge IN (
		0
		,1
		,5
		);
