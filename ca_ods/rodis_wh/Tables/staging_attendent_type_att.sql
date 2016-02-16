CREATE TABLE [rodis_wh].[staging_attendent_type_att] (
    [id_attendent_type] INT          NULL,
    [cd_attendent_type] VARCHAR (50) NULL,
    [tx_attendent_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_attendent_type_att_cd_attendent_type]
    ON [rodis_wh].[staging_attendent_type_att]([cd_attendent_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_attendent_type_att_id_attendent_type]
    ON [rodis_wh].[staging_attendent_type_att]([id_attendent_type] ASC);

