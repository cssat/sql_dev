CREATE TABLE [dbo].[hire_pk_question_data_to_insert] (
    [qry_type]                         INT        NOT NULL,
    [date_type]                        INT        NOT NULL,
    [start_date]                       DATETIME   NOT NULL,
    [age_grouping_cd]                  INT        NULL,
    [cd_race]                          INT        NULL,
    [census_hispanic_latino_origin_cd] INT        NOT NULL,
    [county_cd]                        INT        NULL,
    [cnt_entries]                      FLOAT (53) NULL,
    [cnt_exits]                        FLOAT (53) NULL
);

