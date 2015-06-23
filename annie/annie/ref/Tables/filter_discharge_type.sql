CREATE TABLE [ref].[filter_discharge_type]
(
    [cd_discharge_type] INT NOT NULL 
        CONSTRAINT [pk_filter_discharge_type] PRIMARY KEY, 
    [discharge_type] VARCHAR(50) NOT NULL, 
    [alt_discharge_type] VARCHAR(50) NOT NULL
)
