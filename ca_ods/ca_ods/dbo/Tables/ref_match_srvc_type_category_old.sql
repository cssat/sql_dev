CREATE TABLE [dbo].[ref_match_srvc_type_category_old] (
    [filter_srvc_type]                       DECIMAL (18) NOT NULL,
    [fl_family_focused_services]             INT          NOT NULL,
    [fl_child_care]                          INT          NOT NULL,
    [fl_therapeutic_services]                INT          NOT NULL,
    [fl_mh_services]                         INT          NOT NULL,
    [fl_receiving_care]                      INT          NOT NULL,
    [fl_family_home_placements]              INT          NOT NULL,
    [fl_behavioral_rehabiliation_services]   INT          NOT NULL,
    [fl_other_therapeutic_living_situations] INT          NOT NULL,
    [fl_specialty_adolescent_services]       INT          NOT NULL,
    [fl_respite]                             INT          NOT NULL,
    [fl_transportation]                      INT          NOT NULL,
    [fl_clothing_incidentals]                INT          NOT NULL,
    [fl_sexually_aggressive_youth]           INT          NOT NULL,
    [fl_adoption_support]                    INT          NOT NULL,
    [fl_various]                             INT          NOT NULL,
    [fl_medical]                             INT          NOT NULL,
    [cd_subctgry_poc_fr]                     INT          DEFAULT ((0)) NOT NULL,
    [id_service_category]                    INT          NULL,
    PRIMARY KEY CLUSTERED ([filter_srvc_type] ASC, [cd_subctgry_poc_fr] ASC)
);

