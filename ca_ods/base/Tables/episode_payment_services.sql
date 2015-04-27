﻿CREATE TABLE [base].[episode_payment_services] (
    [id_prsn_child]                              INT             NOT NULL,
    [id_removal_episode_fact]                    INT             NOT NULL,
    [id_case]                                    INT             NOT NULL,
    [min_id_payment_fact]                        INT             NULL,
    [max_id_payment_fact]                        INT             NULL,
    [min_svc_begin_date]                         DATE            NULL,
    [max_svc_end_date]                           DATE            NULL,
    [nbr_services]                               INT             NULL,
    [fl_family_focused_services]                 INT             NULL,
    [fl_child_care]                              INT             NULL,
    [fl_therapeutic_services]                    INT             NULL,
    [fl_mh_services]                             INT             NULL,
    [fl_receiving_care]                          INT             NULL,
    [fl_family_home_placements]                  INT             NULL,
    [fl_behavioral_rehabiliation_services]       INT             NULL,
    [fl_other_therapeutic_living_situations]     INT             NULL,
    [fl_specialty_adolescent_services]           INT             NULL,
    [fl_respite]                                 INT             NULL,
    [fl_transportation]                          INT             NULL,
    [fl_clothing_incidentals]                    INT             NULL,
    [fl_sexually_aggressive_youth]               INT             NULL,
    [fl_adoption_support]                        INT             NULL,
    [fl_various]                                 INT             NULL,
    [fl_medical]                                 INT             NULL,
    [fl_ihs_reun]                                INT             NULL,
    [fl_concrete_goods]                          INT             NULL,
    [fl_budget_C12]                              INT             NULL,
    [fl_budget_C14]                              INT             NULL,
    [fl_budget_C15]                              INT             NULL,
    [fl_budget_C16]                              INT             NULL,
    [fl_budget_C18]                              INT             NULL,
    [fl_budget_C19]                              INT             NULL,
    [fl_uncat_svc]                               INT             NULL,
    [cnt_family_focused_services]                INT             NULL,
    [cnt_child_care]                             INT             NULL,
    [cnt_therapeutic_services]                   INT             NULL,
    [cnt_mh_services]                            INT             NULL,
    [cnt_receiving_care]                         INT             NULL,
    [cnt_family_home_placements]                 INT             NULL,
    [cnt_behavioral_rehabiliation_services]      INT             NULL,
    [cnt_other_therapeutic_living_situations]    INT             NULL,
    [cnt_specialty_adolescent_services]          INT             NULL,
    [cnt_respite]                                INT             NULL,
    [cnt_transportation]                         INT             NULL,
    [cnt_clothing_incidentals]                   INT             NULL,
    [cnt_sexually_aggressive_youth]              INT             NULL,
    [cnt_adoption_support]                       INT             NULL,
    [cnt_various]                                INT             NULL,
    [cnt_medical]                                INT             NULL,
    [cnt_ihs_reun]                               INT             NULL,
    [cnt_concrete_goods]                         INT             NULL,
    [cnt_budget_C12]                             INT             NULL,
    [cnt_budget_C14]                             INT             NULL,
    [cnt_budget_C15]                             INT             NULL,
    [cnt_budget_C16]                             INT             NULL,
    [cnt_budget_C18]                             INT             NULL,
    [cnt_budget_C19]                             INT             NULL,
    [cnt_uncat_svc]                              INT             NULL,
    [amt_pd_family_focused_services]             DECIMAL (38, 2) NULL,
    [amt_pd_child_care]                          DECIMAL (38, 2) NULL,
    [amt_pd_therapeutic_services]                DECIMAL (38, 2) NULL,
    [amt_pd_mh_services]                         DECIMAL (38, 2) NULL,
    [amt_pd_receiving_care]                      DECIMAL (38, 2) NULL,
    [amt_pd_family_home_placements]              DECIMAL (38, 2) NULL,
    [amt_pd_behavioral_rehabiliation_services]   DECIMAL (38, 2) NULL,
    [amt_pd_other_therapeutic_living_situations] DECIMAL (38, 2) NULL,
    [amt_pd_specialty_adolescent_services]       DECIMAL (38, 2) NULL,
    [amt_pd_respite]                             DECIMAL (38, 2) NULL,
    [amt_pd_transportation]                      DECIMAL (38, 2) NULL,
    [amt_pd_clothing_incidentals]                DECIMAL (38, 2) NULL,
    [amt_pd_sexually_aggressive_youth]           DECIMAL (38, 2) NULL,
    [amt_pd_adoption_support]                    DECIMAL (38, 2) NULL,
    [amt_pd_various]                             DECIMAL (38, 2) NULL,
    [amt_pd_medical]                             DECIMAL (38, 2) NULL,
    [amt_pd_ihs_reun]                            DECIMAL (18, 2) NULL,
    [amt_pd_concrete_goods]                      DECIMAL (18, 2) NULL,
    [amt_pd_budget_C12]                          DECIMAL (38, 2) NULL,
    [amt_pd_budget_C14]                          DECIMAL (38, 2) NULL,
    [amt_pd_budget_C15]                          DECIMAL (38, 2) NULL,
    [amt_pd_budget_C16]                          DECIMAL (38, 2) NULL,
    [amt_pd_budget_C18]                          DECIMAL (38, 2) NULL,
    [amt_pd_budget_C19]                          DECIMAL (38, 2) NULL,
    [amt_pd_uncat_svc]                           DECIMAL (38, 2) NULL,
    [total_paid]                                 DECIMAL (38, 2) NULL,
    CONSTRAINT [PK__episode___BE2EB58EB05EEB50] PRIMARY KEY CLUSTERED ([id_removal_episode_fact] ASC)
);
