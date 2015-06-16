CREATE TABLE [prtl].[param_sets_placement]
(
	[plcm_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_plcm_param_key] PRIMARY KEY, 
    [bin_ihs_svc_cd] INT NOT NULL, 
    [init_cd_plcm_setng] INT NOT NULL, 
    [long_cd_plcm_setng] INT NOT NULL, 
    [bin_dependency_cd] INT NOT NULL, 
    [bin_los_cd] INT NOT NULL, 
    [bin_placement_cd] INT NOT NULL, 
    [cd_discharge_type] INT NOT NULL, 
    [kincare] INT NOT NULL, 
    [bin_sibling_group_size] INT NOT NULL, 
    CONSTRAINT [idx_param_sets_placement] UNIQUE NONCLUSTERED (
        [bin_ihs_svc_cd], 
        [init_cd_plcm_setng], 
        [long_cd_plcm_setng], 
        [bin_dependency_cd], 
        [bin_los_cd], 
        [bin_placement_cd], 
        [cd_discharge_type], 
        [kincare], 
        [bin_sibling_group_size]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
