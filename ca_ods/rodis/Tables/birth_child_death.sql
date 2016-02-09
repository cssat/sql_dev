CREATE TABLE [rodis].[birth_child_death] (
	[id_birth] VARCHAR(50) NOT NULL
	,[id_child] INT NOT NULL
	,[id_death] VARCHAR(50) NOT NULL
	,[death_secondary_cause_order] TINYINT NOT NULL
	,[has_birth_record] VARCHAR(3) NOT NULL
	,[has_ca_record] VARCHAR(3) NOT NULL
	,[has_death_record] VARCHAR(3) NOT NULL
	,[has_birth_and_ca_records] VARCHAR(3) NOT NULL
	,[has_all_records] VARCHAR(3) NOT NULL
	,[child_birth_date_ca] DATETIME NULL
	,[child_birth_date_br] DATETIME NULL
	,[child_birth_date] DATETIME NULL
	,[child_fatal_injury_date] DATETIME NULL
	,[child_death_date] DATETIME NULL
	,[days_birth_to_fatal_injury] INT NULL
	,[days_birth_to_death] INT NULL
	,[any_intakes_after_birth_before_fatal_injury] VARCHAR(3) NULL
	,[any_intakes_after_birth_before_death] VARCHAR(3) NULL
	,[cd_residence_county] TINYINT NULL
	,[residence_county] VARCHAR(20) NULL
	,[cd_death_county] TINYINT NULL
	,[death_county] VARCHAR(20) NULL
	,[cause_of_death_icd_type] VARCHAR(6) NULL
	,[main_cause_of_death_icd] VARCHAR(50) NULL
	,[mcod_eph_all_injury_fl] INT NULL
	,[mcod_eph_intentional_fl] INT NULL
	,[mcod_eph_unintentional_fl] INT NULL
	,[mcod_eph_undetermined_fl] INT NULL
	,[other_cause_of_death_icd] VARCHAR(50) NULL
	,[ocod_eph_all_injury_fl] INT NULL
	,[ocod_eph_intentional_fl] INT NULL
	,[ocod_eph_unintentional_fl] INT NULL
	,[ocod_eph_undetermined_fl] INT NULL
	,[rollup_eph_all_injury_fl] INT NULL
	,[rollup_eph_intentional_fl] INT NULL
	,[rollup_eph_unintentional_fl] INT NULL
	,[rollup_eph_undetermined_fl] INT NULL
	)
