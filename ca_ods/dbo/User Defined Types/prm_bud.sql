CREATE TYPE [dbo].[prm_bud] AS TABLE (
    [cd_budget_poc_frc] INT          NOT NULL,
    [match_code]        DECIMAL (18) NOT NULL,
    PRIMARY KEY CLUSTERED ([cd_budget_poc_frc] ASC, [match_code] ASC));

