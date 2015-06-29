CREATE PROCEDURE [prtl].[import_lookup_max_date]
AS
INSERT ref.lookup_max_date (
	id
	,[procedure_name]
	,max_date_all
	,max_date_any
	,max_date_qtr
	,max_date_yr
	,min_date_any
	,is_current
	)
SELECT id
	,[procedure_name]
	,max_date_all
	,max_date_any
	,max_date_qtr
	,max_date_yr
	,min_date_any
	,is_current
FROM ca_ods.dbo.ref_lookup_max_date

UPDATE STATISTICS ref.lookup_max_date
