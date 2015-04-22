CREATE TABLE [dbo].[ca_table_id] (
    [ca_tbl_id]   BIGINT        NOT NULL,
    [tbl_name]    VARCHAR (200) NULL,
    [last_update] DATETIME      NULL,
    CONSTRAINT [PK_ca_table_id] PRIMARY KEY CLUSTERED ([ca_tbl_id] ASC)
);

