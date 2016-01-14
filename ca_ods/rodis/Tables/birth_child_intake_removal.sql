﻿CREATE TABLE [rodis].[birth_child_intake_removal] (
	[id_birth] [bigint] NOT NULL,
	[id_child] [bigint] NOT NULL,
	[id_intake] [bigint] NOT NULL,
	[id_removal] [bigint] NOT NULL,
	[has_ca_record] [varchar](3) NOT NULL,
	[ca_record_source] [varchar](21) NULL,
	[has_birth_record] [varchar](3) NOT NULL,
	[has_ca_and_birth_record] [varchar](3) NOT NULL,
	[child_birth_date_ca] [datetime] NULL,
	[child_birth_date_br] [datetime] NULL,
	[child_birth_date] [datetime] NULL,
	[intake_date] [datetime] NULL,
	[removal_date] [datetime] NULL,
	[intake_order] [bigint] NULL,
	[removal_order] [bigint] NULL,
	[intake_removal_order] [bigint] NULL,
	[cumulative_intakes] [int] NULL,
	[cumulative_removals] [int] NULL,
	[first_intake_date] [datetime] NULL,
	[first_removal_date] [datetime] NULL,
	[previous_intake_date] [datetime] NULL,
	[previous_removal_date] [datetime] NULL,
	[days_birth_to_first_intake] [int] NULL,
	[days_birth_to_first_removal] [int] NULL,
	[days_birth_to_intake] [int] NULL,
	[days_birth_to_removal] [int] NULL,
	[days_first_intake_to_intake] [int] NULL,
	[days_previous_intake_to_intake] [int] NULL,
	[days_intake_to_removal] [int] NULL,
	[days_previous_removal_to_removal] [int] NULL,
	[prenatal_care_start_month] [smallint] NULL,
	[prenatal_care_start_trimester] [varchar](25) NULL,
	[birth_payment_category] [varchar](25) NULL,
	[birth_order] [varchar](24) NULL,
	[child_birth_weight_grams] [int] NULL,
	[child_birth_weight_category] [varchar](7) NULL,
	[child_birth_sex] [varchar](50) NULL,
	[child_census_race] [varchar](200) NULL,
	[child_census_ethnicity] [varchar](13) NULL,
	[child_simple_race_ethnicity] [varchar](22) NULL,
	[any_congenital_abnormality] [varchar](13) NULL,
	[maternal_age] [int] NULL,
	[maternal_age_category] [varchar](30) NULL,
	[maternal_census_race] [varchar](50) NULL,
	[maternal_census_ethnicity] [varchar](50) NULL,
	[maternal_simple_race_ethnicity] [varchar](22) NULL,
	[maternal_residence] [varchar](50) NULL,
	[maternal_raw_education] [varchar](255) NULL,
	[maternal_simple_education] [varchar](26) NULL,
	[paternity_established] [varchar](11) NULL,
	[intake_office] [varchar](200) NULL,
	[intake_reporter_type] [varchar](200) NULL,
	[intake_reporter_mandate] [varchar](50) NULL,
	[screen_decision] [varchar](200) NULL,
	[alleged_phys_abuse] [varchar](20) NULL,
	[alleged_sex_abuse] [varchar](20) NULL,
	[alleged_phys_or_sex_abuse] [varchar](20) NULL,
	[alleged_neglect] [varchar](20) NULL,
	[alleged_emotional_abuse] [varchar](20) NULL,
	[any_allegation] [varchar](20) NULL,
	[any_investigation] [varchar](20) NULL,
	[overall_findings] [varchar](28) NULL,
	[simple_findings] [varchar](31) NULL,
	[ihs_provided] [varchar](7) NULL,
	[ihs_start_date] [datetime] NULL,
	[ooh_provided] [varchar](3) NULL,
	[ooh_start_date] [datetime] NULL,
	[overall_services] [varchar](26) NULL,
	[simple_services] [varchar](26) NULL,
	[removal_outcome] [varchar](25) NULL,
	[intake_before_birth_fl] [int] NULL,
	[mandatory_reporter_fl] [int] NULL,
	[screen_in_fl] [int] NULL,
	[alleged_phys_abuse_fl] [int] NULL,
	[alleged_sex_abuse_fl] [int] NULL,
	[alleged_neglect_fl] [int] NULL,
	[any_allegation_fl] [int] NULL,
	[any_investigation_fl] [int] NULL,
	[any_substantiated_fl] [int] NULL,
	[ihs_provided_fl] [int] NULL,
	[ooh_provided_fl] [int] NULL,
	[still_in_care_fl] [int] NULL,
	[has_ca_and_birth_record_fl] [int] NOT NULL,
	CONSTRAINT [pk_birth_child_intake_removal] PRIMARY KEY CLUSTERED (
		[id_birth] ASC,
		[id_child] ASC,
		[id_intake] ASC,
		[id_removal] ASC
		)
	)
