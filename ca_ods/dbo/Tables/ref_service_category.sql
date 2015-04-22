CREATE TABLE [dbo].[ref_service_category] (
    [cd_srvc]                      INT           NOT NULL,
    [tx_srvc]                      VARCHAR (40)  NULL,
    [cd_subctgry]                  INT           NULL,
    [tx_subctgry]                  VARCHAR (200) NULL,
    [cd_budget_poc_frc]            INT           NULL,
    [tx_budget_poc_frc]            VARCHAR (100) NULL,
    [cd_subctgry_poc_frc]          INT           NULL,
    [tx_subctgry_poc_frc]          VARCHAR (100) NULL,
    [fl_plc_svc]                   INT           NOT NULL,
    [fl_prim_plc_svc]              INT           NOT NULL,
    [fl_prim_plc_svc_all]          INT           NOT NULL,
    [fl_ihs_svc]                   INT           CONSTRAINT [DF__ref_servi__fl_ih__050FA50E] DEFAULT ((0)) NULL,
    [fl_pcit]                      INT           NULL,
    [fl_home_based_svc]            INT           NULL,
    [fl_family_preservation_svc]   INT           NULL,
    [fl_functional_family_therapy] INT           NULL,
    [fl_alternate_response]        INT           NULL,
    [fl_ifps]                      INT           NULL,
    [fl_brs]                       INT           DEFAULT ((0)) NOT NULL,
    [last_update_dt]               DATETIME      NULL,
    CONSTRAINT [PK_ref_service_category] PRIMARY KEY CLUSTERED ([cd_srvc] ASC)
);

