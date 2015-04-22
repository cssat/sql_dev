CREATE TABLE [dbo].[ref_filter_allegation] (
    [cd_allegation] INT           NOT NULL,
    [tx_allegation] VARCHAR (200) NULL,
    [cd_multiplier] NUMERIC (9)   NULL,
    [fl_name]       VARCHAR (100) NULL,
    CONSTRAINT [PK_ref_filter_allegation] PRIMARY KEY CLUSTERED ([cd_allegation] ASC)
);

