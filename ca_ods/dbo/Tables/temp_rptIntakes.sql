﻿CREATE TABLE [dbo].[temp_rptIntakes] (
    [TableKey]                 NVARCHAR (50)  NULL,
    [ID_ACCESS_REPORT]         NVARCHAR (50)  NULL,
    [DT_ACCESS_RCVD]           NVARCHAR (50)  NULL,
    [YEAR]                     NVARCHAR (50)  NULL,
    [YEAR_NAME]                NVARCHAR (50)  NULL,
    [MONTH_NAME]               NVARCHAR (50)  NULL,
    [STATE_FISCAL_YEAR_NAME]   NVARCHAR (50)  NULL,
    [FEDERAL_FISCAL_YEAR_NAME] NVARCHAR (50)  NULL,
    [CPS_YESNO]                NVARCHAR (50)  NULL,
    [INTAKE_TYPE]              NVARCHAR (50)  NULL,
    [CD_NON_CPS]               NVARCHAR (50)  NULL,
    [SCREEN_DCSN]              NVARCHAR (50)  NULL,
    [CD_REASON]                NVARCHAR (50)  NULL,
    [REASON]                   NVARCHAR (50)  NULL,
    [RESPONSE_TIME]            NVARCHAR (50)  NULL,
    [MAJOR_CAN]                NVARCHAR (50)  NULL,
    [PHYSICAL_ABUSE]           NVARCHAR (50)  NULL,
    [SEXUAL_ABUSE]             NVARCHAR (50)  NULL,
    [NEGLECT]                  NVARCHAR (50)  NULL,
    [SEXUAL_EXPLOIT]           NVARCHAR (50)  NULL,
    [ABANDONED]                NVARCHAR (50)  NULL,
    [OTHER]                    NVARCHAR (50)  NULL,
    [ID_CASE]                  NVARCHAR (50)  NULL,
    [ID_PRVD_ORG_INTAKE]       NVARCHAR (50)  NULL,
    [REGION]                   NVARCHAR (50)  NULL,
    [CD_REGION]                NVARCHAR (50)  NULL,
    [INTAKE_REGION]            NVARCHAR (50)  NULL,
    [CD_INTAKE_REGION]         NVARCHAR (50)  NULL,
    [INTAKE_OFFICE]            NVARCHAR (50)  NULL,
    [CD_INTAKE_OFFICE]         NVARCHAR (50)  NULL,
    [INTAKE_UNIT]              NVARCHAR (50)  NULL,
    [CASE_REGION]              NVARCHAR (50)  NULL,
    [CD_CASE_REGION]           NVARCHAR (50)  NULL,
    [CASE_OFFICE]              NVARCHAR (50)  NULL,
    [CD_CASE_OFFICE]           NVARCHAR (50)  NULL,
    [PRIMARY_WRKR]             NVARCHAR (50)  NULL,
    [WRKR_REGION]              NVARCHAR (50)  NULL,
    [CD_WRKR_REGION]           NVARCHAR (50)  NULL,
    [WORKER_OFFICE]            NVARCHAR (50)  NULL,
    [CD_WORKER_OFFICE]         NVARCHAR (50)  NULL,
    [WORKER_UNIT]              NVARCHAR (50)  NULL,
    [COUNTY]                   NVARCHAR (50)  NULL,
    [INTAKE_ZIP]               NVARCHAR (50)  NULL,
    [IA_WRKR_ID]               NVARCHAR (50)  NULL,
    [IA_REGION]                NVARCHAR (50)  NULL,
    [IA_OFFICE]                NVARCHAR (50)  NULL,
    [IA_UNIT]                  NVARCHAR (50)  NULL,
    [CHILDREN]                 NVARCHAR (50)  NULL,
    [REFRESH_DT]               NVARCHAR (50)  NULL,
    [dv_threat_intake]         NVARCHAR (50)  NULL,
    [FL_DEATH_SERIOUS_INJURY]  NVARCHAR (50)  NULL,
    [FL_NEAR_DEATH_INJURY]     NVARCHAR (50)  NULL,
    [FIRST_WORKER]             NVARCHAR (50)  NULL,
    [FIRST_WORKER_REGION]      NVARCHAR (50)  NULL,
    [FIRST_WORKER_CD_REGION]   NVARCHAR (50)  NULL,
    [FIRST_WORKER_OFFICE]      NVARCHAR (50)  NULL,
    [FIRST_WORKER_CD_OFFICE]   NVARCHAR (50)  NULL,
    [FIRST_WORKER_UNIT]        NVARCHAR (50)  NULL,
    [FIRST_WORKER_TOWN]        NVARCHAR (50)  NULL,
    [FIRST_WORKER_CD_TOWN]     NVARCHAR (50)  NULL,
    [FIRST_WORKER_CNTY]        NVARCHAR (50)  NULL,
    [FIRST_WORKER_CD_CNTY]     NVARCHAR (50)  NULL,
    [FIRST_WORKER_Type]        NVARCHAR (50)  NULL,
    [Month]                    NVARCHAR (50)  NULL,
    [Quarter]                  NVARCHAR (50)  NULL,
    [Quarter_Name]             NVARCHAR (50)  NULL,
    [INTAKE_WORKER]            NVARCHAR (50)  NULL,
    [INTAKE_AA]                NVARCHAR (50)  NULL,
    [INTAKE_SUP]               NVARCHAR (50)  NULL,
    [CD_INTAKE_TYPE_DERIVED]   NVARCHAR (50)  NULL,
    [TX_INTAKE_TYPE_DERIVED]   NVARCHAR (200) NULL,
    [ID_INVS]                  NVARCHAR (50)  NULL,
    [ID_FACP]                  NVARCHAR (50)  NULL,
    [CD_INTAKE_VERSION]        NVARCHAR (50)  NULL
);

