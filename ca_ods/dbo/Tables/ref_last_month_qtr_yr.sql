CREATE TABLE [dbo].[ref_last_month_qtr_yr] (
    [date_type] INT      NOT NULL,
    [end_date]  DATETIME NULL,
    PRIMARY KEY CLUSTERED ([date_type] ASC)
);

