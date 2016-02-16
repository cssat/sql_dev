﻿CREATE TABLE [rodis].[death_rollup] (
    [id_birth]                       BIGINT       NOT NULL,
    [id_child]                       BIGINT       NOT NULL,
    [has_ca_and_birth_record]        VARCHAR (3)  NULL,
    [number_intakes]                 INT          NULL,
    [number_placements]              INT          NULL,
    [child_birth_date]               DATETIME     NULL,
    [first_intake_date]              DATETIME     NULL,
    [child_birth_sex]                VARCHAR (50) NULL,
    [child_birth_weight_grams]       INT          NULL,
    [any_congenital_abnormality]     VARCHAR (13) NULL,
    [paternity_established]          VARCHAR (11) NULL,
    [maternal_simple_race_ethnicity] VARCHAR (22) NULL,
    [maternal_age]                   INT          NULL,
    [maternal_simple_education]      VARCHAR (26) NULL,
    [maternal_residence]             VARCHAR (50) NULL,
    [birth_order]                    VARCHAR (24) NULL,
    [birth_payment_category]         VARCHAR (25) NULL,
    [id_death]                       INT          NULL,
    [dt_death_dtg]                   DATETIME     NULL,
    [id_city_of_residence_at_death]  INT          NULL,
    [EPH_all_injury]                 INT          NOT NULL,
    [EPH_intentional]                INT          NOT NULL,
    [EPH_undetermined]               INT          NOT NULL,
    [EPH_unintentional]              INT          NOT NULL
);

