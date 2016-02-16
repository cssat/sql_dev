CREATE TABLE [rodis_wh].[staging_ecode_att] (
    [id_ecode] INT          NULL,
    [cd_ecode] VARCHAR (50) NULL,
    [tx_ecode] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ecode_att_cd_ecode]
    ON [rodis_wh].[staging_ecode_att]([cd_ecode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ecode_att_id_ecode]
    ON [rodis_wh].[staging_ecode_att]([id_ecode] ASC);

