CREATE TABLE [ref].[filter_access_type]
(
    [cd_access_type] INT NOT NULL 
        CONSTRAINT [pk_filter_access_type] PRIMARY KEY, 
    [tx_access_type] VARCHAR(50) NOT NULL, 
    [fl_name] VARCHAR(50) NULL, 
    [cd_multiplier] DECIMAL(18, 0) NULL, 
    [filter_access_type] INT NOT NULL, 
    [min_filter_date] DATE NULL
)
