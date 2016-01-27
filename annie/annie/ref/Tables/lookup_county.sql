CREATE TABLE [ref].[lookup_county] (
    [cd_county] INT NOT NULL 
        CONSTRAINT [pk_lookup_county] PRIMARY KEY, 
    [county_desc] VARCHAR(50) NOT NULL, 
    [small_fl] TINYINT NOT NULL
	)
