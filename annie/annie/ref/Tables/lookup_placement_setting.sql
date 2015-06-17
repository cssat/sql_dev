CREATE TABLE [ref].[lookup_placement_setting]
(
    [cd_placement_setting] INT NOT NULL 
        CONSTRAINT [pk_lookup_placement] PRIMARY KEY, 
    [tx_placement_setting] VARCHAR(50) NOT NULL
)
