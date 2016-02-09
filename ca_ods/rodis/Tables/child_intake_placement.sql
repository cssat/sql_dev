CREATE TABLE [rodis].[child_intake_placement] (
	[id_birth] BIGINT NOT NULL
	,[id_child] INT NOT NULL
	,[id_intake] INT NOT NULL
	,[id_placement] INT NOT NULL
	,[record_source] VARCHAR(23) NULL
	,[intake_date] DATETIME NULL
	,[intake_office] VARCHAR(200) NULL
	,[intake_reporter_type] VARCHAR(200) NULL
	,[intake_reporter_mandate] VARCHAR(50) NULL
	,[screen_decision] VARCHAR(200) NULL
	,[alleged_phys_abuse] VARCHAR(20) NOT NULL
	,[alleged_sex_abuse] VARCHAR(20) NOT NULL
	,[alleged_phys_or_sex_abuse] VARCHAR(20) NOT NULL
	,[alleged_neglect] VARCHAR(20) NOT NULL
	,[alleged_emotional_abuse] VARCHAR(20) NOT NULL
	,[any_allegation] VARCHAR(20) NOT NULL
	,[any_investigation] VARCHAR(20) NOT NULL
	,[overall_findings] VARCHAR(28) NOT NULL
	,[simple_findings] VARCHAR(31) NULL
	,[ihs_provided] VARCHAR(7) NULL
	,[ihs_start_date] DATETIME NULL
	,[ooh_provided] VARCHAR(3) NULL
	,[ooh_start_date] DATETIME NULL
	,[overall_services] VARCHAR(26) NULL
	,[simple_services] VARCHAR(26) NULL
	,[child_CA_birth_date] DATETIME NULL
	,[child_census_race] VARCHAR(200) NULL
	,[child_census_ethnicity] VARCHAR(13) NOT NULL
	,[child_simple_race_ethnicity] VARCHAR(22) NOT NULL
	,[placement_outcome] VARCHAR(25) NULL
	,[birth_record_link] VARCHAR(22) NULL
	,[child_birth_date] DATETIME NULL
	,[child_birth_weight] INT NULL
	,[child_birth_weight_category] VARCHAR(7) NULL
	,[child_birth_sex] VARCHAR(50) NULL
	,[any_congenital_abnormality] VARCHAR(13) NULL
	,[prenatal_care_start_month] SMALLINT NULL
	,[prenatal_care_start_trimester] VARCHAR(25) NULL
	,[birth_order] VARCHAR(24) NULL
	,[birth_payment_category] VARCHAR(25) NULL
	,[paternity_established] VARCHAR(11) NULL
	,[maternal_age] INT NULL
	,[maternal_age_category] VARCHAR(30) NULL
	,[maternal_census_race] VARCHAR(50) NULL
	,[maternal_census_ethnicity] VARCHAR(50) NULL
	,[maternal_simple_race_ethnicity] VARCHAR(22) NULL
	,[maternal_residence] VARCHAR(50) NULL
	,[maternal_raw_education] VARCHAR(255) NULL
	,[maternal_simple_education] VARCHAR(26) NULL
	,[mandatory_reporter_fl] INT NULL
	,[screen_in_fl] INT NULL
	,[alleged_phys_abuse_fl] INT NULL
	,[alleged_sex_abuse_fl] INT NULL
	,[alleged_neglect_fl] INT NULL
	,[any_allegation_fl] INT NULL
	,[any_investigation_fl] INT NULL
	,[any_substantiated_fl] INT NULL
	,[ihs_provided_fl] INT NULL
	,[ooh_provided_fl] INT NULL
	,[still_in_care_fl] INT NULL
	,[birth_record_link_fl] INT NOT NULL
	,CONSTRAINT [pk_child_intake_placement] PRIMARY KEY CLUSTERED (
		[id_birth] ASC
		,[id_child] ASC
		,[id_intake] ASC
		,[id_placement] ASC
		)
	)
