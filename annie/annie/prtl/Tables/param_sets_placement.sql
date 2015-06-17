CREATE TABLE [prtl].[param_sets_placement]
(
	[plcm_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_plcm_param_key] PRIMARY KEY, 
    [bin_ihs_service_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_bin_ihs_service_cd] FOREIGN KEY REFERENCES [ref].[filter_ihs_services]([bin_ihs_service_cd]), 
    [initial_cd_placement_setting] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_initial_cd_placement_setting] FOREIGN KEY REFERENCES [ref].[lookup_placement_setting]([cd_placement_setting]), 
    [longest_cd_placement_setting] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_longest_cd_placement_setting] FOREIGN KEY REFERENCES [ref].[lookup_placement_setting]([cd_placement_setting]), 
    [bin_dependency_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_bin_dependency_cd] FOREIGN KEY REFERENCES [ref].[filter_dependency]([bin_dependency_cd]), 
    [bin_los_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_bin_los_cd] FOREIGN KEY REFERENCES [ref].[filter_los]([bin_los_cd]), 
    [bin_placement_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_bin_placement_cd] FOREIGN KEY REFERENCES [ref].[filter_nbr_placement]([bin_placement_cd]), 
    [cd_discharge_type] INT NOT NULL 
        CONSTRAINT [fk_param_sets_placement_cd_discharge_type] FOREIGN KEY REFERENCES [ref].[filter_discharge_type]([cd_discharge_type]), 
    CONSTRAINT [idx_param_sets_placement] UNIQUE NONCLUSTERED (
        [bin_ihs_service_cd], 
        [initial_cd_placement_setting], 
        [longest_cd_placement_setting], 
        [bin_dependency_cd], 
        [bin_los_cd], 
        [bin_placement_cd], 
        [cd_discharge_type]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
