CREATE TABLE [ospi].[school_dim] (
    [SchoolCode]     INT           NOT NULL,
    [SchoolName]     VARCHAR (255) NULL,
    [SchoolType]     VARCHAR (4)   NULL,
    [GradeStart]     VARCHAR (2)   NULL,
    [GradeEnd]       VARCHAR (2)   NULL,
    [CurrentStatus]  VARCHAR (50)  NULL,
    [SchoolOpen]     DATETIME      NULL,
    [SchoolClosed]   DATETIME      NULL,
    [NameChange]     DATETIME      NULL,
    [int_schooltype] INT           DEFAULT ((999)) NOT NULL,
    PRIMARY KEY CLUSTERED ([SchoolCode] ASC)
);

