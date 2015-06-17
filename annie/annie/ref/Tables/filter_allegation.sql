CREATE TABLE [ref].[filter_allegation]
(
    [cd_allegation] INT NOT NULL 
        CONSTRAINT [pk_filter_allegation] PRIMARY KEY, 
    [tx_allegation] VARCHAR(50) NOT NULL, 
    [min_filter_date] DATE NULL
)
