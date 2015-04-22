CREATE TABLE [dbo].[ref_lookup_office_collapse] (
    [cd_office] INT           NOT NULL,
    [tx_office] VARCHAR (200) NULL,
    CONSTRAINT [PK_ref_lookup_office_collapse] PRIMARY KEY CLUSTERED ([cd_office] ASC)
);

