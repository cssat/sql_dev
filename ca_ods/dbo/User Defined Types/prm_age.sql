CREATE TYPE [dbo].[prm_age] AS TABLE (
    [age_grouping_cd] INT NOT NULL,
    [match_code]      INT NOT NULL,
    PRIMARY KEY CLUSTERED ([age_grouping_cd] ASC, [match_code] ASC));

