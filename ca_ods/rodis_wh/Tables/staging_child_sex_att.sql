CREATE TABLE [rodis_wh].[staging_child_sex_att] (
    [id_child_sex] INT          NULL,
    [cd_child_sex] VARCHAR (50) NULL,
    [tx_child_sex] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_child_sex_att_cd_child_sex]
    ON [rodis_wh].[staging_child_sex_att]([cd_child_sex] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_child_sex_att_id_child_sex]
    ON [rodis_wh].[staging_child_sex_att]([id_child_sex] ASC);

