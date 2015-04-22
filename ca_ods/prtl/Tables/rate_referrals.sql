CREATE TABLE [prtl].[rate_referrals] (
    [qry_type]      INT            NOT NULL,
    [date_type]     INT            NOT NULL,
    [start_date]    DATETIME       NOT NULL,
    [county_cd]     INT            NOT NULL,
    [entry_point]   INT            NOT NULL,
    [cnt_referrals] INT            NOT NULL,
    [tot_pop]       INT            NOT NULL,
    [referral_rate] NUMERIC (9, 4) NULL,
    [ds_trend]      FLOAT (53)     NULL,
    CONSTRAINT [PK_rate_referrals_1] PRIMARY KEY CLUSTERED ([start_date] ASC, [county_cd] ASC, [entry_point] ASC),
    CONSTRAINT [rate_referrals_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [rate_referrals_screened_in_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd])
);

