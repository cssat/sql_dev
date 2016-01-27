CREATE TABLE [rodis].[xwalk_icd_10_to_eph] (
	[icd_10_head] [varchar](25) NOT NULL
	,[eph_all_injury_fl] [int] NULL
	,[eph_intentional_injury_fl] [int] NOT NULL
	,[eph_unintentional_injury_fl] [int] NOT NULL
	,[eph_undetermined_injury_fl] [int] NOT NULL
	)
