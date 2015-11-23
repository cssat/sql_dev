CREATE VIEW [ref].[match_bin_ihs_service_cd]
AS
SELECT bin_ihs_service_cd
	,bin_ihs_service_cd [bin_ihs_service_match_code]
FROM ref.filter_ihs_services flt
WHERE bin_ihs_service_cd != 0

UNION ALL

SELECT 0 [bin_ihs_service_cd]
	,bin_ihs_service_cd [bin_ihs_service_match_code]
FROM ref.filter_ihs_services
WHERE bin_ihs_service_cd != 0
