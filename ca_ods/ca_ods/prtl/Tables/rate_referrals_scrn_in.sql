CREATE TABLE [prtl].[rate_referrals_scrn_in] (
    [qry_type]      INT            NOT NULL,
    [date_type]     INT            NOT NULL,
    [start_date]    DATETIME       NOT NULL,
    [county_cd]     INT            NOT NULL,
    [entry_point]   INT            NOT NULL,
    [cnt_referrals] INT            NOT NULL,
    [tot_pop]       INT            NULL,
    [referral_rate] NUMERIC (9, 4) NULL,
    [ds_trend]      FLOAT (53)     NULL,
    CONSTRAINT [PK_rate_referrals_scrn_in] PRIMARY KEY CLUSTERED ([start_date] ASC, [county_cd] ASC, [entry_point] ASC)
);

