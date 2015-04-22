CREATE TABLE [base].[WRK_nonDCFS_All] (
    [ID_PRSN]                INT          NULL,
    [CUST_BEGIN]             DATETIME     NULL,
    [CUST_END]               DATETIME     NULL,
    [backtoDCFS]             INT          NULL,
    [CD_PLACEMENT_CARE_AUTH] INT          NULL,
    [PLACEMENT_CARE_AUTH]    VARCHAR (16) NULL,
    [nondcfs_mark]           INT          NOT NULL,
    [tbl_refresh_dt]         DATETIME     NULL
);

