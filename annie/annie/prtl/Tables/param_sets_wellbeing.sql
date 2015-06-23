CREATE TABLE [prtl].[param_sets_wellbeing]
(
    [wb_param_key] INT NOT NULL IDENTITY(1,1)
        CONSTRAINT [pk_param_sets_wellbeing] PRIMARY KEY, 
    [kincare] INT NOT NULL 
        CONSTRAINT [fk_param_sets_wellbeing_kincare] FOREIGN KEY REFERENCES [ref].[filter_kincare]([kincare]), 
    [bin_sibling_group_size] INT NOT NULL 
        CONSTRAINT [fk_param_sets_wellbeing_bin_sib_group_size] FOREIGN KEY REFERENCES [ref].[lookup_sibling_groups]([bin_sibling_group_size]), 
    CONSTRAINT [idx_param_sets_wellbeing] UNIQUE NONCLUSTERED (
        [kincare], 
        [bin_sibling_group_size] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
