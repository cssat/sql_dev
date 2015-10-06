CREATE PROCEDURE [ref].[import_numbers]
AS
TRUNCATE TABLE ref.numbers

INSERT ref.numbers(
	number
	,ia_safety_group
	)
SELECT
	n.number
	,ISNULL(ia.member, 0) [ia_safety_group]
FROM ca_ods.dbo.numbers n
LEFT JOIN (
	SELECT number * 3 [month_group]
		,1 [member]
	FROM ca_ods.dbo.numbers
	WHERE number BETWEEN 1 AND 16
	) ia ON ia.month_group = n.number
