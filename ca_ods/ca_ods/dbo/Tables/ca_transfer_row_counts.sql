CREATE TABLE [dbo].[ca_transfer_row_counts] (
    [ca_tbl_id]    INT           NOT NULL,
    [tbl_name]     CHAR (200)    NULL,
    [row_count]    INT           NULL,
    [insert_date]  DATETIME      NOT NULL,
    [success]      BIT           NOT NULL,
    [error_reason] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ca_transfer_row_counts_1] PRIMARY KEY CLUSTERED ([ca_tbl_id] ASC, [insert_date] ASC)
);

