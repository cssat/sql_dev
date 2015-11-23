CREATE VIEW [ref].[match_kincare]
AS 
SELECT kincare
	,kincare [kincare_match_code]
FROM ref.filter_kincare

UNION ALL

SELECT 0 [kincare]
	,kincare [kincare_match_code]
FROM ref.filter_kincare
WHERE kincare != 0
