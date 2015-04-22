CREATE TABLE [base].[tbl_ihs_services] (
    [id_ihs_episode]          INT             NOT NULL,
    [dtl_id_payment_fact]     INT             NOT NULL,
    [id_case]                 INT             NULL,
    [id_prsn]                 INT             NULL,
    [prsn_age]                INT             NULL,
    [srvc_dt_begin]           DATETIME        NOT NULL,
    [srvc_dt_end]             DATETIME        NULL,
    [cd_srvc]                 INT             NULL,
    [tx_srvc]                 VARCHAR (40)    NULL,
    [am_rate]                 FLOAT (53)      NULL,
    [am_units]                FLOAT (53)      NULL,
    [am_total_paid]           NUMERIC (18, 2) NULL,
    [id_service_type_dim]     INT             NULL,
    [id_provider_dim_service] INT             NULL,
    [cd_unit_rate_type]       INT             NULL,
    [tx_unit_rate_type]       VARCHAR (200)   NULL,
    [cd_srvc_ctgry]           INT             NULL,
    [tx_srvc_ctgry]           VARCHAR (200)   NULL,
    [cd_budget_poc_frc]       INT             NULL,
    [tx_budget_poc_frc]       VARCHAR (100)   NULL,
    [cd_subctgry_poc_frc]     INT             NULL,
    [tx_subctgry_poc_frc]     VARCHAR (100)   NULL,
    [dur_days]                INT             NULL,
    [ihs_rank]                INT             NOT NULL,
    [fl_no_pay]               INT             NULL,
    CONSTRAINT [PK__tbl_ihs___FC12E0DD9F0E6032] PRIMARY KEY CLUSTERED ([id_ihs_episode] ASC, [dtl_id_payment_fact] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_id_ihs_episode]
    ON [base].[tbl_ihs_services]([id_ihs_episode] ASC);

