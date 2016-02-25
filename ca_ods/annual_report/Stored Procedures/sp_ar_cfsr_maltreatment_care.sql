
CREATE PROCEDURE annual_report.sp_ar_cfsr_maltreatment_care (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,maltreatment_in_care AS 'Rate'
FROM [annual_report].[cfsr_safety];
