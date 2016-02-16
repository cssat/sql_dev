CREATE TABLE [rodis_wh].[birth_familial_dim] (
    [id_birth_familial]   INT          NOT NULL,
    [cd_birth_familial]   VARCHAR (50) NOT NULL,
    [cd_birth_zip]        INT          NULL,
    [id_race_census]      INT          NOT NULL,
    [cd_race_census]      VARCHAR (50) NOT NULL,
    [tx_race_census]      VARCHAR (50) NULL,
    [id_ethnicity_census] INT          NOT NULL,
    [cd_ethnicity_census] VARCHAR (50) NOT NULL,
    [tx_ethnicity_census] VARCHAR (50) NULL,
    [id_tribe]            INT          NOT NULL,
    [cd_tribe]            VARCHAR (50) NOT NULL,
    [tx_tribe]            VARCHAR (50) NULL,
    [id_occupation]       INT          NOT NULL,
    [cd_occupation]       VARCHAR (50) NOT NULL,
    [tx_occupation]       VARCHAR (50) NULL,
    [id_city_current]     INT          NOT NULL,
    [id_city_birth]       INT          NOT NULL,
    [id_education]        INT          NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_dim]
    ON [rodis_wh].[birth_familial_dim]([id_birth_familial] ASC)
    INCLUDE([id_city_current], [id_city_birth], [id_education]);

