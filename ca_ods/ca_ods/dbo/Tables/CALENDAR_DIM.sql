CREATE TABLE [dbo].[CALENDAR_DIM] (
    [ID_CALENDAR_DIM]                      INT          NOT NULL,
    [CALENDAR_DATE]                        DATETIME     NULL,
    [YEAR_YYYY]                            INT          NULL,
    [MONTH_MM]                             INT          NULL,
    [DAY_DD]                               INT          NULL,
    [DATE_NAME]                            VARCHAR (50) NULL,
    [YEAR]                                 DATETIME     NULL,
    [YEAR_NAME]                            VARCHAR (50) NULL,
    [QUARTER]                              DATETIME     NULL,
    [QUARTER_NAME]                         VARCHAR (50) NULL,
    [MONTH]                                DATETIME     NULL,
    [MONTH_NAME]                           VARCHAR (50) NULL,
    [WEEK]                                 DATETIME     NULL,
    [WEEK_NAME]                            VARCHAR (50) NULL,
    [DAY_OF_YEAR]                          INT          NULL,
    [DAY_OF_YEAR_NAME]                     VARCHAR (50) NULL,
    [DAY_OF_QUARTER]                       INT          NULL,
    [DAY_OF_QUARTER_NAME]                  VARCHAR (50) NULL,
    [DAY_OF_MONTH]                         INT          NULL,
    [DAY_OF_MONTH_NAME]                    VARCHAR (50) NULL,
    [DAY_OF_WEEK]                          INT          NULL,
    [DAY_OF_WEEK_NAME]                     VARCHAR (50) NULL,
    [WEEK_OF_YEAR]                         INT          NULL,
    [WEEK_OF_YEAR_NAME]                    VARCHAR (50) NULL,
    [MONTH_OF_YEAR]                        INT          NULL,
    [MONTH_OF_YEAR_NAME]                   VARCHAR (50) NULL,
    [MONTH_OF_QUARTER]                     INT          NULL,
    [MONTH_OF_QUARTER_NAME]                VARCHAR (50) NULL,
    [QUARTER_OF_YEAR]                      INT          NULL,
    [QUARTER_OF_YEAR_NAME]                 VARCHAR (50) NULL,
    [FEDERAL_FISCAL_YEAR]                  DATETIME     NULL,
    [FEDERAL_FISCAL_YEAR_NAME]             VARCHAR (50) NULL,
    [FEDERAL_FISCAL_QUARTER]               DATETIME     NULL,
    [FEDERAL_FISCAL_QUARTER_NAME]          VARCHAR (50) NULL,
    [FEDERAL_FISCAL_MONTH]                 DATETIME     NULL,
    [FEDERAL_FISCAL_MONTH_NAME]            VARCHAR (50) NULL,
    [FEDERAL_FISCAL_WEEK]                  DATETIME     NULL,
    [FEDERAL_FISCAL_WEEK_NAME]             VARCHAR (50) NULL,
    [FEDERAL_FISCAL_DAY]                   DATETIME     NULL,
    [FEDERAL_FISCAL_DAY_NAME]              VARCHAR (50) NULL,
    [FEDERAL_FISCAL_DAY_OF_YEAR]           INT          NULL,
    [FEDERAL_FISCAL_DAY_OF_YEAR_NAME]      VARCHAR (50) NULL,
    [FEDERAL_FISCAL_DAY_OF_QUARTER]        INT          NULL,
    [FEDERAL_FISCAL_DAY_OF_QUARTER_NAME]   VARCHAR (50) NULL,
    [FEDERAL_FISCAL_DAY_OF_MONTH]          INT          NULL,
    [FEDERAL_FISCAL_DAY_OF_MONTH_NAME]     VARCHAR (50) NULL,
    [FEDERAL_FISCAL_DAY_OF_WEEK]           INT          NULL,
    [FEDERAL_FISCAL_DAY_OF_WEEK_NAME]      VARCHAR (50) NULL,
    [FEDERAL_FISCAL_WEEK_OF_YEAR]          INT          NULL,
    [FEDERAL_FISCAL_WEEK_OF_YEAR_NAME]     VARCHAR (50) NULL,
    [FEDERAL_FISCAL_MONTH_OF_YEAR]         INT          NULL,
    [FEDERAL_FISCAL_MONTH_OF_YEAR_NAME]    VARCHAR (50) NULL,
    [FEDERAL_FISCAL_MONTH_OF_QUARTER]      INT          NULL,
    [FEDERAL_FISCAL_MONTH_OF_QUARTER_NAME] VARCHAR (50) NULL,
    [FEDERAL_FISCAL_QUARTER_OF_YEAR]       INT          NULL,
    [FEDERAL_FISCAL_QUARTER_OF_YEAR_NAME]  VARCHAR (50) NULL,
    [STATE_FISCAL_YEAR]                    DATETIME     NULL,
    [STATE_FISCAL_YEAR_NAME]               VARCHAR (50) NULL,
    [STATE_FISCAL_QUARTER]                 DATETIME     NULL,
    [STATE_FISCAL_QUARTER_NAME]            VARCHAR (50) NULL,
    [STATE_FISCAL_MONTH]                   DATETIME     NULL,
    [STATE_FISCAL_MONTH_NAME]              VARCHAR (50) NULL,
    [STATE_FISCAL_WEEK]                    DATETIME     NULL,
    [STATE_FISCAL_WEEK_NAME]               VARCHAR (50) NULL,
    [STATE_FISCAL_DAY]                     DATETIME     NULL,
    [STATE_FISCAL_DAY_NAME]                VARCHAR (50) NULL,
    [STATE_FISCAL_DAY_OF_YEAR]             INT          NULL,
    [STATE_FISCAL_DAY_OF_YEAR_NAME]        VARCHAR (50) NULL,
    [STATE_FISCAL_DAY_OF_QUARTER]          VARCHAR (50) NULL,
    [STATE_FISCAL_DAY_OF_QUARTER_NAME]     VARCHAR (50) NULL,
    [STATE_FISCAL_DAY_OF_MONTH]            INT          NULL,
    [STATE_FISCAL_DAY_OF_MONTH_NAME]       VARCHAR (50) NULL,
    [STATE_FISCAL_DAY_OF_WEEK]             INT          NULL,
    [STATE_FISCAL_DAY_OF_WEEK_NAME]        VARCHAR (50) NULL,
    [STATE_FISCAL_WEEK_OF_YEAR]            INT          NULL,
    [STATE_FISCAL_WEEK_OF_YEAR_NAME]       VARCHAR (50) NULL,
    [STATE_FISCAL_MONTH_OF_YEAR]           INT          NULL,
    [STATE_FISCAL_MONTH_OF_YEAR_NAME]      VARCHAR (50) NULL,
    [STATE_FISCAL_MONTH_OF_QUARTER]        INT          NULL,
    [STATE_FISCAL_MONTH_OF_QUARTER_NAME]   VARCHAR (50) NULL,
    [STATE_FISCAL_QUARTER_OF_YEAR]         INT          NULL,
    [STATE_FISCAL_QUARTER_OF_YEAR_NAME]    VARCHAR (50) NULL,
    [STATE_HOLIDAY_FLAG]                   VARCHAR (1)  NULL,
    [WORKDAY_FLAG]                         VARCHAR (1)  NULL,
    [DST_FLAG]                             VARCHAR (1)  NULL,
    [DT_ROW_BEGIN]                         DATETIME     NULL,
    [DT_ROW_END]                           DATETIME     NULL,
    [ID_CYCLE]                             INT          NULL,
    [IS_CURRENT]                           INT          NULL,
    [MONTH_END_FLAG]                       CHAR (1)     NULL,
    [CALENDAR_DATE_YYYY_MM_DD]             CHAR (10)    NULL,
    [CALENDAR_DATE_MM_DD_YYYY]             CHAR (10)    NULL,
    [LASTOFMONTH]                          DATETIME     NULL,
    [CASEMONTH]                            INT          NULL,
    [MONTH_TEXT]                           VARCHAR (9)  NULL,
    [MONTH_TEXT_ABBR]                      CHAR (3)     NULL,
    [YEAR_MONTH]                           INT          NULL,
    [FIRST_OF_MONTH]                       DATETIME     NULL,
    [FEDERAL_FISCAL_YYYY]                  INT          NULL,
    [STATE_FISCAL_YYYY]                    INT          NULL,
    CONSTRAINT [pk_ID_CALENDAR_DIM] PRIMARY KEY CLUSTERED ([ID_CALENDAR_DIM] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_calendar_dim]
    ON [dbo].[CALENDAR_DIM]([CALENDAR_DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_1238hasd]
    ON [dbo].[CALENDAR_DIM]([MONTH] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_state_fiscal_year]
    ON [dbo].[CALENDAR_DIM]([STATE_FISCAL_YEAR] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_month_calendar_date_calendar_dim]
    ON [dbo].[CALENDAR_DIM]([CALENDAR_DATE] ASC)
    INCLUDE([MONTH]);


GO
CREATE NONCLUSTERED INDEX [idx_fy_calendar_date]
    ON [dbo].[CALENDAR_DIM]([STATE_FISCAL_YYYY] ASC)
    INCLUDE([CALENDAR_DATE]);

