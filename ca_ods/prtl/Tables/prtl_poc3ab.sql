﻿CREATE TABLE [prtl].[prtl_poc3ab] (
    [qry_type]                         INT      NOT NULL,
    [date_type]                        INT      NOT NULL,
    [start_date]                       DATETIME NOT NULL,
    [start_year]                       INT      NOT NULL,
    [int_match_param_key]              BIGINT   NOT NULL,
    [bin_ihs_svc_cd]                   INT      NOT NULL,
    [cd_reporter_type]                 INT      NOT NULL,
    [filter_access_type]               INT      CONSTRAINT [DF__prtl_poc3__filte__11606D5A] DEFAULT (power((10),(5))) NOT NULL,
    [filter_allegation]                INT      CONSTRAINT [DF__prtl_poc3__filte__12549193] DEFAULT (power((10),(4))) NOT NULL,
    [filter_finding]                   INT      CONSTRAINT [DF__prtl_poc3__filte__1348B5CC] DEFAULT (power((10),(4))) NOT NULL,
    [filter_service_category]          INT      NOT NULL,
    [filter_service_budget]            INT      NOT NULL,
    [cd_sib_age_group]                 INT      NOT NULL,
    [cd_race_census]                   INT      NOT NULL,
    [census_hispanic_latino_origin_cd] INT      NOT NULL,
    [county_cd]                        INT      NOT NULL,
    [cnt_start_date]                   INT      NOT NULL,
    [cnt_opened]                       INT      NOT NULL,
    [cnt_closed]                       INT      NOT NULL,
    CONSTRAINT [PK_prtl_poc3ab_1] PRIMARY KEY CLUSTERED ([qry_type] ASC, [date_type] ASC, [start_date] ASC, [int_match_param_key] ASC, [bin_ihs_svc_cd] ASC, [cd_reporter_type] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC, [filter_service_category] ASC, [filter_service_budget] ASC),
    CONSTRAINT [prtl_poc3ab_bin_ihs_svc_cd_FK] FOREIGN KEY ([bin_ihs_svc_cd]) REFERENCES [dbo].[ref_filter_ihs_services] ([bin_ihs_svc_cd]),
    CONSTRAINT [prtl_poc3ab_cd_race_FK] FOREIGN KEY ([cd_race_census]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [prtl_poc3ab_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [prtl_poc3ab_cd_sib_age_grpr_FK] FOREIGN KEY ([cd_sib_age_group]) REFERENCES [dbo].[ref_lookup_sib_age_grp] ([cd_sib_age_grp]),
    CONSTRAINT [prtl_poc3ab_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [prtl_poc3ab_filter_service_category_FK] FOREIGN KEY ([filter_service_category]) REFERENCES [dbo].[ref_service_category_flag_xwalk] ([int_filter_service_category]),
    CONSTRAINT [prtl_poc3ab_origin_cd_FK] FOREIGN KEY ([census_hispanic_latino_origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd])
);


GO
CREATE NONCLUSTERED INDEX [idx_prtl_poc3ab]
    ON [prtl].[prtl_poc3ab]([qry_type] ASC, [date_type] ASC, [start_date] ASC, [int_match_param_key] ASC, [cd_reporter_type] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC, [filter_service_category] ASC, [filter_service_budget] ASC)
    INCLUDE([bin_ihs_svc_cd]);


GO
ALTER INDEX [idx_prtl_poc3ab]
    ON [prtl].[prtl_poc3ab] DISABLE;


GO
CREATE NONCLUSTERED INDEX [idx_qry_type_start_date]
    ON [prtl].[prtl_poc3ab]([qry_type] ASC, [start_date] ASC)
    INCLUDE([date_type], [start_year], [int_match_param_key], [bin_ihs_svc_cd], [county_cd], [cnt_start_date], [cnt_opened], [cnt_closed], [cd_reporter_type], [filter_access_type], [filter_allegation], [filter_finding], [filter_service_category], [filter_service_budget]);
