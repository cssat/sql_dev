CREATE TABLE [rodis_wh].[payment_att] (
    [id_payment] INT          NOT NULL,
    [cd_payment] VARCHAR (50) NOT NULL,
    [tx_payment] VARCHAR (50) NULL,
    CONSTRAINT [pk_payment_att] PRIMARY KEY CLUSTERED ([id_payment] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_payment_att_cd_payment]
    ON [rodis_wh].[payment_att]([cd_payment] ASC);

