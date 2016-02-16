CREATE TABLE [rodis_wh].[birth_familial_att] (
    [id_birth_familial]   INT          NOT NULL,
    [cd_birth_familial]   VARCHAR (50) NOT NULL,
    [cd_birth_zip]        INT          NULL,
    [id_race_census]      INT          NOT NULL,
    [id_ethnicity_census] INT          NOT NULL,
    [id_tribe]            INT          NOT NULL,
    [id_occupation]       INT          NOT NULL,
    [id_city_current]     INT          NOT NULL,
    [id_city_birth]       INT          NOT NULL,
    [id_education]        INT          NOT NULL,
    CONSTRAINT [pk_birth_familial_att] PRIMARY KEY CLUSTERED ([id_birth_familial] ASC),
    CONSTRAINT [fk_birth_familial_att_id_city_birth] FOREIGN KEY ([id_city_birth]) REFERENCES [rodis_wh].[city_att] ([id_city]),
    CONSTRAINT [fk_birth_familial_att_id_city_current] FOREIGN KEY ([id_city_current]) REFERENCES [rodis_wh].[city_att] ([id_city]),
    CONSTRAINT [fk_birth_familial_att_id_education] FOREIGN KEY ([id_education]) REFERENCES [rodis_wh].[education_att] ([id_education]),
    CONSTRAINT [fk_birth_familial_att_id_ethnicity_census] FOREIGN KEY ([id_ethnicity_census]) REFERENCES [rodis_wh].[ethnicity_census_att] ([id_ethnicity_census]),
    CONSTRAINT [fk_birth_familial_att_id_occupation] FOREIGN KEY ([id_occupation]) REFERENCES [rodis_wh].[occupation_att] ([id_occupation]),
    CONSTRAINT [fk_birth_familial_att_id_race_census] FOREIGN KEY ([id_race_census]) REFERENCES [rodis_wh].[race_census_att] ([id_race_census]),
    CONSTRAINT [fk_birth_familial_att_id_tribe] FOREIGN KEY ([id_tribe]) REFERENCES [rodis_wh].[tribe_att] ([id_tribe])
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_education]
    ON [rodis_wh].[birth_familial_att]([id_education] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_city_birth]
    ON [rodis_wh].[birth_familial_att]([id_city_birth] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_city_current]
    ON [rodis_wh].[birth_familial_att]([id_city_current] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_occupation]
    ON [rodis_wh].[birth_familial_att]([id_occupation] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_tribe]
    ON [rodis_wh].[birth_familial_att]([id_tribe] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_ethnicity_census]
    ON [rodis_wh].[birth_familial_att]([id_ethnicity_census] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_familial_att_id_race_census]
    ON [rodis_wh].[birth_familial_att]([id_race_census] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_birth_familial_att_cd_birth_familial]
    ON [rodis_wh].[birth_familial_att]([cd_birth_familial] ASC);

