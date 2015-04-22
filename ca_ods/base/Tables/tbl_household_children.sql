CREATE TABLE [base].[tbl_household_children] (
    [id_household_children] INT      IDENTITY (1, 1) NOT NULL,
    [id_case]               INT      NOT NULL,
    [id_intake_fact]        INT      NOT NULL,
    [id_prsn_child]         INT      NOT NULL,
    [dt_birth]              DATETIME NULL,
    [age_at_referral_dt]    INT      NULL,
    CONSTRAINT [PK_tbl_household_children] PRIMARY KEY CLUSTERED ([id_household_children] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_household_children_id_intake_fact_dt_birth]
    ON [base].[tbl_household_children]([id_intake_fact] ASC)
    INCLUDE([dt_birth]);

