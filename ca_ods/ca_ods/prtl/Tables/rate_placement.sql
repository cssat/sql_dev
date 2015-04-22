CREATE TABLE [prtl].[rate_placement] (
    [date_type]             INT             NOT NULL,
    [qry_type]              INT             NOT NULL,
    [cohort_date]           DATETIME        NOT NULL,
    [county_cd]             INT             NOT NULL,
    [entry_point]           INT             NOT NULL,
    [cnt_households_w_plcm] INT             NULL,
    [cnt_referrals_u18]     INT             NULL,
    [rate_placement]        NUMERIC (18, 9) NULL,
    [ds_trend]              FLOAT (53)      NULL,
    CONSTRAINT [PK_rate_placement] PRIMARY KEY CLUSTERED ([cohort_date] ASC, [county_cd] ASC, [entry_point] ASC),
    CONSTRAINT [rate_placement_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd])
);

