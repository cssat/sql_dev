CREATE TABLE [rodis_wh].[discharge_status_att] (
    [id_discharge_status] INT          NOT NULL,
    [cd_discharge_status] VARCHAR (50) NOT NULL,
    [tx_discharge_status] VARCHAR (50) NULL,
    CONSTRAINT [pk_discharge_status_att] PRIMARY KEY CLUSTERED ([id_discharge_status] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_discharge_status_att_cd_discharge_status]
    ON [rodis_wh].[discharge_status_att]([cd_discharge_status] ASC);

