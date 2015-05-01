﻿CREATE TABLE [camis].[dcfref] (
    [DCFREF_ID]                   FLOAT (53)   NOT NULL,
    [DCFREF_RECV_DATE]            DATETIME     NULL,
    [DCFREF_RECV_TIME]            FLOAT (53)   NULL,
    [DCFREF_PROG_TYPE_CODE]       VARCHAR (1)  NULL,
    [DCFREF_DECN_CODE]            VARCHAR (1)  NULL,
    [DCFREF_DECN_DATE]            DATETIME     NULL,
    [CPSREF_INCDNT_DATE]          DATETIME     NULL,
    [DCFREF_RFRNT_TYPE_CODE]      INT          NULL,
    [DCFREF_MODE_CODE]            VARCHAR (1)  NULL,
    [CPSREF_RFRNT_INFO_SRC_CODE]  VARCHAR (1)  NULL,
    [DCFREF_PRMRY_CITY_NAME]      VARCHAR (20) NULL,
    [CPSRA_NUM_CODE]              FLOAT (53)   NULL,
    [DCFREF_INVSTN_STD_CODE]      VARCHAR (1)  NULL,
    [DCFREF_RESP_TIME_CODE]       VARCHAR (1)  NULL,
    [DCFREF_PRMRY_ST_CODE]        VARCHAR (2)  NULL,
    [DCFREF_PRMRY_ZIP_CODE]       VARCHAR (9)  NULL,
    [dcfref_prmry_cnty_code_num]  FLOAT (53)   NULL,
    [DCFREF_INCDNT_CITY_NAME]     VARCHAR (20) NULL,
    [DCFREF_INCDNT_ST_CODE]       VARCHAR (2)  NULL,
    [DCFREF_INCDNT_ZIP_CODE]      VARCHAR (9)  NULL,
    [dcfref_incdnt_cnty_code_num] FLOAT (53)   NULL,
    [SSPS_SPRVSR_RPT_UNIT_NUM]    FLOAT (53)   NULL,
    [LIC_ISSUES_FLG]              VARCHAR (1)  NULL,
    [BUS_ID]                      FLOAT (53)   NULL,
    [DCFREF_FATAL_FLG]            VARCHAR (1)  NULL,
    [DCFREF_CHLD_FATAL_FLG]       VARCHAR (1)  NULL,
    [DCFREF_RUNAWAY_CODE]         VARCHAR (1)  NULL,
    [DCFREF_CHLD_INJ_FLG]         VARCHAR (1)  NULL,
    [PRICAR_PRSN_ID]              FLOAT (53)   NULL,
    [SSPS_WRKR_RPT_UNIT_NUM]      FLOAT (53)   NULL,
    [DCFREF_IMNT_DNGR_FLG]        VARCHAR (1)  NULL,
    [SSPS_WRKR_REGION]            FLOAT (53)   NULL,
    [INTAKE_WRKR_RPT_UNIT_NUM]    FLOAT (53)   NULL,
    [DCFREF_PRMRY_CNTY_CODE]      VARCHAR (15) NULL,
    [DCFREF_INCDNT_CNTY_CODE]     VARCHAR (15) NULL,
    PRIMARY KEY CLUSTERED ([DCFREF_ID] ASC)
);

