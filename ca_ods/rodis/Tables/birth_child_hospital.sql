CREATE TABLE [rodis].[birth_child_hospital] (
	[id_birth] VARCHAR(50) NULL
	,[id_child] INT NULL
	,[id_hospitalization] VARCHAR(50) NULL
	,[id_hospital_admission] INT NULL
	,[admission_icd_order] VARCHAR(50) NULL
	,[has_birth_record] VARCHAR(3) NOT NULL
	,[has_ca_record] VARCHAR(3) NOT NULL
	,[has_hospital_record] VARCHAR(3) NOT NULL
	,[has_birth_and_ca_records] VARCHAR(3) NOT NULL
	,[has_all_records] VARCHAR(3) NOT NULL
	,[child_birth_date_ca] DATETIME NULL
	,[child_birth_date_br] DATETIME NULL
	,[child_birth_date] DATETIME NULL
	,[admission_date] DATETIME NULL
	,[discharge_date] DATETIME NULL
	,[admission_order] [bigint] NULL
	,[first_admission_date] DATETIME NULL
	,[previous_admission_date] DATETIME NULL
	,[days_birth_to_first_admission] INT NULL
	,[days_birth_to_admission] INT NULL
	,[days_first_admission_to_admission] INT NULL
	,[days_previous_admission_to_admission] INT NULL
	,[days_admission_to_discharge] INT NULL
	,[id_facility] INT NULL
	,[cd_facility] VARCHAR(50) NULL
	,[admission_point_of_entry] VARCHAR(50) NULL
	,[admission_reason] VARCHAR(50) NULL
	,[primary_payment_cd] VARCHAR(50) NULL
	,[primary_payment_category] VARCHAR(50) NULL
	,[secondary_payment_cd] VARCHAR(50) NULL
	,[secondary_payment_category] VARCHAR(50) NULL
	,[joint_payment_category] VARCHAR(28) NULL
	,[dollars_hospital_charges] FLOAT NULL
	,[admission_icd_type] VARCHAR(6) NULL
	,[admission_icd] VARCHAR(50) NULL
	,[icd_eph_all_injury_fl] INT NULL
	,[icd_eph_intentional_fl] INT NULL
	,[icd_eph_unintentional_fl] INT NULL
	,[icd_eph_undetermined_fl] INT NULL
	,[admission_eph_all_injury_fl] INT NULL
	,[admission_eph_intentional_fl] INT NULL
	,[admission_eph_unintentional_fl] INT NULL
	,[admission_eph_undetermined_fl] INT NULL
	,[ever_eph_all_injury_fl] INT NULL
	,[ever_eph_intentional_fl] INT NULL
	,[ever_eph_unintentional_fl] INT NULL
	,[ever_eph_undetermined_fl] INT NULL
	)
