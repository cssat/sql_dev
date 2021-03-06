﻿CREATE TABLE [dbo].[RELATIONSHIP_DIM] (
    [ID_RELATIONSHIP_DIM] INT           NOT NULL,
    [CD_RLTNSHP_VCTM]     INT           NULL,
    [TX_RLTNSHP_VCTM]     VARCHAR (200) NULL,
    [CD_TPR_RELATIONSHIP] INT           NULL,
    [TX_TPR_RELATIONSHIP] VARCHAR (200) NULL,
    [DT_ROW_BEGIN]        DATETIME      NULL,
    [DT_ROW_END]          DATETIME      NULL,
    [ID_CYCLE]            INT           NULL,
    [IS_CURRENT]          INT           NULL,
    CONSTRAINT [pk_ID_RELATIONSHIP_DIM] PRIMARY KEY CLUSTERED ([ID_RELATIONSHIP_DIM] ASC)
);

