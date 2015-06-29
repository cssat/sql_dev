CREATE PROCEDURE [dbo].[populate_param_match_demog]
AS
INSERT prtl.param_match_demog (
	demog_param_key
	,age_grouping_cd
	,age_census_cd
	,age_dev_cd
	,age_sib_group_cd
	,cd_race_census
	,pk_gender
	)
SELECT d.demog_param_key
	,ag.age_grouping_match_code
	,ac.age_census_match_code
	,ad.age_dev_match_code
	,asg.age_sib_group_match_code
	,rc.race_census_match_code
	,g.pk_gender_match_code
FROM prtl.param_sets_demog d
INNER JOIN ref.match_age_grouping_cd ag ON ag.age_grouping_cd = d.age_grouping_cd
INNER JOIN ref.match_age_census_cd ac ON ac.age_census_cd = d.age_census_cd
INNER JOIN ref.match_age_dev_cd ad ON ad.age_dev_cd = d.age_dev_cd
INNER JOIN ref.match_age_sib_group_cd asg ON asg.age_sib_group_cd = d.age_sib_group_cd
INNER JOIN ref.match_cd_race_census rc ON rc.cd_race_census = d.cd_race_census
INNER JOIN ref.match_pk_gender g ON g.pk_gender = d.pk_gender
ORDER BY 1
	,2
	,3
	,4
	,5
	,6
	,7
