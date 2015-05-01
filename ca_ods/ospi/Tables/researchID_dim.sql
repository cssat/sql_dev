CREATE TABLE [ospi].[researchID_dim] (
    [ResearchID]     VARCHAR (10) NOT NULL,
    [int_researchID] INT          IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([int_researchID] ASC)
);

