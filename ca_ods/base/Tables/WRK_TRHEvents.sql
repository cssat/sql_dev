CREATE TABLE [base].[WRK_TRHEvents] (
    [ID_PRSN_CHILD]           INT         NOT NULL,
    [ID_REMOVAL_EPISODE_FACT] INT         NULL,
    [TRH_begin]               DATETIME    NULL,
    [TRH_End]                 DATETIME    NULL,
    [TRHtype]                 INT         NOT NULL,
    [TRHmark]                 INT         NOT NULL,
    [N_TRH]                   INT         NULL,
    [daysctrh_tot]            INT         NULL,
    [FL_RET_TO_CARE]          VARCHAR (1) NOT NULL,
    [FL_Last_Eps_OH_Plcmnt]   VARCHAR (1) NOT NULL,
    [Tbl_Refresh_Dt]          DATETIME    NULL
);

