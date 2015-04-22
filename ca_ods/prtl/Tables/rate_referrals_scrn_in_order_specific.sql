CREATE TABLE [prtl].[rate_referrals_scrn_in_order_specific] (
    [qry_type]              INT            NOT NULL,
    [date_type]             INT            NOT NULL,
    [start_date]            DATETIME       NOT NULL,
    [county_cd]             INT            NOT NULL,
    [prior_order_referrals] INT            NULL,
    [cnt_referrals]         INT            NOT NULL,
    [referral_rate]         NUMERIC (9, 4) NULL,
    [nth_order]             INT            NOT NULL,
    CONSTRAINT [PK_rate_referrals_scrn_in_order_specific] PRIMARY KEY CLUSTERED ([county_cd] ASC, [nth_order] ASC, [start_date] ASC)
);

