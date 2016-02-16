CREATE TABLE [rodis_wh].[marital_status_att] (
    [id_marital_status] INT          NOT NULL,
    [cd_marital_status] VARCHAR (50) NOT NULL,
    [tx_marital_status] VARCHAR (50) NULL,
    CONSTRAINT [pk_marital_status_att] PRIMARY KEY CLUSTERED ([id_marital_status] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_marital_status_att_cd_marital_status]
    ON [rodis_wh].[marital_status_att]([cd_marital_status] ASC);

