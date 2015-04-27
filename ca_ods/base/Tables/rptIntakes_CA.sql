﻿CREATE TABLE [base].[rptIntakes_CA] (
    [ID_ACCESS_REPORT]                        INT           NOT NULL,
    [DT_ACCESS_RCVD]                          DATETIME      NULL,
    [YEAR_DT_ACCESS_RCVD]                     DATETIME      NULL,
    [YEAR_NAME_DT_ACCESS_RCVD]                VARCHAR (20)  NULL,
    [MONTH_NAME_DT_ACCESS_RCVD]               VARCHAR (20)  NULL,
    [STATE_FISCAL_YEAR_NAME_DT_ACCESS_RCVD]   VARCHAR (10)  NULL,
    [FEDERAL_FISCAL_YEAR_NAME_DT_ACCESS_RCVD] VARCHAR (10)  NULL,
    [CPS_YESNO]                               CHAR (3)      NULL,
    [INTAKE_TYPE]                             VARCHAR (200) NULL,
    [CD_NON_CPS]                              NVARCHAR (50) NULL,
    [SCREEN_DCSN]                             VARCHAR (200) NULL,
    [CD_REASON]                               INT           NULL,
    [REASON]                                  VARCHAR (200) NULL,
    [RESPONSE_TIME]                           VARCHAR (200) NULL,
    [MAJOR_CAN]                               INT           NULL,
    [PHYSICAL_ABUSE]                          INT           NULL,
    [SEXUAL_ABUSE]                            INT           NULL,
    [NEGLECT]                                 INT           NULL,
    [SEXUAL_EXPLOIT]                          INT           NULL,
    [ABANDONED]                               INT           NULL,
    [OTHER]                                   INT           NULL,
    [ID_CASE]                                 INT           NULL,
    [ID_PRVD_ORG_INTAKE]                      INT           NULL,
    [CD_REGION]                               INT           NULL,
    [REGION]                                  VARCHAR (200) NULL,
    [INTAKE_REGION]                           VARCHAR (200) NULL,
    [CD_INTAKE_REGION]                        INT           NULL,
    [INTAKE_OFFICE]                           VARCHAR (200) NULL,
    [CD_INTAKE_OFFICE]                        INT           NULL,
    [INTAKE_UNIT]                             NVARCHAR (10) NULL,
    [CASE_REGION]                             VARCHAR (200) NULL,
    [CD_CASE_REGION]                          INT           NULL,
    [CASE_OFFICE]                             VARCHAR (200) NULL,
    [CD_CASE_OFFICE]                          INT           NULL,
    [PRIMARY_WRKR]                            NVARCHAR (50) NULL,
    [WRKR_REGION]                             VARCHAR (200) NULL,
    [CD_WRKR_REGION]                          INT           NULL,
    [WORKER_OFFICE]                           VARCHAR (200) NULL,
    [CD_WORKER_OFFICE]                        INT           NULL,
    [WORKER_UNIT]                             NVARCHAR (10) NULL,
    [COUNTY]                                  VARCHAR (200) NULL,
    [INTAKE_ZIP]                              NVARCHAR (10) NULL,
    [IA_WRKR_ID]                              NVARCHAR (50) NULL,
    [IA_REGION]                               VARCHAR (200) NULL,
    [IA_OFFICE]                               VARCHAR (200) NULL,
    [IA_UNIT]                                 NVARCHAR (10) NULL,
    [CHILDREN]                                INT           NULL,
    [REFRESH_DT]                              DATETIME      NULL,
    [dv_threat_intake]                        VARCHAR (3)   NULL,
    [FL_DEATH_SERIOUS_INJURY]                 VARCHAR (1)   NULL,
    [FL_NEAR_DEATH_INJURY]                    VARCHAR (1)   NULL,
    [FIRST_WORKER]                            INT           NULL,
    [FIRST_WORKER_REGION]                     VARCHAR (200) NULL,
    [FIRST_WORKER_CD_REGION]                  INT           NULL,
    [FIRST_WORKER_OFFICE]                     VARCHAR (200) NULL,
    [FIRST_WORKER_CD_OFFICE]                  INT           NULL,
    [FIRST_WORKER_UNIT]                       NVARCHAR (10) NULL,
    [FIRST_WORKER_TOWN]                       VARCHAR (200) NULL,
    [FIRST_WORKER_CD_TOWN]                    NVARCHAR (50) NULL,
    [FIRST_WORKER_CNTY]                       VARCHAR (200) NULL,
    [FIRST_WORKER_CD_CNTY]                    INT           NULL,
    [FIRST_WORKER_Type]                       VARCHAR (50)  NULL,
    [Month_DT_ACCESS_RCVD]                    VARCHAR (200) NULL,
    [Quarter_DT_ACCESS_RCVD]                  VARCHAR (200) NULL,
    [Quarter_Name_DT_ACCESS_RCVD]             VARCHAR (200) NULL,
    [INTAKE_WORKER]                           VARCHAR (50)  NULL,
    [INTAKE_AA]                               VARCHAR (50)  NULL,
    [INTAKE_SUP]                              VARCHAR (50)  NULL,
    [CD_INTAKE_TYPE_DERIVED]                  VARCHAR (50)  NULL,
    [TX_INTAKE_TYPE_DERIVED]                  VARCHAR (50)  NULL,
    [ID_INVS]                                 INT           NULL,
    [ID_FACP]                                 INT           NULL,
    [CD_INTAKE_VERSION]                       VARCHAR (50)  NULL,
    CONSTRAINT [PK_rptIntakes_CA] PRIMARY KEY CLUSTERED ([ID_ACCESS_REPORT] ASC)
);
