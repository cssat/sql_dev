CREATE TABLE [rodis_wh].[staging_discharge_status_att] (
    [id_discharge_status] INT          NULL,
    [cd_discharge_status] VARCHAR (50) NULL,
    [tx_discharge_status] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_discharge_status_att_cd_discharge_status]
    ON [rodis_wh].[staging_discharge_status_att]([cd_discharge_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_discharge_status_att_id_discharge_status]
    ON [rodis_wh].[staging_discharge_status_att]([id_discharge_status] ASC);

