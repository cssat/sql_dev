﻿




CREATE VIEW [dbo].[Cube_CALENDAR_DIM]
AS

SELECT
	CD.ID_CALENDAR_DIM
	,ISNULL(CD.CALENDAR_DATE, '1/1/1800') [CALENDAR_DATE]
	,ISNULL(CD.YEAR_YYYY, -99) [YEAR_YYYY]
	,ISNULL(CD.MONTH_MM, -99) [MONTH_MM]
	,ISNULL(CD.DAY_DD, -99) [DAY_DD]
	,CD.DATE_NAME
	,ISNULL(YEAR(CD.[YEAR]), -99) [YEAR]
	,ISNULL(CD.YEAR_NAME, 'Unspecified') [YEAR_NAME]
	,ISNULL(CD.[YEAR], '1/1/1800') [YEAR_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.YEAR_NAME, 4) + CONVERT(CHAR(1), CD.QUARTER_OF_YEAR)), -99) [QUARTER]
	,ISNULL(CD.QUARTER_NAME, 'Unspecified') [QUARTER_NAME]
	,ISNULL(CD.[QUARTER], '1/1/1800') [QUARTER_START_DATE]
	,ISNULL(CONVERT(INT, LEFT(CONVERT(VARCHAR, CD.[MONTH], 112), 6)), -99) [MONTH]
	,ISNULL(CD.MONTH_NAME, 'Unspecified') [MONTH_NAME]
	,ISNULL(CD.[MONTH], '1/1/1800') [MONTH_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.YEAR_NAME, 4) + RIGHT(CONVERT(CHAR(3), 100 + CD.WEEK_OF_YEAR), 2)), -99) [WEEK]
	,ISNULL(CD.WEEK_NAME, 'Unspecified') [WEEK_NAME]
	,ISNULL(CD.[WEEK], '1/1/1800') [WEEK_START_DATE]
	,ISNULL(CD.DAY_OF_YEAR, -99) [DAY_OF_YEAR]
	,ISNULL(CD.DAY_OF_YEAR_NAME, 'Unspecified') [DAY_OF_YEAR_NAME]
	,ISNULL(CD.DAY_OF_QUARTER, -99) [DAY_OF_QUARTER]
	,ISNULL(CD.DAY_OF_QUARTER_NAME, 'Unspecified') [DAY_OF_QUARTER_NAME]
	,ISNULL(CD.DAY_OF_MONTH, -99) [DAY_OF_MONTH]
	,ISNULL(CD.DAY_OF_MONTH_NAME, 'Unspecified') [DAY_OF_MONTH_NAME]
	,ISNULL(CD.DAY_OF_WEEK, -99) [DAY_OF_WEEK]
	,ISNULL(CD.DAY_OF_WEEK_NAME, 'Unspecified') [DAY_OF_WEEK_NAME]
	,ISNULL(CD.WEEK_OF_YEAR, -99) [WEEK_OF_YEAR]
	,ISNULL(CD.WEEK_OF_YEAR_NAME, 'Unspecified') [WEEK_OF_YEAR_NAME]
	,ISNULL(CD.MONTH_OF_YEAR, -99) [MONTH_OF_YEAR]
	,ISNULL(CD.MONTH_OF_YEAR_NAME, 'Unspecified') [MONTH_OF_YEAR_NAME]
	,ISNULL(CD.MONTH_OF_QUARTER, -99) [MONTH_OF_QUARTER]
	,ISNULL(CD.MONTH_OF_QUARTER_NAME, 'Unspecified') [MONTH_OF_QUARTER_NAME]
	,ISNULL(CD.QUARTER_OF_YEAR, -99) [QUARTER_OF_YEAR]
	,ISNULL(CD.QUARTER_OF_YEAR_NAME, 'Unspecified') [QUARTER_OF_YEAR_NAME]
	,ISNULL(CONVERT(INT, RIGHT(CD.FEDERAL_FISCAL_YEAR_NAME, 4)), -99) [FEDERAL_FISCAL_YEAR]
	,ISNULL(CD.FEDERAL_FISCAL_YEAR_NAME, 'Unspecified') [FEDERAL_FISCAL_YEAR_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_YEAR, '1/1/1800') [FEDERAL_FISCAL_YEAR_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.FEDERAL_FISCAL_YEAR_NAME, 4) + CONVERT(CHAR(1), CD.FEDERAL_FISCAL_QUARTER_OF_YEAR)), -99) [FEDERAL_FISCAL_QUARTER]
	,ISNULL(CD.FEDERAL_FISCAL_QUARTER_NAME, 'Unspecified') [FEDERAL_FISCAL_QUARTER_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_QUARTER, '1/1/1800') [FEDERAL_FISCAL_QUARTER_START_DATE]
	,ISNULL(CONVERT(INT, LEFT(CONVERT(VARCHAR, CD.FEDERAL_FISCAL_MONTH, 112), 6)), -99) [FEDERAL_FISCAL_MONTH]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH_NAME, 'Unspecified') [FEDERAL_FISCAL_MONTH_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH, '1/1/1800') [FEDERAL_FISCAL_MONTH_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.FEDERAL_FISCAL_YEAR_NAME, 4) + RIGHT(CONVERT(CHAR(3), 100 + CD.FEDERAL_FISCAL_WEEK_OF_YEAR), 2)), -99) [FEDERAL_FISCAL_WEEK]
	,ISNULL(CD.FEDERAL_FISCAL_WEEK_NAME, 'Unspecified') [FEDERAL_FISCAL_WEEK_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_WEEK, '1/1/1800') [FEDERAL_FISCAL_WEEK_START_DATE]
	,ISNULL(CONVERT(INT, CONVERT(VARCHAR, CD.FEDERAL_FISCAL_DAY, 112)), -99) [FEDERAL_FISCAL_DAY]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_NAME, 'Unspecified') [FEDERAL_FISCAL_DAY_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_DAY, '1/1/1800') [FEDERAL_FISCAL_DAY_DATE]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_YEAR, -99) [FEDERAL_FISCAL_DAY_OF_YEAR]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_YEAR_NAME, 'Unspecified') [FEDERAL_FISCAL_DAY_OF_YEAR_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_QUARTER, -99) [FEDERAL_FISCAL_DAY_OF_QUARTER]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_QUARTER_NAME, 'Unspecified') [FEDERAL_FISCAL_DAY_OF_QUARTER_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_MONTH, -99) [FEDERAL_FISCAL_DAY_OF_MONTH]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_MONTH_NAME, 'Unspecified') [FEDERAL_FISCAL_DAY_OF_MONTH_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_WEEK, -99) [FEDERAL_FISCAL_DAY_OF_WEEK]
	,ISNULL(CD.FEDERAL_FISCAL_DAY_OF_WEEK_NAME, 'Unspecified') [FEDERAL_FISCAL_DAY_OF_WEEK_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_WEEK_OF_YEAR, -99) [FEDERAL_FISCAL_WEEK_OF_YEAR]
	,ISNULL(CD.FEDERAL_FISCAL_WEEK_OF_YEAR_NAME, 'Unspecified') [FEDERAL_FISCAL_WEEK_OF_YEAR_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH_OF_YEAR, -99) [FEDERAL_FISCAL_MONTH_OF_YEAR]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH_OF_YEAR_NAME, 'Unspecified') [FEDERAL_FISCAL_MONTH_OF_YEAR_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH_OF_QUARTER, -99) [FEDERAL_FISCAL_MONTH_OF_QUARTER]
	,ISNULL(CD.FEDERAL_FISCAL_MONTH_OF_QUARTER_NAME, 'Unspecified') [FEDERAL_FISCAL_MONTH_OF_QUARTER_NAME]
	,ISNULL(CD.FEDERAL_FISCAL_QUARTER_OF_YEAR, -99) [FEDERAL_FISCAL_QUARTER_OF_YEAR]
	,ISNULL(CD.FEDERAL_FISCAL_QUARTER_OF_YEAR_NAME, 'Unspecified') [FEDERAL_FISCAL_QUARTER_OF_YEAR_NAME]
	,ISNULL(CONVERT(INT, RIGHT(CD.STATE_FISCAL_YEAR_NAME, 4)), -99) [STATE_FISCAL_YEAR]
	,ISNULL(CD.STATE_FISCAL_YEAR_NAME, 'Unspecified') [STATE_FISCAL_YEAR_NAME]
	,ISNULL(CD.STATE_FISCAL_YEAR, '1/1/1800') [STATE_FISCAL_YEAR_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.STATE_FISCAL_YEAR_NAME, 4) + CONVERT(CHAR(1), CD.STATE_FISCAL_QUARTER_OF_YEAR)), -99) [STATE_FISCAL_QUARTER]
	,ISNULL(CD.STATE_FISCAL_QUARTER_NAME, 'Unspecified') [STATE_FISCAL_QUARTER_NAME]
	,ISNULL(CD.STATE_FISCAL_QUARTER, '1/1/1800') [STATE_FISCAL_QUARTER_START_DATE]
	,ISNULL(CONVERT(INT, LEFT(CONVERT(VARCHAR, CD.STATE_FISCAL_MONTH, 112), 6)), -99) [STATE_FISCAL_MONTH]
	,ISNULL(CD.STATE_FISCAL_MONTH_NAME, 'Unspecified') [STATE_FISCAL_MONTH_NAME]
	,ISNULL(CD.STATE_FISCAL_MONTH, '1/1/1800') [STATE_FISCAL_MONTH_START_DATE]
	,ISNULL(CONVERT(INT, RIGHT(CD.STATE_FISCAL_YEAR_NAME, 4) + RIGHT(CONVERT(CHAR(3), 100 + CD.STATE_FISCAL_WEEK_OF_YEAR), 2)), -99) [STATE_FISCAL_WEEK]
	,ISNULL(CD.STATE_FISCAL_WEEK_NAME, 'Unspecified') [STATE_FISCAL_WEEK_NAME]
	,ISNULL(CD.STATE_FISCAL_WEEK, '1/1/1800') [STATE_FISCAL_WEEK_START_DATE]
	,ISNULL(CONVERT(INT, CONVERT(VARCHAR, CD.STATE_FISCAL_DAY, 112)), -99) [STATE_FISCAL_DAY]
	,ISNULL(CD.STATE_FISCAL_DAY_NAME, 'Unspecified') [STATE_FISCAL_DAY_NAME]
	,ISNULL(CD.STATE_FISCAL_DAY, '1/1/1800') [STATE_FISCAL_DAY_DATE]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_YEAR, -99) [STATE_FISCAL_DAY_OF_YEAR]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_YEAR_NAME, 'Unspecified') [STATE_FISCAL_DAY_OF_YEAR_NAME]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_QUARTER, -99) [STATE_FISCAL_DAY_OF_QUARTER]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_QUARTER_NAME, 'Unspecified') [STATE_FISCAL_DAY_OF_QUARTER_NAME]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_MONTH, -99) [STATE_FISCAL_DAY_OF_MONTH]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_MONTH_NAME, 'Unspecified') [STATE_FISCAL_DAY_OF_MONTH_NAME]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_WEEK, -99) [STATE_FISCAL_DAY_OF_WEEK]
	,ISNULL(CD.STATE_FISCAL_DAY_OF_WEEK_NAME, 'Unspecified') [STATE_FISCAL_DAY_OF_WEEK_NAME]
	,ISNULL(CD.STATE_FISCAL_WEEK_OF_YEAR, -99) [STATE_FISCAL_WEEK_OF_YEAR]
	,ISNULL(CD.STATE_FISCAL_WEEK_OF_YEAR_NAME, 'Unspecified') [STATE_FISCAL_WEEK_OF_YEAR_NAME]
	,ISNULL(CD.STATE_FISCAL_MONTH_OF_YEAR, -99) [STATE_FISCAL_MONTH_OF_YEAR]
	,ISNULL(CD.STATE_FISCAL_MONTH_OF_YEAR_NAME, 'Unspecified') [STATE_FISCAL_MONTH_OF_YEAR_NAME]
	,ISNULL(CD.STATE_FISCAL_MONTH_OF_QUARTER, -99) [STATE_FISCAL_MONTH_OF_QUARTER]
	,ISNULL(CD.STATE_FISCAL_MONTH_OF_QUARTER_NAME, 'Unspecified') [STATE_FISCAL_MONTH_OF_QUARTER_NAME]
	,ISNULL(CD.STATE_FISCAL_QUARTER_OF_YEAR, -99) [STATE_FISCAL_QUARTER_OF_YEAR]
	,ISNULL(CD.STATE_FISCAL_QUARTER_OF_YEAR_NAME, 'Unspecified') [STATE_FISCAL_QUARTER_OF_YEAR_NAME]
	,ISNULL(CD.STATE_HOLIDAY_FLAG, 'N') [STATE_HOLIDAY_FLAG]
	,ISNULL(CD.WORKDAY_FLAG, 'N') [WORKDAY_FLAG]
	,ISNULL(CD.DST_FLAG, 'N') [DST_FLAG]
	,CD.MONTH_END_FLAG
	,ISNULL(CD.CALENDAR_DATE_YYYY_MM_DD, '01-01-1800') [CALENDAR_DATE_YYYY_MM_DD]
	,ISNULL(CD.CALENDAR_DATE_MM_DD_YYYY, '1800-01-01') [CALENDAR_DATE_MM_DD_YYYY]
FROM dbo.CALENDAR_DIM CD
INNER JOIN (
	SELECT
		MIN(id_calendar_dim_begin) [min_id_calendar_dim_begin]
		,MAX(id_calendar_dim_begin) [max_id_calendar_dim_begin]
		,MIN(IIF(id_calendar_dim_afcars_end = 0, NULL, id_calendar_dim_afcars_end)) [min_id_calendar_dim_afcars_end]
		,MAX(id_calendar_dim_afcars_end) [max_id_calendar_dim_afcars_end]
		,MIN(id_calendar_dim_afcars_end) [abs_min_id_calendar_dim_afcars_end]
	FROM base.rptPlacement
) RP ON
	(RP.min_id_calendar_dim_begin <= CD.ID_CALENDAR_DIM
		AND RP.max_id_calendar_dim_begin >= CD.ID_CALENDAR_DIM)
	OR (RP.min_id_calendar_dim_afcars_end <= CD.ID_CALENDAR_DIM
		AND RP.max_id_calendar_dim_afcars_end >= CD.ID_CALENDAR_DIM)
	OR RP.abs_min_id_calendar_dim_afcars_end = CD.ID_CALENDAR_DIM

UNION ALL

SELECT
	99991231 [ID_CALENDAR_DIM]
	,CONVERT(DATETIME, '12/31/9999') [CALENDAR_DATE]
	,9999 [YEAR_YYYY]
	,99 [MONTH_MM]
	,99 [DAY_DD]
	,'Still Open' [DATE_NAME]
	,9999 [YEAR]
	,'Still Open' [YEAR_NAME]
	,CONVERT(DATETIME, '12/31/9999') [YEAR_START_DATE]
	,99 [QUARTER]
	,'Still Open' [QUARTER_NAME]
	,CONVERT(DATETIME, '12/31/9999') [QUARTER_START_DATE]
	,99 [MONTH]
	,'Still Open' [MONTH_NAME]
	,CONVERT(DATETIME, '12/31/9999') [MONTH_START_DATE]
	,99 [WEEK]
	,'Still Open' [WEEK_NAME]
	,CONVERT(DATETIME, '12/31/9999') [WEEK_START_DATE]
	,999 [DAY_OF_YEAR]
	,'Still Open' [DAY_OF_YEAR_NAME]
	,999 [DAY_OF_QUARTER]
	,'Still Open' [DAY_OF_QUARTER_NAME]
	,99 [DAY_OF_MONTH]
	,'Still Open' [DAY_OF_MONTH_NAME]
	,99 [DAY_OF_WEEK]
	,'Still Open' [DAY_OF_WEEK_NAME]
	,99 [WEEK_OF_YEAR]
	,'Still Open' [WEEK_OF_YEAR_NAME]
	,99 [MONTH_OF_YEAR]
	,'Still Open' [MONTH_OF_YEAR_NAME]
	,99 [MONTH_OF_QUARTER]
	,'Still Open' [MONTH_OF_QUARTER_NAME]
	,99 [QUARTER_OF_YEAR]
	,'Still Open' [QUARTER_OF_YEAR_NAME]
	,9999 [FEDERAL_FISCAL_YEAR]
	,'Still Open' [FEDERAL_FISCAL_YEAR_NAME]
	,CONVERT(DATETIME, '12/31/9999') [FEDERAL_FISCAL_YEAR_START_DATE]
	,99 [FEDERAL_FISCAL_QUARTER]
	,'Still Open' [FEDERAL_FISCAL_QUARTER_NAME]
	,CONVERT(DATETIME, '12/31/9999') [FEDERAL_FISCAL_QUARTER_START_DATE]
	,99 [FEDERAL_FISCAL_MONTH]
	,'Still Open' [FEDERAL_FISCAL_MONTH_NAME]
	,CONVERT(DATETIME, '12/31/9999') [FEDERAL_FISCAL_MONTH_START_DATE]
	,99 [FEDERAL_FISCAL_WEEK]
	,'Still Open' [FEDERAL_FISCAL_WEEK_NAME]
	,CONVERT(DATETIME, '12/31/9999') [FEDERAL_FISCAL_WEEK_START_DATE]
	,999 [FEDERAL_FISCAL_DAY]
	,'Still Open' [FEDERAL_FISCAL_DAY_NAME]
	,CONVERT(DATETIME, '12/31/9999') [FEDERAL_FISCAL_DAY_DATE]
	,999 [FEDERAL_FISCAL_DAY_OF_YEAR]
	,'Still Open' [FEDERAL_FISCAL_DAY_OF_YEAR_NAME]
	,999 [FEDERAL_FISCAL_DAY_OF_QUARTER]
	,'Still Open' [FEDERAL_FISCAL_DAY_OF_QUARTER_NAME]
	,99 [FEDERAL_FISCAL_DAY_OF_MONTH]
	,'Still Open' [FEDERAL_FISCAL_DAY_OF_MONTH_NAME]
	,99 [FEDERAL_FISCAL_DAY_OF_WEEK]
	,'Still Open' [FEDERAL_FISCAL_DAY_OF_WEEK_NAME]
	,99 [FEDERAL_FISCAL_WEEK_OF_YEAR]
	,'Still Open' [FEDERAL_FISCAL_WEEK_OF_YEAR_NAME]
	,99 [FEDERAL_FISCAL_MONTH_OF_YEAR]
	,'Still Open' [FEDERAL_FISCAL_MONTH_OF_YEAR_NAME]
	,99 [FEDERAL_FISCAL_MONTH_OF_QUARTER]
	,'Still Open' [FEDERAL_FISCAL_MONTH_OF_QUARTER_NAME]
	,99 [FEDERAL_FISCAL_QUARTER_OF_YEAR]
	,'Still Open' [FEDERAL_FISCAL_QUARTER_OF_YEAR_NAME]
	,9999 [STATE_FISCAL_YEAR]
	,'Still Open' [STATE_FISCAL_YEAR_NAME]
	,CONVERT(DATETIME, '12/31/9999') [STATE_FISCAL_YEAR_START_DATE]
	,99 [STATE_FISCAL_QUARTER]
	,'Still Open' [STATE_FISCAL_QUARTER_NAME]
	,CONVERT(DATETIME, '12/31/9999') [STATE_FISCAL_QUARTER_START_DATE]
	,99 [STATE_FISCAL_MONTH]
	,'Still Open' [STATE_FISCAL_MONTH_NAME]
	,CONVERT(DATETIME, '12/31/9999') [STATE_FISCAL_MONTH_START_DATE]
	,99 [STATE_FISCAL_WEEK]
	,'Still Open' [STATE_FISCAL_WEEK_NAME]
	,CONVERT(DATETIME, '12/31/9999') [STATE_FISCAL_WEEK_START_DATE]
	,999 [STATE_FISCAL_DAY]
	,'Still Open' [STATE_FISCAL_DAY_NAME]
	,CONVERT(DATETIME, '12/31/9999') [STATE_FISCAL_DAY_DATE]
	,999 [STATE_FISCAL_DAY_OF_YEAR]
	,'Still Open' [STATE_FISCAL_DAY_OF_YEAR_NAME]
	,999 [STATE_FISCAL_DAY_OF_QUARTER]
	,'Still Open' [STATE_FISCAL_DAY_OF_QUARTER_NAME]
	,99 [STATE_FISCAL_DAY_OF_MONTH]
	,'Still Open' [STATE_FISCAL_DAY_OF_MONTH_NAME]
	,99 [STATE_FISCAL_DAY_OF_WEEK]
	,'Still Open' [STATE_FISCAL_DAY_OF_WEEK_NAME]
	,99 [STATE_FISCAL_WEEK_OF_YEAR]
	,'Still Open' [STATE_FISCAL_WEEK_OF_YEAR_NAME]
	,99 [STATE_FISCAL_MONTH_OF_YEAR]
	,'Still Open' [STATE_FISCAL_MONTH_OF_YEAR_NAME]
	,99 [STATE_FISCAL_MONTH_OF_QUARTER]
	,'Still Open' [STATE_FISCAL_MONTH_OF_QUARTER_NAME]
	,99 [STATE_FISCAL_QUARTER_OF_YEAR]
	,'Still Open' [STATE_FISCAL_QUARTER_OF_YEAR_NAME]
	,'N' [STATE_HOLIDAY_FLAG]
	,'N' [WORKDAY_FLAG]
	,'N' [DST_FLAG]
	,'N' [MONTH_END_FLAG]
	,'12-31-9999' [CALENDAR_DATE_YYYY_MM_DD]
	,'9999-31-12' [CALENDAR_DATE_MM_DD_YYYY]



