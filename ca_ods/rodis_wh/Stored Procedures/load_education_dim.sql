CREATE PROCEDURE [rodis_wh].[load_education_dim]
AS
TRUNCATE TABLE rodis_wh.education_dim

INSERT rodis_wh.education_dim (
	id_education
	,cd_education
	,tx_education
	)
SELECT id_education
	,cd_education
	,tx_education
FROM rodis_wh.education_att

UPDATE STATISTICS rodis_wh.education_dim
