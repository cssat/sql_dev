CREATE TABLE [rodis_wh].[country_att] (
    [id_country] INT          NOT NULL,
    [cd_country] VARCHAR (50) NOT NULL,
    [tx_country] VARCHAR (50) NULL,
    CONSTRAINT [pk_country_att] PRIMARY KEY CLUSTERED ([id_country] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_country_att_cd_country]
    ON [rodis_wh].[country_att]([cd_country] ASC);

