CREATE TABLE [prtl].[prtl_poc2ab] (
    [qry_type]                         INT      NOT NULL,
    [date_type]                        INT      NOT NULL,
    [start_date]                       DATETIME NOT NULL,
    [start_year]                       INT      NOT NULL,
    [int_match_param_key]              BIGINT   NOT NULL,
    [cd_reporter_type]                 INT      NOT NULL,
    [filter_access_type]               INT      CONSTRAINT [DF__prtl_poc2__filte__32024716] DEFAULT (power((10),(5))) NOT NULL,
    [filter_allegation]                INT      CONSTRAINT [DF__prtl_poc2__filte__32F66B4F] DEFAULT (power((10),(4))) NOT NULL,
    [filter_finding]                   INT      CONSTRAINT [DF__prtl_poc2__filte__33EA8F88] DEFAULT (power((10),(4))) NOT NULL,
    [cd_sib_age_group]                 INT      NULL,
    [cd_race_census]                   INT      NULL,
    [census_hispanic_latino_origin_cd] INT      NOT NULL,
    [county_cd]                        INT      NULL,
    [cnt_start_date]                   INT      NULL,
    [cnt_opened]                       INT      NULL,
    [cnt_closed]                       INT      NULL,
    CONSTRAINT [PK__prtl_poc__D530CF965353F541] PRIMARY KEY CLUSTERED ([qry_type] ASC, [date_type] ASC, [start_date] ASC, [int_match_param_key] ASC, [cd_reporter_type] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC),
    CONSTRAINT [prtl_poc2ab_cd_race_FK] FOREIGN KEY ([cd_race_census]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [prtl_poc2ab_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [prtl_poc2ab_cd_sib_age_grpr_FK] FOREIGN KEY ([cd_sib_age_group]) REFERENCES [dbo].[ref_lookup_sib_age_grp] ([cd_sib_age_grp]),
    CONSTRAINT [prtl_poc2ab_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [prtl_poc2ab_origin_cd_FK] FOREIGN KEY ([census_hispanic_latino_origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd])
);


GO
CREATE NONCLUSTERED INDEX [idx_prtl_poc2ab_qry_type_start_date]
    ON [prtl].[prtl_poc2ab]([qry_type] ASC, [start_date] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_start_date]
    ON [prtl].[prtl_poc2ab]([start_date] ASC, [qry_type] ASC);

