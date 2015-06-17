CREATE TABLE [ref].[filter_dependency]
(
    [bin_dependency_cd] INT NOT NULL 
        CONSTRAINT [pk_filter_dependency] PRIMARY KEY, 
    [bin_dependency_desc] VARCHAR(50) NOT NULL, 
    [diff_days_from] INT NULL, 
    [diff_days_thru] INT NULL, 
    [fl_dep_exist] TINYINT NULL, 
    [lag_days] INT NULL, 
    [min_filter_date] DATE NULL
)
