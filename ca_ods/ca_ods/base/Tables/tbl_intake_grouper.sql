CREATE TABLE [base].[tbl_intake_grouper] (
    [intake_grouper]   INT NOT NULL,
    [id_case]          INT NOT NULL,
    [id_intake_fact]   INT NOT NULL,
    [intk_grp_seq_nbr] INT NULL,
    PRIMARY KEY CLUSTERED ([id_intake_fact] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_intake_grouper]
    ON [base].[tbl_intake_grouper]([id_intake_fact] ASC)
    INCLUDE([intake_grouper], [id_case]);

