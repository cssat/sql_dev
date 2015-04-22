CREATE TABLE [dbo].[ref_service_cd_budget_poc_frc] (
    [cd_budget_poc_frc] INT           NOT NULL,
    [tx_budget_poc_frc] VARCHAR (100) NULL,
    [fl_name]           VARCHAR (200) NULL,
    [multiplier]        NUMERIC (38)  NULL,
    [power_10]          INT           NULL,
    [fl_plc_svc]        INT           NULL,
    [fl_ihs_svc]        INT           NULL,
    CONSTRAINT [PK_ref_service_cd_budget_poc_frc] PRIMARY KEY CLUSTERED ([cd_budget_poc_frc] ASC)
);

