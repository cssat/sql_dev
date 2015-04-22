CREATE TABLE [dbo].[ref_service_cd_subctgry_poc_old] (
    [cd_subctgry_poc_frc] INT           NOT NULL,
    [tx_subctgry_poc_frc] VARCHAR (100) NULL,
    [fl_name]             VARCHAR (200) NULL,
    [multiplier]          NUMERIC (38)  NULL,
    [power_10]            INT           NULL,
    [ordering]            SMALLINT      NULL,
    [fl_plc_svc]          INT           NULL,
    [fl_ihs_svc]          INT           NULL,
    CONSTRAINT [PK_ref_service_cd_subctgry_poc] PRIMARY KEY CLUSTERED ([cd_subctgry_poc_frc] ASC)
);

