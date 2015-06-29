CREATE VIEW [ref].[match_pk_gender]
AS
SELECT pk_gender
	,pk_gender [pk_gender_match_code]
FROM ref.lookup_gender
WHERE pk_gender != 0

UNION ALL

SELECT 0
	,pk_gender
FROM ref.lookup_gender
WHERE pk_gender != 0
