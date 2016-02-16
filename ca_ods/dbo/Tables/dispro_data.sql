CREATE TABLE [dbo].[dispro_data] (
    [ID_ACCESS_REPORT]        INT           NOT NULL,
    [id_child]                INT           NULL,
    [DT_ACCESS_RCVD]          DATETIME      NULL,
    [year]                    INT           NULL,
    [intake_region]           VARCHAR (200) NULL,
    [SINGLE_RACE]             VARCHAR (200) NULL,
    [CD_MULTI_RACE_ETHNICITY] INT           NULL,
    [TX_MULTI_RACE_ETHNICITY] VARCHAR (200) NULL,
    [TX_HSPNC]                VARCHAR (200) NULL,
    [screen_in]               INT           NOT NULL,
    [removal]                 INT           NULL,
    [removal_60day]           INT           NULL,
    [removal_2yr]             INT           NULL,
    [not_reun_within_1yr]     INT           NULL,
    [kin_not_1st_placement]   INT           NULL,
    [initial_instability]     INT           NULL,
    [ongoing_instability]     INT           NULL
);



