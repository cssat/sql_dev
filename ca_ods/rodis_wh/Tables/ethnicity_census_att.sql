CREATE TABLE [rodis_wh].[ethnicity_census_att] (
    [id_ethnicity_census] INT          NOT NULL,
    [cd_ethnicity_census] VARCHAR (50) NOT NULL,
    [tx_ethnicity_census] VARCHAR (50) NULL,
    CONSTRAINT [pk_ethnicity_census_att] PRIMARY KEY CLUSTERED ([id_ethnicity_census] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ethnicity_census_att_cd_ethnicity_census]
    ON [rodis_wh].[ethnicity_census_att]([cd_ethnicity_census] ASC);

