CREATE VIEW [dbo].[cube_prtl_poc1ab_time]
AS


with cte_maxdate as (select min_date_any,max_date_any from ref_lookup_max_date where id=19)

SELECT pk_key
	,[CALENDAR_DATE]
	,ISNULL(YEAR(CD.[YEAR]), -99) [YEAR]
	,ISNULL(CD.YEAR_NAME, 'Unspecified') [YEAR_NAME]
	,ISNULL(CONVERT(INT, RIGHT(CD.YEAR_NAME, 4) + CONVERT(CHAR(1), CD.QUARTER_OF_YEAR)), -99) [QUARTER]
	,ISNULL(CD.QUARTER_NAME, 'Unspecified') [QUARTER_NAME]
FROM dbo.cube_prtl_poc1ab_fact
, dbo.CALENDAR_DIM CD,cte_maxdate
where [CALENDAR_DATE] between min_date_any and max_date_any
and start_date=CALENDAR_DATE