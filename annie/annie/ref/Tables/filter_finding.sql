CREATE TABLE [ref].[filter_finding]
(
    [cd_finding] INT NOT NULL 
        CONSTRAINT [pk_filter_finding] PRIMARY KEY, 
    [tx_finding] VARCHAR(50) NOT NULL, 
    [min_filter_date] DATE NULL
)
