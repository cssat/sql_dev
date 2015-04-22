CREATE TYPE [dbo].[prm_fnd] AS TABLE (
    [cd_finding] INT          NOT NULL,
    [match_code] DECIMAL (18) NOT NULL,
    PRIMARY KEY CLUSTERED ([cd_finding] ASC, [match_code] ASC));

