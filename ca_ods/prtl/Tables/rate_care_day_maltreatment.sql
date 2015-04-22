CREATE TABLE [prtl].[rate_care_day_maltreatment] (
    [date_type]              INT             NULL,
    [qry_type]               INT             NULL,
    [fiscal_yr]              INT             NOT NULL,
    [county_cd]              INT             NOT NULL,
    [care_days]              INT             NULL,
    [cnt_incidents]          INT             NULL,
    [care_day_incident_rate] NUMERIC (18, 9) NULL,
    PRIMARY KEY CLUSTERED ([county_cd] ASC, [fiscal_yr] ASC)
);

