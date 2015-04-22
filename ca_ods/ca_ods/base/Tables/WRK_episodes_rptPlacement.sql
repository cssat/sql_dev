CREATE TABLE [base].[WRK_episodes_rptPlacement] (
    [id_removal_episode_fact]     INT      NOT NULL,
    [child]                       INT      NOT NULL,
    [id_intake_fact]              INT      NULL,
    [id_case_tce]                 INT      NULL,
    [inv_ass_start]               DATETIME NULL,
    [inv_ass_stop]                DATETIME NULL,
    [removal_dt]                  DATETIME NOT NULL,
    [discharge_dt]                DATETIME NULL,
    [id_case_si]                  INT      NULL,
    [update_from_intakes_si]      INT      NOT NULL,
    [update_from_sibling]         INT      NOT NULL,
    [update_from_vctm_fact]       INT      NOT NULL,
    [update_from_tce_xwalk]       INT      NOT NULL,
    [update_from_intk_part_vctm]  INT      NOT NULL,
    [update_from_algtn_vctm_ars]  INT      NOT NULL,
    [update_from_tce_xwalk_ars]   INT      NOT NULL,
    [update_from_si_intk_reopn]   INT      NOT NULL,
    [update_from_tce_xwalk_reopn] INT      NOT NULL,
    [row_num]                     BIGINT   NULL
);

