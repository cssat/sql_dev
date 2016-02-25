CREATE PROCEDURE annual_report.sp_ar_cfsr_permanency_exits (
	@p_date VARCHAR(3000)
	,@p_cd_discharge VARCHAR(200)
	)
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,cd_discharge AS 'Discharge Type'
	,time_period
	,[percent]
FROM annual_report.cfsr_permanency_exits AS cpe
JOIN dbo.fn_ReturnStrTableFromList(@p_cd_discharge, 1) AS dv -- second argument in function is a bit (false/true) for eliminating or keeping duplicate inputs
	ON cpe.cd_discharge = dv.arrValue
WHERE cd_discharge != 2
	AND [percent] IS NOT NULL;