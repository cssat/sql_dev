﻿CREATE TABLE [dbo].[ca_service_metadata] (
    [FamLink Service Type]             NUMERIC (18)  NULL,
    [FamLink Service Group]            VARCHAR (50)  NULL,
    [FamLink Service Category]         VARCHAR (50)  NULL,
    [SSPS Service Code]                NUMERIC (18)  NULL,
    [SSPS Reason Code]                 VARCHAR (50)  NULL,
    [FamLink Service Type Name]        VARCHAR (255) NULL,
    [SSPS Service Code Name]           VARCHAR (255) NULL,
    [SSPS Short Service Code Name]     VARCHAR (255) NULL,
    [Service Effective Begin Date]     DATETIME      NULL,
    [Service Effective End Date]       DATETIME      NULL,
    [Previous SSPS Service Code]       NUMERIC (18)  NULL,
    [Previous SSPS Reason Code]        VARCHAR (50)  NULL,
    [Service Concurrency]              VARCHAR (50)  NULL,
    [On-Going Service Placement]       VARCHAR (50)  NULL,
    [Tax Reporting Status]             VARCHAR (50)  NULL,
    [Payment Type]                     VARCHAR (50)  NULL,
    [Unpaid Service]                   VARCHAR (50)  NULL,
    [SSPS Invoice]                     VARCHAR (50)  NULL,
    [Non-System Disbursed]             VARCHAR (50)  NULL,
    [Date Last Paid]                   VARCHAR (50)  NULL,
    [Age Range]                        VARCHAR (50)  NULL,
    [Age Up Timing]                    VARCHAR (50)  NULL,
    [Next Service Type Age]            VARCHAR (50)  NULL,
    [Foster Care Rate Min Points]      VARCHAR (50)  NULL,
    [Foster Care Rate Max Points]      VARCHAR (50)  NULL,
    [Case Required]                    VARCHAR (50)  NULL,
    [License Required]                 VARCHAR (50)  NULL,
    [Contract Required]                VARCHAR (50)  NULL,
    [SS Notice Required]               VARCHAR (50)  NULL,
    [Approval Required]                VARCHAR (50)  NULL,
    [Regional Use All]                 VARCHAR (50)  NULL,
    [R7 - Central]                     VARCHAR (50)  NULL,
    [R1]                               VARCHAR (50)  NULL,
    [R2]                               VARCHAR (50)  NULL,
    [R3]                               VARCHAR (50)  NULL,
    [R4]                               VARCHAR (50)  NULL,
    [R5]                               VARCHAR (50)  NULL,
    [R6]                               VARCHAR (50)  NULL,
    [Include in IV-E Pen Rate]         VARCHAR (50)  NULL,
    [Eligiblity State]                 VARCHAR (50)  NULL,
    [Eligiblity None]                  VARCHAR (50)  NULL,
    [Eligiblity SSP]                   VARCHAR (50)  NULL,
    [Eligiblity IV-A]                  VARCHAR (50)  NULL,
    [Eligiblity IV-E]                  VARCHAR (50)  NULL,
    [Eligiblity Title XIX]             VARCHAR (50)  NULL,
    [Include in Trust Fund]            VARCHAR (50)  NULL,
    [SEMS]                             VARCHAR (50)  NULL,
    [Rate Type]                        VARCHAR (50)  NULL,
    [Rate By Service Or Provider]      VARCHAR (50)  NULL,
    [Amount Auto Calculated]           VARCHAR (50)  NULL,
    [Child Specific Rate Allowed]      VARCHAR (50)  NULL,
    [Unit Type]                        VARCHAR (50)  NULL,
    [Rate Effective Date]              DATETIME      NULL,
    [Rate Minimum]                     MONEY         NULL,
    [Rate Maximum]                     MONEY         NULL,
    [Maximum Monthly Quantity]         VARCHAR (50)  NULL,
    [Maximum Hours Quantity]           VARCHAR (50)  NULL,
    [Maximum Unit Quantity]            VARCHAR (50)  NULL,
    [Hidden Service Type]              VARCHAR (50)  NULL,
    [Length of Stay]                   VARCHAR (50)  NULL,
    [Service Limit Quantity]           VARCHAR (50)  NULL,
    [Service Limit Quantity Unit]      VARCHAR (50)  NULL,
    [Service Limit Amount]             VARCHAR (50)  NULL,
    [Service Limit Amount Unit]        VARCHAR (50)  NULL,
    [Restrict Same Provider]           VARCHAR (50)  NULL,
    [Restrict Different Provider]      VARCHAR (50)  NULL,
    [Quantity Per Placement]           VARCHAR (50)  NULL,
    [Placement Quantity Unit]          VARCHAR (50)  NULL,
    [Amount Per Placement]             VARCHAR (50)  NULL,
    [Placement Amount Unit]            VARCHAR (50)  NULL,
    [Date Service Created]             DATETIME      NULL,
    [Date Service Updated]             DATETIME      NULL,
    [Service Referral Required]        VARCHAR (50)  NULL,
    [Service Referral Fields Required] VARCHAR (50)  NULL,
    [EBP Field Required]               VARCHAR (50)  NULL,
    [tbl_last_update]                  DATETIME      NULL
);
