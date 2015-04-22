CREATE TABLE [prtl].[rate_referrals_order_specific] (
    [nth_order]                  INT             NOT NULL,
    [start_date]                 DATETIME        NOT NULL,
    [date_type]                  INT             NOT NULL,
    [qry_type]                   INT             NOT NULL,
    [county_cd]                  INT             NOT NULL,
    [cnt_referrals]              INT             NULL,
    [prior_order_cnt_households] INT             NULL,
    [referral_rate]              NUMERIC (18, 9) NULL,
    CONSTRAINT [PK_rate_referrals_order_specific] PRIMARY KEY CLUSTERED ([nth_order] ASC, [start_date] ASC, [date_type] ASC, [qry_type] ASC, [county_cd] ASC),
    CONSTRAINT [rate_referrals_order_specific_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd])
);


GO
ALTER TABLE [prtl].[rate_referrals_order_specific] NOCHECK CONSTRAINT [rate_referrals_order_specific_county_cd_FK];

