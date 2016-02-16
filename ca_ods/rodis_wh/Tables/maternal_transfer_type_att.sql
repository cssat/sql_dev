CREATE TABLE [rodis_wh].[maternal_transfer_type_att] (
    [id_maternal_transfer_type] INT          NOT NULL,
    [cd_maternal_transfer_type] VARCHAR (50) NOT NULL,
    [tx_maternal_transfer_type] VARCHAR (50) NULL,
    CONSTRAINT [pk_maternal_transfer_type_att] PRIMARY KEY CLUSTERED ([id_maternal_transfer_type] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_maternal_transfer_type_att_cd_maternal_transfer_type]
    ON [rodis_wh].[maternal_transfer_type_att]([cd_maternal_transfer_type] ASC);

