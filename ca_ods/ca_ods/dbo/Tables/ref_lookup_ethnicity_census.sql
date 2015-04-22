CREATE TABLE [dbo].[ref_lookup_ethnicity_census] (
    [cd_race_census] INT           NOT NULL,
    [tx_race_census] VARCHAR (200) NULL,
    CONSTRAINT [ct_pk_cd_race_census] PRIMARY KEY CLUSTERED ([cd_race_census] ASC)
);

