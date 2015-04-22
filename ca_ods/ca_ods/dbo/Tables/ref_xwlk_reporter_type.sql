CREATE TABLE [dbo].[ref_xwlk_reporter_type] (
    [cd_reporter_type]           INT           NOT NULL,
    [tx_reporter_type]           VARCHAR (200) NULL,
    [collapsed_cd_reporter_type] INT           NULL,
    [collapsed_tx_reporter_type] VARCHAR (200) NULL,
    CONSTRAINT [PK_ref_xwlk_reporter_type] PRIMARY KEY CLUSTERED ([cd_reporter_type] ASC)
);

