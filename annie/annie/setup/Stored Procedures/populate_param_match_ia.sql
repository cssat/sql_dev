CREATE PROCEDURE [setup].[populate_param_match_ia]
AS
INSERT prtl.param_match_ia (
	ia_param_key
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	)
SELECT ia.ia_param_key
	,r.reporter_type_match_code
	,at.filter_access_type
	,a.filter_allegation
	,f.filter_finding
FROM prtl.param_sets_ia ia
INNER JOIN ref.match_cd_reporter_type r ON r.cd_reporter_type = ia.cd_reporter_type
INNER JOIN ref.match_cd_access_type at ON at.cd_access_type = ia.cd_access_type
INNER JOIN ref.match_allegation a ON a.cd_allegation = ia.cd_allegation
INNER JOIN ref.match_finding f ON f.cd_finding = ia.cd_finding