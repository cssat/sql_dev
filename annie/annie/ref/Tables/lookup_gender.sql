CREATE TABLE [ref].[lookup_gender]
(
    [pk_gender] INT NOT NULL 
        CONSTRAINT [pk_lookup_gender] PRIMARY KEY, 
    [cd_gender] CHAR NOT NULL, 
    [tx_gender] VARCHAR(10) NOT NULL
)
