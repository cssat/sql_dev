CREATE TABLE [dbo].[ref_filter_ihs_services] (
    [bin_ihs_svc_cd]   INT           NOT NULL,
    [bin_ihs_svc_tx]   VARCHAR (100) NULL,
    [min_display_date] DATETIME      NULL,
    CONSTRAINT [PK_ref_filter_ihs_services] PRIMARY KEY CLUSTERED ([bin_ihs_svc_cd] ASC)
);

