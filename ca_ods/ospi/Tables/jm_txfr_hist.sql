CREATE TABLE [ospi].[jm_txfr_hist] (
    [int_researchID]   INT        NOT NULL,
    [districtid]       INT        NULL,
    [age_begin]        INT        NULL,
    [female]           INT        NOT NULL,
    [race]             INT        NULL,
    [any_disability]   INT        NOT NULL,
    [urban]            FLOAT (53) NULL,
    [lunch_100tile]    BIGINT     NULL,
    [lunch_quintile]   BIGINT     NULL,
    [foster]           INT        NULL,
    [total_enrollment] INT        NULL,
    [nn_txfr]          SMALLINT   NULL
);

