CREATE TABLE [dbo].[Time] (
    [PK_Date]              DATETIME      NOT NULL,
    [Date_Name]            NVARCHAR (50) NULL,
    [Year]                 DATETIME      NULL,
    [Year_Name]            NVARCHAR (50) NULL,
    [Quarter]              DATETIME      NULL,
    [Quarter_Name]         NVARCHAR (50) NULL,
    [Day_Of_Year]          INT           NULL,
    [Day_Of_Year_Name]     NVARCHAR (50) NULL,
    [Day_Of_Quarter]       INT           NULL,
    [Day_Of_Quarter_Name]  NVARCHAR (50) NULL,
    [Quarter_Of_Year]      INT           NULL,
    [Quarter_Of_Year_Name] NVARCHAR (50) NULL,
    CONSTRAINT [PK_Time] PRIMARY KEY CLUSTERED ([PK_Date] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'CONSTRAINT', @level2name = N'PK_Time';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'DSVTable', @value = N'Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'Project', @value = N'a5420ad5-9df0-47ed-a36e-6de7febe74f8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'PK_Date';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'PK_Date';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Date_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Date_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Date_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Year';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Year';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Year_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Year_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Year_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Quarter_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Year';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Year';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Year_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Year_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Year_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Quarter';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Quarter';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Quarter_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Quarter_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Quarter_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Of_Year';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Quarter_Of_Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Of_Year';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Of_Year_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Quarter_Of_Year_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Quarter_Of_Year_Name';

