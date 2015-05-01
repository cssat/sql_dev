CREATE TABLE [ospi].[jm_tbl_potentialgrads] (
    [int_researchid]              INT      NOT NULL,
    [districtid]                  INT      NOT NULL,
    [schoolcode]                  INT      NOT NULL,
    [dateenrolledinschool]        DATETIME NOT NULL,
    [start9]                      DATETIME NULL,
    [dateexitedfromschool]        DATETIME NOT NULL,
    [int_min_grade]               INT      NULL,
    [int_max_grade]               INT      NULL,
    [enrollmentstatus]            CHAR (2) NULL,
    [int_overall_startGradeLevel] INT      NULL,
    [int_overall_stopGradeLevel]  INT      NULL,
    [fl_famlinkFC]                INT      NULL,
    [fl_other_txfr]               SMALLINT NULL,
    [tot_ep_cnt]                  INT      NULL
);

