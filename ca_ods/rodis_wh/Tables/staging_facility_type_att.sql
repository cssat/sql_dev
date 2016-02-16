CREATE TABLE [rodis_wh].[staging_facility_type_att] (
    [id_facility_type] INT          NULL,
    [cd_facility_type] VARCHAR (50) NULL,
    [tx_facility_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_facility_type_att_cd_facility_type]
    ON [rodis_wh].[staging_facility_type_att]([cd_facility_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_facility_type_att_id_facility_type]
    ON [rodis_wh].[staging_facility_type_att]([id_facility_type] ASC);

