﻿CREATE TABLE [dbo].[ref_match_srvc_type_category] (
    [filter_srvc_type]                       DECIMAL (21) NOT NULL,
    [fl_family_focused_services]             SMALLINT     NOT NULL,
    [fl_child_care]                          SMALLINT     NOT NULL,
    [fl_therapeutic_services]                SMALLINT     NOT NULL,
    [fl_mh_services]                         SMALLINT     NOT NULL,
    [fl_receiving_care]                      SMALLINT     NOT NULL,
    [fl_family_home_placements]              SMALLINT     NOT NULL,
    [fl_behavioral_rehabiliation_services]   SMALLINT     NOT NULL,
    [fl_other_therapeutic_living_situations] SMALLINT     NOT NULL,
    [fl_specialty_adolescent_services]       SMALLINT     NOT NULL,
    [fl_respite]                             SMALLINT     NOT NULL,
    [fl_transportation]                      SMALLINT     NOT NULL,
    [fl_clothing_incidentals]                SMALLINT     NOT NULL,
    [fl_sexually_aggressive_youth]           SMALLINT     NOT NULL,
    [fl_adoption_support]                    SMALLINT     NOT NULL,
    [fl_various]                             SMALLINT     NOT NULL,
    [fl_medical]                             SMALLINT     NOT NULL,
    [fl_ihs_reun]                            SMALLINT     NOT NULL,
    [fl_concrete_goods]                      SMALLINT     NOT NULL,
    [cd_subctgry_poc_fr]                     INT          DEFAULT ((0)) NOT NULL,
    [int_filter_service_category]            INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([int_filter_service_category] ASC, [cd_subctgry_poc_fr] ASC)
);

