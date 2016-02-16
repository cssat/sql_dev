CREATE TABLE [rodis_wh].[staging_birth_familial_att] (
    [id_birth_familial]   INT          NULL,
    [cd_birth_familial]   VARCHAR (50) NULL,
    [cd_birth_zip]        INT          NULL,
    [id_race_census]      INT          NULL,
    [cd_race_census]      VARCHAR (50) NULL,
    [id_ethnicity_census] INT          NULL,
    [cd_ethnicity_census] VARCHAR (50) NULL,
    [id_tribe]            INT          NULL,
    [cd_tribe]            VARCHAR (50) NULL,
    [id_occupation]       INT          NULL,
    [cd_occupation]       VARCHAR (50) NULL,
    [id_city_current]     INT          NULL,
    [cd_city_current]     VARCHAR (50) NULL,
    [id_city_birth]       INT          NULL,
    [cd_city_birth]       VARCHAR (50) NULL,
    [id_education]        INT          NULL,
    [cd_education]        VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_education]
    ON [rodis_wh].[staging_birth_familial_att]([cd_education] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_city_birth]
    ON [rodis_wh].[staging_birth_familial_att]([cd_city_birth] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_city_current]
    ON [rodis_wh].[staging_birth_familial_att]([cd_city_current] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_occupation]
    ON [rodis_wh].[staging_birth_familial_att]([cd_occupation] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_tribe]
    ON [rodis_wh].[staging_birth_familial_att]([cd_tribe] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_ethnicity_census]
    ON [rodis_wh].[staging_birth_familial_att]([cd_ethnicity_census] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_race_census]
    ON [rodis_wh].[staging_birth_familial_att]([cd_race_census] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_cd_birth_familial]
    ON [rodis_wh].[staging_birth_familial_att]([cd_birth_familial] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_familial_att_id_birth_familial]
    ON [rodis_wh].[staging_birth_familial_att]([id_birth_familial] ASC);

