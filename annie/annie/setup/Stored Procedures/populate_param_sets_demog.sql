CREATE PROCEDURE [setup].[populate_param_sets_demog]
AS
IF (
		SELECT count()
		FROM prtl.param_sets_demog
		) = 0
BEGIN
	INSERT prtl.param_sets_demog (
		age_grouping_cd
		,age_census_cd
		,age_dev_cd
		,age_sib_group_cd
		,cd_race_census
		,pk_gender
		)
	SELECT ag.age_grouping_cd
		,0 [age_census_cd]
		,0 [age_dev_cd]
		,0 [age_sib_group_cd]
		,ec.cd_race_census
		,g.pk_gender
	FROM ref.lookup_age_grouping ag
	CROSS JOIN ref.lookup_ethnicity_census ec
	CROSS JOIN ref.lookup_gender g
	
	UNION ALL
	
	SELECT 0 [age_grouping_cd]
		,ac.age_census_cd
		,0 [age_dev_cd]
		,0 [age_sib_group_cd]
		,ec.cd_race_census
		,g.pk_gender
	FROM ref.lookup_age_census ac
	CROSS JOIN ref.lookup_ethnicity_census ec
	CROSS JOIN ref.lookup_gender g
	WHERE ac.age_census_cd != 0
	
	UNION ALL
	
	SELECT 0 [age_grouping_cd]
		,0 [age_census_cd]
		,ad.age_dev_cd
		,0 [age_sib_group_cd]
		,ec.cd_race_census
		,g.pk_gender
	FROM ref.lookup_age_dev ad
	CROSS JOIN ref.lookup_ethnicity_census ec
	CROSS JOIN ref.lookup_gender g
	WHERE ad.age_dev_cd != 0
	
	UNION ALL
	
	SELECT 0 [age_grouping_cd]
		,0 [age_census_cd]
		,0 [age_dev_cd]
		,asg.age_sib_group_cd
		,ec.cd_race_census
		,g.pk_gender
	FROM ref.lookup_age_sib_group asg
	CROSS JOIN ref.lookup_ethnicity_census ec
	CROSS JOIN ref.lookup_gender g
	WHERE asg.age_sib_group_cd != 0
	ORDER BY 1
		,2
		,3
		,4
		,5
		,6

    UPDATE STATISTICS prtl.param_sets_demog
END