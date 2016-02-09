CREATE VIEW [dbo].[vw_qa_prtl_access_type]
AS
SELECT 'prtl_poc1ab' [tbl]
	,tx_access_type
	,COUNT(*) row_count
FROM prtl.ooh_point_in_time_measures
JOIN ref_filter_access_type acc ON acc.filter_access_type = ooh_point_in_time_measures.filter_access_type
	AND ooh_point_in_time_measures.fl_poc1ab = 1
GROUP BY tx_access_type

UNION

SELECT 'prtl_poc1ab_entries' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_poc1ab_entries
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_poc1ab_entries.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_poc1ab_exits' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_poc1ab_exits
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_poc1ab_exits.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_poc2ab' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_poc2ab
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_poc2ab.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_poc3ab' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_poc3ab
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_poc3ab.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_outcomes' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_outcomes
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_outcomes.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_pbcp5' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_pbcp5
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_pbcp5.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_pbcs2' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_pbcs2
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_pbcs2.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_pbcs3' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.prtl_pbcs3
JOIN ref_filter_access_type acc ON acc.filter_access_type = prtl_pbcs3.filter_access_type
GROUP BY tx_access_type

UNION

SELECT 'prtl_pbcw3' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.ooh_point_in_time_measures
JOIN ref_filter_access_type acc ON acc.filter_access_type = ooh_point_in_time_measures.filter_access_type
	AND ooh_point_in_time_measures.fl_w3 = 1
GROUP BY tx_access_type

UNION

SELECT 'prtl_pbcw4' [tbl]
	,tx_access_type
	,COUNT(*)
FROM prtl.ooh_point_in_time_measures
JOIN ref_filter_access_type acc ON acc.filter_access_type = ooh_point_in_time_measures.filter_access_type
	AND ooh_point_in_time_measures.fl_w4 = 1
GROUP BY tx_access_type
