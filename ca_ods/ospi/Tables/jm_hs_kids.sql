CREATE TABLE [ospi].[jm_hs_kids] (
    [int_researchid]          INT        NULL,
    [firstResidentDistrictID] INT        NULL,
    [age_range]               INT        NULL,
    [female]                  INT        NOT NULL,
    [race]                    INT        NULL,
    [any_disability]          INT        NOT NULL,
    [cnt_nntxfr_hist]         INT        NOT NULL,
    [cnt_foster_hist]         INT        NOT NULL,
    [any_nn_txfr_hist]        INT        NOT NULL,
    [any_foster_hist]         INT        NOT NULL,
    [urban]                   FLOAT (53) NULL,
    [lunch_100tile]           BIGINT     NULL,
    [lunch_quintile]          BIGINT     NULL,
    [cnt_foster]              INT        NULL,
    [cnt_nntxfr]              INT        NULL,
    [any_foster]              INT        NULL,
    [any_nn_txfr]             INT        NULL,
    [grad_plus]               INT        NULL
);

