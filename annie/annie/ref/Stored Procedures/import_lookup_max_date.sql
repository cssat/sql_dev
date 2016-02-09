CREATE PROCEDURE [ref].[import_lookup_max_date]
AS
TRUNCATE TABLE ref.lookup_max_date

INSERT ref.lookup_max_date (
	id
	,procedure_name
	,max_date_all
	,max_date_any
	,max_date_qtr
	,max_date_yr
	,min_date_any
	,is_current
	)
SELECT
	id
	,procedure_name
	,max_date_all
	,max_date_any
	,max_date_qtr
	,max_date_yr
	,min_date_any
	,is_current
FROM CA_ODS.dbo.ref_lookup_max_date
