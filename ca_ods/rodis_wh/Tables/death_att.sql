CREATE TABLE [rodis_wh].[death_att] (
    [id_death]                      INT          NOT NULL,
    [cd_death]                      VARCHAR (50) NOT NULL,
    [fl_autopsy]                    TINYINT      NULL,
    [fl_citizen]                    TINYINT      NULL,
    [fl_city_limits_death]          VARCHAR (1)  NULL,
    [fl_coroner_referred]           TINYINT      NULL,
    [fl_smoked]                     TINYINT      NULL,
    [dt_death_dtg]                  DATETIME     NULL,
    [dt_injury_dtg]                 DATETIME     NULL,
    [id_armed_forces]               INT          NOT NULL,
    [id_attendent_type]             INT          NOT NULL,
    [id_place_of_death]             INT          NOT NULL,
    [id_marital_status]             INT          NOT NULL,
    [id_ucode]                      INT          NOT NULL,
    [id_city_of_death]              INT          NOT NULL,
    [id_city_of_injury]             INT          NOT NULL,
    [id_city_of_residence_at_death] INT          NOT NULL,
    [id_education]                  INT          NOT NULL,
    [id_birth_administration]       INT          NOT NULL,
    [id_hospital_admission_last]    INT          NOT NULL,
    CONSTRAINT [pk_death_att] PRIMARY KEY CLUSTERED ([id_death] ASC),
    CONSTRAINT [fk_death_att_id_armed_forces] FOREIGN KEY ([id_armed_forces]) REFERENCES [rodis_wh].[armed_forces_att] ([id_armed_forces]),
    CONSTRAINT [fk_death_att_id_attendent_type] FOREIGN KEY ([id_attendent_type]) REFERENCES [rodis_wh].[attendent_type_att] ([id_attendent_type]),
    CONSTRAINT [fk_death_att_id_birth_administration] FOREIGN KEY ([id_birth_administration]) REFERENCES [rodis_wh].[birth_administration_att] ([id_birth_administration]),
    CONSTRAINT [fk_death_att_id_city_of_death] FOREIGN KEY ([id_city_of_death]) REFERENCES [rodis_wh].[city_att] ([id_city]),
    CONSTRAINT [fk_death_att_id_city_of_injury] FOREIGN KEY ([id_city_of_injury]) REFERENCES [rodis_wh].[city_att] ([id_city]),
    CONSTRAINT [fk_death_att_id_city_of_residence_at_death] FOREIGN KEY ([id_city_of_residence_at_death]) REFERENCES [rodis_wh].[city_att] ([id_city]),
    CONSTRAINT [fk_death_att_id_education] FOREIGN KEY ([id_education]) REFERENCES [rodis_wh].[education_att] ([id_education]),
    CONSTRAINT [fk_death_att_id_hospital_admission_last] FOREIGN KEY ([id_hospital_admission_last]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission]),
    CONSTRAINT [fk_death_att_id_marital_status] FOREIGN KEY ([id_marital_status]) REFERENCES [rodis_wh].[marital_status_att] ([id_marital_status]),
    CONSTRAINT [fk_death_att_id_place_of_death] FOREIGN KEY ([id_place_of_death]) REFERENCES [rodis_wh].[place_of_death_att] ([id_place_of_death]),
    CONSTRAINT [fk_death_att_id_ucode] FOREIGN KEY ([id_ucode]) REFERENCES [rodis_wh].[ucode_att] ([id_ucode])
);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_hospital_admission_last]
    ON [rodis_wh].[death_att]([id_hospital_admission_last] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_birth_administration]
    ON [rodis_wh].[death_att]([id_birth_administration] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_education]
    ON [rodis_wh].[death_att]([id_education] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_city_of_residence_at_death]
    ON [rodis_wh].[death_att]([id_city_of_residence_at_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_city_of_injury]
    ON [rodis_wh].[death_att]([id_city_of_injury] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_city_of_death]
    ON [rodis_wh].[death_att]([id_city_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_ucode]
    ON [rodis_wh].[death_att]([id_ucode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_marital_status]
    ON [rodis_wh].[death_att]([id_marital_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_place_of_death]
    ON [rodis_wh].[death_att]([id_place_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_attendent_type]
    ON [rodis_wh].[death_att]([id_attendent_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_death_att_id_armed_forces]
    ON [rodis_wh].[death_att]([id_armed_forces] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_death_att_cd_death]
    ON [rodis_wh].[death_att]([cd_death] ASC);

