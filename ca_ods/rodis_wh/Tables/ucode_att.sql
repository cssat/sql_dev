CREATE TABLE [rodis_wh].[ucode_att] (
    [id_ucode] INT          NOT NULL,
    [cd_ucode] VARCHAR (50) NOT NULL,
    [tx_ucode] VARCHAR (50) NULL,
    CONSTRAINT [pk_ucode_att] PRIMARY KEY CLUSTERED ([id_ucode] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ucode_att_cd_ucode]
    ON [rodis_wh].[ucode_att]([cd_ucode] ASC);

