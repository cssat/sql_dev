CREATE TABLE [dbo].[ref_filter_reporter_type] (
    [cd_reporter_type] INT           NOT NULL,
    [tx_reporter_type] VARCHAR (200) NULL,
    CONSTRAINT [PK_ref_filter_reporter_type] PRIMARY KEY CLUSTERED ([cd_reporter_type] ASC)
);

