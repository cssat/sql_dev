CREATE TABLE [rodis_wh].[staging_payment_att] (
    [id_payment] INT          NULL,
    [cd_payment] VARCHAR (50) NULL,
    [tx_payment] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_payment_att_cd_payment]
    ON [rodis_wh].[staging_payment_att]([cd_payment] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_payment_att_id_payment]
    ON [rodis_wh].[staging_payment_att]([id_payment] ASC);

