CREATE TABLE [ref].[filter_los]
(
    [bin_los_cd] INT NOT NULL 
        CONSTRAINT [pk_filter_los] PRIMARY KEY, 
    [bin_los_desc] VARCHAR(50) NOT NULL, 
    [dur_days_from] INT NULL, 
    [dur_days_thru] INT NULL, 
    [lag_days] INT NULL
)
