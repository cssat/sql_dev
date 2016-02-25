
CREATE PROCEDURE annual_report.sp_ar_cfsr_recurrence (@p_date VARCHAR(3000))
AS
SELECT DATEFROMPARTS(dat_year, 10, 1) AS 'Fiscal Year'
	,recurrence_of_maltreatment AS 'Percent'
FROM [annual_report].[cfsr_safety];
