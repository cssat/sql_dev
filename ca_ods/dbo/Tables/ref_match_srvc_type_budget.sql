CREATE TABLE [dbo].[ref_match_srvc_type_budget] (
    [filter_service_budget] INT NOT NULL,
    [fl_budget_C12]         INT NULL,
    [fl_budget_C14]         INT NULL,
    [fl_budget_C15]         INT NULL,
    [fl_budget_C16]         INT NULL,
    [fl_budget_C18]         INT NULL,
    [fl_budget_C19]         INT NULL,
    [fl_uncat_svc]          INT NULL,
    [cd_budget_poc_frc]     INT NOT NULL,
    [id_service_budget]     INT NULL,
    PRIMARY KEY CLUSTERED ([filter_service_budget] ASC, [cd_budget_poc_frc] ASC)
);

