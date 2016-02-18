CREATE TABLE [prtl].[ia_trends_cache] (
    [row_id]               INT            NOT NULL,
    [qry_type]             TINYINT        NOT NULL,
    [date_type]            TINYINT        NOT NULL,
    [start_date]           DATETIME       NOT NULL,
    [age_sib_group_cd]     TINYINT        NOT NULL,
    [cd_race_census]       TINYINT        NOT NULL,
    [cd_county]            TINYINT        NOT NULL,
    [cd_reporter_type]     TINYINT        NOT NULL,
    [cd_access_type]       TINYINT        NOT NULL,
    [cd_allegation]        TINYINT        NOT NULL,
    [cd_finding]           TINYINT        NOT NULL,
    [cnt_start_date]       INT            NOT NULL,
    [cnt_opened]           INT            NOT NULL,
    [x1]                   FLOAT (53)     NOT NULL,
    [x2]                   FLOAT (53)     NOT NULL,
    [jit_start_date]       INT            NULL,
    [jit_opened]           INT            NULL,
    [rate_opened]          DECIMAL (9, 2) NULL,
    [fl_include_perCapita] BIT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [pk_ia_trends_cache] PRIMARY KEY CLUSTERED ([row_id] ASC)
);


GO


GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_cache]
    ON [prtl].[ia_trends_cache]([age_sib_group_cd] ASC, [cd_race_census] ASC, [cd_county] ASC, [cd_reporter_type] ASC, [cd_access_type] ASC, [cd_allegation] ASC, [cd_finding] ASC)
    INCLUDE([row_id], [qry_type], [date_type], [start_date], [jit_start_date], [jit_opened], [rate_opened], [fl_include_perCapita]);


GO
