CREATE TABLE [rodis_wh].[staging_education_att] (
    [id_education] INT          NULL,
    [cd_education] VARCHAR (50) NULL,
    [tx_education] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_education_att_cd_education]
    ON [rodis_wh].[staging_education_att]([cd_education] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_education_att_id_education]
    ON [rodis_wh].[staging_education_att]([id_education] ASC);

