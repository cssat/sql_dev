CREATE TABLE [dbo].[ref_filter_finding] (
    [cd_finding]    INT           NOT NULL,
    [tx_finding]    VARCHAR (200) NULL,
    [cd_multiplier] NUMERIC (9)   NULL,
    [fl_name]       VARCHAR (100) NULL,
    [min_filter_date] DATETIME NULL, 
    CONSTRAINT [PK_ref_filter_finding] PRIMARY KEY CLUSTERED ([cd_finding] ASC)
);

