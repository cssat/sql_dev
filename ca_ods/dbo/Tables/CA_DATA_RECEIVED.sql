CREATE TABLE [dbo].[CA_DATA_RECEIVED] (
    [ca_tbl_id]     INT           NOT NULL,
    [tbl_name]      VARCHAR (200) NULL,
    [row_count]     INT           NULL,
    [date_received] DATETIME      NOT NULL,
    [ca_date_run]   DATETIME      NULL,
    CONSTRAINT [PK_CA_DATA_RECEIVED] PRIMARY KEY CLUSTERED ([ca_tbl_id] ASC, [date_received] ASC)
);

