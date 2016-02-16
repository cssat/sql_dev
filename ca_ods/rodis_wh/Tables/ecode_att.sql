CREATE TABLE [rodis_wh].[ecode_att] (
    [id_ecode] INT          NOT NULL,
    [cd_ecode] VARCHAR (50) NOT NULL,
    [tx_ecode] VARCHAR (50) NULL,
    CONSTRAINT [pk_ecode_att] PRIMARY KEY CLUSTERED ([id_ecode] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ecode_att_cd_ecode]
    ON [rodis_wh].[ecode_att]([cd_ecode] ASC);

