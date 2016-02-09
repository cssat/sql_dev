CREATE TABLE [oliver].[rpt_first_visits] (
	[id_visitation_referral_fact] VARCHAR(50) NULL
	,[dt_rcvd] DATETIME NULL
	,[id_calendar_dim_rcvd] VARCHAR(50) NULL
	,[dt_first_visit] DATETIME NULL
	,[id_calendar_dim_first_visit] VARCHAR(50) NULL
	,[cd_region] VARCHAR(50) NULL
	,[nm_organization] VARCHAR(50) NULL
	,[tm_days_to_first] INT NULL
	,[fl_first_visit] INT NOT NULL
	)
