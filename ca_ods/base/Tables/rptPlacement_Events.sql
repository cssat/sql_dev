CREATE TABLE [base].[rptPlacement_Events] (
    [row_id]                       INT           NOT NULL,
    [id_removal_episode_fact]      INT           NULL,
    [rmvl_seq]                     INT           NULL,
    [child]                        INT           NOT NULL,
    [birthdate]                    DATETIME      NULL,
    [tx_gndr]                      VARCHAR (200) NULL,
    [18bday]                       DATETIME      NULL,
    [tx_braam_race]                VARCHAR (200) NULL,
    [tx_multirace]                 VARCHAR (200) NULL,
    [id_case]                      INT           NULL,
    [tx_region]                    VARCHAR (200) NULL,
    [worker_region]                VARCHAR (200) NULL,
    [worker_office]                VARCHAR (200) NULL,
    [worker_unit]                  VARCHAR (200) NULL,
    [episode_los]                  INT           NULL,
    [episode_los_grp]              VARCHAR (200) NULL,
    [removal_dt]                   DATETIME      NULL,
    [removal_year]                 DATETIME      NULL,
    [removal_sfy_name]             VARCHAR (200) NULL,
    [removal_cy_name]              VARCHAR (200) NULL,
    [discharge_dt]                 DATETIME      NULL,
    [discharge_year]               DATETIME      NULL,
    [discharge_sfy_name]           VARCHAR (200) NULL,
    [discharge_cy_name]            VARCHAR (200) NULL,
    [exit_reason]                  VARCHAR (200) NULL,
    [last_pca]                     VARCHAR (200) NULL,
    [last_lgl_stat]                VARCHAR (200) NULL,
    [id_epsd]                      INT           NOT NULL,
    [id_prvd_org_caregiver]        INT           NULL,
    [id_bsns]                      INT           NULL,
    [tx_provider_type]             VARCHAR (200) NULL,
    [current_prvd_status]          VARCHAR (200) NULL,
    [id_ssps]                      INT           NULL,
    [id_calendar_dim_begin]        INT           NULL,
    [id_calendar_dim_end]          INT           NULL,
    [age_plcm_begin]               INT           NULL,
    [begin_date]                   DATETIME      NOT NULL,
    [begin_year]                   DATETIME      NULL,
    [begin_year_name]              VARCHAR (200) NULL,
    [begin_state_fiscal_year_name] VARCHAR (200) NULL,
    [begin_month]                  DATETIME      NULL,
    [begin_month_name]             VARCHAR (200) NULL,
    [end_date]                     DATETIME      NULL,
    [end_year]                     DATETIME      NULL,
    [end_year_name]                VARCHAR (200) NULL,
    [end_state_fiscal_year_name]   VARCHAR (200) NULL,
    [end_month]                    DATETIME      NULL,
    [end_month_name]               VARCHAR (200) NULL,
    [age_plcm_end]                 INT           NULL,
    [plcmnt_days]                  INT           NULL,
    [tx_plcm_setng]                VARCHAR (200) NULL,
    [tx_srvc]                      VARCHAR (200) NULL,
    [tx_srvc_ctgry]                VARCHAR (200) NULL,
    [tx_subctgry]                  VARCHAR (200) NULL,
    [tx_end_rsn]                   VARCHAR (200) NULL,
    [plcmnt_type]                  VARCHAR (200) NULL,
    [post_brs]                     INT           NULL,
    [brs_id]                       INT           NULL,
    [brs_nm]                       VARCHAR (200) NULL,
    [brs_bsns]                     VARCHAR (200) NULL,
    [brs_srvc]                     VARCHAR (200) NULL,
    [brs_srvc_ctgry]               VARCHAR (200) NULL,
    [brs_subctgry]                 VARCHAR (200) NULL,
    [brs_plcm_setng]               VARCHAR (200) NULL,
    [brs_plcmnt_days]              INT           NULL,
    [days_from_rmvl]               INT           NULL,
    [days_to_dsch]                 INT           NULL,
    [plcmnt_seq]                   INT           NULL,
    [days_to_dsch_grp]             VARCHAR (200) NULL,
    [days_from_rmvl_grp]           VARCHAR (200) NULL,
    [cd_plcm_setng]                INT           NULL,
    [rundate]                      DATETIME      NULL,
    [primary_plan]                 VARCHAR (200) NULL,
    [alt_plan]                     VARCHAR (200) NULL,
    [id_placement_fact]            INT           NULL,
    [cd_srvc]                      INT           NULL,
    [id_plcmnt_evnt]               INT           NULL,
    [cd_plcmnt_evnt]               CHAR (3)      NULL,
    [prtl_cd_plcm_setng]           INT           NULL,
    [cd_epsd_type]                 INT           NULL,
    [cd_end_rsn]                   INT           NULL,
    [derived_county]               INT           NULL,
    [id_provider_dim_caregiver]    INT           NULL, 
    [tx_multi_race_ethnicity]      VARCHAR(200)  NULL, 
    [cd_multi_race_ethnicity]      INT           NULL, 
    [removal_qtr]                  DATETIME      NULL, 
    [discharge_qtr]                DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_id_removal_episode_fact_begin_Date_incl_cnty]
    ON [base].[rptPlacement_Events]([id_removal_episode_fact] ASC, [begin_date] ASC)
    INCLUDE([id_placement_fact], [derived_county]);


GO
CREATE NONCLUSTERED INDEX [id_removal_episode_fact_id_placement_fact_Incl_begin_date_end_date]
    ON [base].[rptPlacement_Events]([id_removal_episode_fact] ASC, [id_placement_fact] ASC, [begin_date] ASC)
    INCLUDE([end_date]);


GO
CREATE NONCLUSTERED INDEX [idx_poc1ab_1]
    ON [base].[rptPlacement_Events]([id_removal_episode_fact] ASC, [begin_date] ASC, [end_date] ASC)
    INCLUDE([id_placement_fact], [derived_county]);


GO
CREATE NONCLUSTERED INDEX [idx_poc1ab_2]
    ON [base].[rptPlacement_Events]([id_placement_fact] ASC)
    INCLUDE([derived_county]);


GO
CREATE NONCLUSTERED INDEX [idx_BGDKSO2]
    ON [base].[rptPlacement_Events]([id_removal_episode_fact] ASC)
    INCLUDE([id_calendar_dim_end], [begin_date], [end_date], [tx_plcm_setng], [cd_plcm_setng], [id_placement_fact], [id_plcmnt_evnt], [cd_plcmnt_evnt], [id_provider_dim_caregiver]);


GO
CREATE NONCLUSTERED INDEX [idx_id_removal_episode_fact_incl_6]
    ON [base].[rptPlacement_Events]([id_removal_episode_fact] ASC)
    INCLUDE([begin_date], [end_date], [tx_plcm_setng], [cd_plcm_setng], [id_plcmnt_evnt], [cd_plcmnt_evnt], [id_provider_dim_caregiver]);


GO
CREATE NONCLUSTERED INDEX [idx_child_id_epsd_begin_date]
    ON [base].[rptPlacement_Events]([child] ASC, [id_epsd] ASC, [begin_date] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_for_trh_rptPlacement_Events]
    ON [base].[rptPlacement_Events]([cd_epsd_type] ASC, [id_prvd_org_caregiver] ASC)
    INCLUDE([id_removal_episode_fact], [id_case], [begin_date], [end_date], [tx_end_rsn], [id_placement_fact], [cd_end_rsn]);


GO
CREATE NONCLUSTERED INDEX [idx_cd_end_rsn_rptPlacement_Events]
    ON [base].[rptPlacement_Events]([cd_end_rsn] ASC)
    INCLUDE([id_removal_episode_fact], [birthdate], [removal_dt], [discharge_dt], [id_placement_fact]);

