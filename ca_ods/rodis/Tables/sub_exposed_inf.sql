﻿CREATE TABLE [rodis].[sub_exposed_inf] (
	[id_birth] BIGINT NOT NULL
	,[id_child] INT NOT NULL
	,[number_records] INT NULL
	,[number_intakes] INT NULL
	,[number_placements] INT NULL
	,[child_CA_birth_date] DATETIME NULL
	,[child_birth_date] DATETIME NULL
	,[first_intake_date] DATETIME NULL
	,[first_intake_office] VARCHAR(200) NULL
	,[first_intake_record_source] VARCHAR(23) NULL
	,[first_intake_reporter_mandate] VARCHAR(50) NULL
	,[first_intake_screen_decision] VARCHAR(200) NULL
	,[first_intake_most_serious_allegation] VARCHAR(24) NULL
	,[first_intake_investigated] VARCHAR(20) NULL
	,[first_intake_findings] VARCHAR(31) NULL
	,[first_intake_services] VARCHAR(26) NULL
	,[first_placement_outcome] VARCHAR(25) NULL
	,[days_to_first_intake] INT NULL
	,[intake_in_first_year] VARCHAR(3) NULL
	,[intake_within_five_years_of_first] VARCHAR(3) NULL
	,[id_re_intake] INT NULL
	,[re_intake_date] DATETIME NULL
	,[re_intake_order] BIGINT NULL
	,[ever_investigated] VARCHAR(3) NULL
	,[ever_substantiated] VARCHAR(3) NULL
	,[ever_received_ihs] VARCHAR(3) NULL
	,[ever_received_ooh] VARCHAR(3) NULL
	,[ever_adopted] VARCHAR(3) NULL
	,[ever_emancipated] VARCHAR(3) NULL
	,[ever_guardianship] VARCHAR(3) NULL
	,[birth_record_link] VARCHAR(22) NULL
	,[child_birth_sex] VARCHAR(50) NULL
	,[child_birth_weight] INT NULL
	,[child_birth_weight_category] VARCHAR(7) NULL
	,[child_simple_race_ethnicity] VARCHAR(22) NULL
	,[prenatal_care_start_trimester] VARCHAR(25) NULL
	,[any_congenital_abnormality] VARCHAR(13) NULL
	,[paternity_established] VARCHAR(11) NULL
	,[maternal_simple_race_ethnicity] VARCHAR(22) NULL
	,[maternal_age] INT NULL
	,[maternal_age_category] VARCHAR(30) NULL
	,[maternal_simple_education] VARCHAR(26) NULL
	,[maternal_residence] VARCHAR(50) NULL
	,[birth_order] VARCHAR(24) NULL
	,[birth_payment_category] VARCHAR(25) NULL
	,[cd_birth_fact] VARCHAR(50) NULL
	,[id_birth_administration] INT NULL
	,[bf_id_birth_admin] INT NULL
	,[id_hospital_admission] INT NULL
	,[dmf_id_hosp_admission] INT NULL
	,[dmf_id_diagnosis] INT NULL
	,[id_diagnosis] INT NULL
	,[cd_diagnosis] VARCHAR(50) NULL
	)