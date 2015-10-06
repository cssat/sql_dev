CREATE TABLE [ref].[reporter_mandate_xwalk] (
	[cd_rptr_dscr] INT NOT NULL 
		CONSTRAINT [pk_reporter_mandate_xwalk] PRIMARY KEY
	,[tx_rptr_dscr] VARCHAR(50)
	,[tx_rptr_mandate] VARCHAR(50)
	)
