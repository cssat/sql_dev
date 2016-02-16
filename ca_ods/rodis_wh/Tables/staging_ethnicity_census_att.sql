CREATE TABLE [rodis_wh].[staging_ethnicity_census_att] (
    [id_ethnicity_census] INT          NULL,
    [cd_ethnicity_census] VARCHAR (50) NULL,
    [tx_ethnicity_census] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ethnicity_census_att_cd_ethnicity_census]
    ON [rodis_wh].[staging_ethnicity_census_att]([cd_ethnicity_census] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ethnicity_census_att_id_ethnicity_census]
    ON [rodis_wh].[staging_ethnicity_census_att]([id_ethnicity_census] ASC);

