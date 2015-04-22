CREATE TYPE [dbo].[prm_alg] AS TABLE (
    [cd_allegation] INT          NOT NULL,
    [match_code]    DECIMAL (18) NOT NULL,
    PRIMARY KEY CLUSTERED ([cd_allegation] ASC, [match_code] ASC));

