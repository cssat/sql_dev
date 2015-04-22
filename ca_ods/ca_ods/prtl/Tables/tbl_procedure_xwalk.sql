CREATE TABLE [prtl].[tbl_procedure_xwalk] (
    [procedure_id] INT          NOT NULL,
    [tbl_id]       INT          NOT NULL,
    [tbl_name]     VARCHAR (50) NULL,
    [tbl_seq_nbr]  INT          NULL,
    CONSTRAINT [PK_tbl_procedure_xwalk] PRIMARY KEY CLUSTERED ([tbl_id] ASC),
    CONSTRAINT [FK_tbl_procedure_xwalk_ref_lookup_max_date] FOREIGN KEY ([procedure_id]) REFERENCES [dbo].[ref_lookup_max_date] ([id])
);

