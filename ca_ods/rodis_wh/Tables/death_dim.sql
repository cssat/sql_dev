CREATE TABLE [rodis_wh].[death_dim] (
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
    [cd_armed_forces]               VARCHAR (50) NOT NULL,
    [tx_armed_forces]               VARCHAR (50) NULL,
    [id_attendent_type]             INT          NOT NULL,
    [cd_attendent_type]             VARCHAR (50) NOT NULL,
    [tx_attendent_type]             VARCHAR (50) NULL,
    [id_place_of_death]             INT          NOT NULL,
    [cd_place_of_death]             VARCHAR (50) NOT NULL,
    [tx_place_of_death]             VARCHAR (50) NULL,
    [id_marital_status]             INT          NOT NULL,
    [cd_marital_status]             VARCHAR (50) NOT NULL,
    [tx_marital_status]             VARCHAR (50) NULL,
    [id_ucode]                      INT          NOT NULL,
    [cd_ucode]                      VARCHAR (50) NOT NULL,
    [tx_ucode]                      VARCHAR (50) NULL,
    [id_place_of_death_type]        INT          NOT NULL,
    [cd_place_of_death_type]        VARCHAR (50) NOT NULL,
    [tx_place_of_death_type]        VARCHAR (50) NULL,
    [id_city_of_death]              INT          NOT NULL,
    [id_city_of_injury]             INT          NOT NULL,
    [id_city_of_residence_at_death] INT          NOT NULL,
    [id_education]                  INT          NOT NULL,
    [id_birth_administration]       INT          NOT NULL,
    [id_hospital_admission_last]    INT          NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_death_dim]
    ON [rodis_wh].[death_dim]([id_death] ASC)
    INCLUDE([id_city_of_death], [id_city_of_injury], [id_city_of_residence_at_death], [id_education], [id_birth_administration], [id_hospital_admission_last]);

