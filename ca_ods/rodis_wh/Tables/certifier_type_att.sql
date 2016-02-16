CREATE TABLE [rodis_wh].[certifier_type_att] (
    [id_certifier_type] INT          NOT NULL,
    [cd_certifier_type] VARCHAR (50) NOT NULL,
    [tx_certifier_type] VARCHAR (50) NULL,
    CONSTRAINT [pk_certifier_type_att] PRIMARY KEY CLUSTERED ([id_certifier_type] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_certifier_type_att_cd_certifier_type]
    ON [rodis_wh].[certifier_type_att]([cd_certifier_type] ASC);

