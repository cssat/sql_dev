CREATE TABLE [dbo].[CA_NULL_ANALYSIS] (
    [colname]      VARCHAR (200)  NULL,
    [tblname]      VARCHAR (200)  NULL,
    [tblrecordcnt] INT            NULL,
    [nullcnt]      INT            NULL,
    [nullprcnt]    DECIMAL (9, 2) NULL,
    [load_date]    DATETIME       NULL
);

