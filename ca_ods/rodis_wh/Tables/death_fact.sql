﻿CREATE TABLE [rodis_wh].[death_fact] (
    [id_death_fact]                                                               INT          NOT NULL,
    [cd_death_fact]                                                               VARCHAR (50) NOT NULL,
    [id_prsn_child]                                                               INT          NULL,
    [id_county_file_number]                                                       VARCHAR (10) NULL,
    [id_calendar_dim_death]                                                       INT          NULL,
    [id_calendar_dim_injury]                                                      INT          NULL,
    [id_death]                                                                    INT          NOT NULL,
    [death_id_city_of_death]                                                      INT          NOT NULL,
    [death_id_city_of_injury]                                                     INT          NOT NULL,
    [death_id_city_of_residence_at_death]                                         INT          NOT NULL,
    [death_id_education]                                                          INT          NOT NULL,
    [death_id_birth_administration]                                               INT          NOT NULL,
    [death_birth_administration_id_birth_familial_child]                          INT          NOT NULL,
    [death_birth_administration_child_birth_familial_id_city_current]             INT          NOT NULL,
    [death_birth_administration_child_birth_familial_id_city_birth]               INT          NOT NULL,
    [death_birth_administration_child_birth_familial_id_education]                INT          NOT NULL,
    [death_birth_administration_id_birth_familial_maternal]                       INT          NOT NULL,
    [death_birth_administration_maternal_birth_familial_id_city_current]          INT          NOT NULL,
    [death_birth_administration_maternal_birth_familial_id_city_birth]            INT          NOT NULL,
    [death_birth_administration_maternal_birth_familial_id_education]             INT          NOT NULL,
    [death_birth_administration_id_birth_familial_paternal]                       INT          NOT NULL,
    [death_birth_administration_paternal_birth_familial_id_city_current]          INT          NOT NULL,
    [death_birth_administration_paternal_birth_familial_id_city_birth]            INT          NOT NULL,
    [death_birth_administration_paternal_birth_familial_id_education]             INT          NOT NULL,
    [death_birth_administration_id_hospital_admission_child]                      INT          NOT NULL,
    [death_birth_administration_child_hospital_admission_id_payment_primary]      INT          NOT NULL,
    [death_birth_administration_child_hospital_admission_id_payment_secondary]    INT          NOT NULL,
    [death_birth_administration_id_hospital_admission_maternal]                   INT          NOT NULL,
    [death_birth_administration_maternal_hospital_admission_id_payment_primary]   INT          NOT NULL,
    [death_birth_administration_maternal_hospital_admission_id_payment_secondary] INT          NOT NULL,
    [death_birth_administration_id_birth_child_condition]                         INT          NOT NULL,
    [death_birth_administration_id_birth_child_procedure]                         INT          NOT NULL,
    [death_birth_administration_id_maternal_behavior]                             INT          NOT NULL,
    [death_birth_administration_id_maternal_condition]                            INT          NOT NULL,
    [death_birth_administration_id_maternal_history]                              INT          NOT NULL,
    [death_birth_administration_id_maternal_procedure]                            INT          NOT NULL,
    [death_id_hospital_admission_last]                                            INT          NOT NULL,
    [death_last_hospital_admission_id_payment_primary]                            INT          NOT NULL,
    [death_last_hospital_admission_id_payment_secondary]                          INT          NOT NULL
);

