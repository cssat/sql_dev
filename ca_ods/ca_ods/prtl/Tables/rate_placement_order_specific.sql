CREATE TABLE [prtl].[rate_placement_order_specific] (
    [date_type]                     INT             NOT NULL,
    [qry_type]                      INT             NOT NULL,
    [cohort_date]                   DATETIME        NOT NULL,
    [nth_order]                     INT             NOT NULL,
    [county_cd]                     INT             NOT NULL,
    [cnt_nth_order_placement_cases] INT             NULL,
    [cnt_prior_order_si_referrals]  INT             NULL,
    [placement_rate]                NUMERIC (18, 9) NULL,
    CONSTRAINT [PK_rate_placement_order_specific] PRIMARY KEY CLUSTERED ([date_type] ASC, [qry_type] ASC, [cohort_date] ASC, [nth_order] ASC, [county_cd] ASC)
);

