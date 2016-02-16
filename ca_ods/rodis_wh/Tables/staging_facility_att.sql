CREATE TABLE [rodis_wh].[staging_facility_att] (
    [id_facility] INT          NULL,
    [cd_facility] VARCHAR (50) NULL,
    [tx_facility] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_facility_att_cd_facility]
    ON [rodis_wh].[staging_facility_att]([cd_facility] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_facility_att_id_facility]
    ON [rodis_wh].[staging_facility_att]([id_facility] ASC);

