CREATE TABLE [ospi].[district_school] (
    [DistrictID]   INT           NOT NULL,
    [DistrictCode] VARCHAR (5)   NULL,
    [SchoolCode]   INT           NOT NULL,
    [SchoolType]   VARCHAR (255) NULL,
    [GradeStart]   VARCHAR (255) NULL,
    [GradeEnd]     VARCHAR (255) NULL,
    CONSTRAINT [pk_ospi_schooltypes] PRIMARY KEY CLUSTERED ([DistrictID] ASC, [SchoolCode] ASC)
);

