CREATE TABLE [prtl].[param_sets_placement]
(
	[plcm_param_key] INT NOT NULL PRIMARY KEY, 
    [bin_ihs_svc_cd] INT NOT NULL, 
    [init_cd_long_plcm_setng] INT NOT NULL, 
    [long_cd_plcm_setng] INT NOT NULL, 
    [bin_dependency_cd] INT NOT NULL, 
    [bin_los_cd] INT NOT NULL, 
    [bin_placement_cd] INT NOT NULL, 
    [cd_discharge_type] INT NOT NULL, 
    [kincare] INT NOT NULL, 
    [bin_sibling_group_size] INT NOT NULL, 
)
