CREATE TABLE [rodis_wh].[csection_att] (
    [id_csection] INT          NOT NULL,
    [cd_csection] INT          NOT NULL,
    [tx_csection] VARCHAR (50) NULL,
    CONSTRAINT [pk_csection_att] PRIMARY KEY CLUSTERED ([id_csection] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_csection_att_cd_csection]
    ON [rodis_wh].[csection_att]([cd_csection] ASC);

