CREATE TABLE [base].[placement_payment_services] (
    [id_prsn_child]                          INT             NOT NULL,
    [begin_date]                             DATETIME        NOT NULL,
    [end_date]                               DATETIME        NOT NULL,
    [id_removal_episode_fact]                INT             NOT NULL,
    [id_placement_fact]                      INT             NOT NULL,
    [id_provider_dim_caregiver]              INT             NULL,
    [id_case]                                INT             NOT NULL,
    [dur_days]                               INT             NULL,
    [fl_close]                               INT             NULL,
    [id_payment_fact]                        INT             NOT NULL,
    [svc_begin_date]                         DATETIME        NOT NULL,
    [svc_end_date]                           DATETIME        NULL,
    [pymt_cd_srvc]                           INT             NOT NULL,
    [pymt_tx_srvc]                           VARCHAR (200)   NULL,
    [fl_primary_srvc]                        INT             NOT NULL,
    [srvc_match]                             INT             NOT NULL,
    [prov_match]                             INT             NOT NULL,
    [rate]                                   NUMERIC (9, 4)  NULL,
    [unit]                                   NUMERIC (9, 2)  NULL,
    [total_paid]                             NUMERIC (18, 2) NULL,
    [cd_budget_poc_frc]                      INT             NULL,
    [tx_budget_poc_frc]                      VARCHAR (200)   NULL,
    [cd_subctgry_poc_frc]                    INT             NULL,
    [tx_subctgry_poc_frc]                    VARCHAR (200)   NULL,
    [fl_plc_svc]                             INT             NULL,
    [fl_dup_payment]                         INT             NULL,
    [plcm_pymnt_sort_asc]                    INT             NULL,
    [filter_service_category_todate]         DECIMAL (21)    NULL,
    [filter_service_budget_todate]           DECIMAL (9)     NULL,
    [fl_family_focused_services]             INT             NULL,
    [fl_child_care]                          INT             NULL,
    [fl_therapeutic_services]                INT             NULL,
    [fl_mh_services]                         INT             NULL,
    [fl_receiving_care]                      INT             NULL,
    [fl_family_home_placements]              INT             NULL,
    [fl_behavioral_rehabiliation_services]   INT             NULL,
    [fl_other_therapeutic_living_situations] INT             NULL,
    [fl_specialty_adolescent_services]       INT             NULL,
    [fl_respite]                             INT             NULL,
    [fl_transportation]                      INT             NULL,
    [fl_clothing_incidentals]                INT             NULL,
    [fl_sexually_aggressive_youth]           INT             NULL,
    [fl_adoption_support]                    INT             NULL,
    [fl_various]                             INT             NULL,
    [fl_medical]                             INT             NULL,
    [fl_ihs_reun]                            INT             NULL,
    [fl_concrete_goods]                      INT             NULL,
    [fl_budget_C12]                          INT             NULL,
    [fl_budget_C14]                          INT             NULL,
    [fl_budget_C15]                          INT             NULL,
    [fl_budget_C16]                          INT             NULL,
    [fl_budget_C18]                          INT             NULL,
    [fl_budget_C19]                          INT             NULL,
    [fl_uncat_svc]                           INT             NULL,
    CONSTRAINT [PK_placement_payment_services] PRIMARY KEY CLUSTERED ([id_payment_fact] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_filter_service_category_to_date]
    ON [base].[placement_payment_services]([filter_service_category_todate] ASC)
    INCLUDE([id_prsn_child], [begin_date], [end_date], [id_removal_episode_fact], [id_placement_fact], [fl_budget_C16], [fl_budget_C18], [fl_budget_C19], [fl_uncat_svc], [fl_adoption_support], [fl_various], [fl_medical], [fl_budget_C12], [fl_budget_C14], [fl_budget_C15], [fl_other_therapeutic_living_situations], [fl_specialty_adolescent_services], [fl_respite], [fl_transportation], [fl_clothing_incidentals], [fl_sexually_aggressive_youth], [fl_child_care], [fl_therapeutic_services], [fl_mh_services], [fl_receiving_care], [fl_family_home_placements], [fl_behavioral_rehabiliation_services], [tx_subctgry_poc_frc], [fl_plc_svc], [fl_dup_payment], [plcm_pymnt_sort_asc], [filter_service_budget_todate], [fl_family_focused_services], [rate], [unit], [total_paid], [cd_budget_poc_frc], [tx_budget_poc_frc], [cd_subctgry_poc_frc], [svc_end_date], [pymt_cd_srvc], [pymt_tx_srvc], [fl_primary_srvc], [srvc_match], [prov_match], [id_provider_dim_caregiver], [id_case], [dur_days], [fl_close], [id_payment_fact], [svc_begin_date]);


GO
CREATE NONCLUSTERED INDEX [idx_pps_id_placement_fact]
    ON [base].[placement_payment_services]([pymt_cd_srvc] ASC)
    INCLUDE([id_placement_fact]);


GO
CREATE NONCLUSTERED INDEX [idx_id_placement_fact]
    ON [base].[placement_payment_services]([id_placement_fact] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_id_prsn_child]
    ON [base].[placement_payment_services]([id_prsn_child] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_id_removal_episode_fact]
    ON [base].[placement_payment_services]([id_removal_episode_fact] ASC);

