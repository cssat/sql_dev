CREATE TABLE [prtl].[prtl_tables_last_update] (
    [tbl_id]          INT          NOT NULL,
    [tbl_name]        VARCHAR (50) NULL,
    [last_build_date] DATETIME     NULL,
    [row_count]       BIGINT       NULL,
    [load_time_mins]  INT          NULL,
    PRIMARY KEY CLUSTERED ([tbl_id] ASC)
);

