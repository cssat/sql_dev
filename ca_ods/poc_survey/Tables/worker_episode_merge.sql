﻿CREATE TABLE [poc_survey].[worker_episode_merge] (
    [RespondentID]                    FLOAT (53)   NULL,
    [surveyed]                        FLOAT (53)   NULL,
    [PRSN_ID]                         FLOAT (53)   NULL,
    [plcmt_id]                        FLOAT (53)   NULL,
    [exact_episode_begin_date_match]  VARCHAR (30) NULL,
    [removal_begin_dt_used_for_match] DATETIME     NULL,
    [next_removal_begin_date]         DATETIME     NULL,
    [reentered]                       FLOAT (53)   NULL,
    [PrimaryLast]                     FLOAT (53)   NULL,
    [worker_count]                    FLOAT (53)   NULL,
    [p_outcom]                        FLOAT (53)   NULL,
    [rg]                              FLOAT (53)   NULL,
    [w_start]                         DATETIME     NULL,
    [w_end]                           DATETIME     NULL,
    [w_end_new]                       DATETIME     NULL,
    [w_end_final]                     DATETIME     NULL,
    [p_date]                          DATETIME     NULL,
    [p_epend]                         DATETIME     NULL,
    [epend_sub]                       DATETIME     NULL,
    [end]                             FLOAT (53)   NULL,
    [prior]                           FLOAT (53)   NULL,
    [Region]                          VARCHAR (1)  NULL,
    [office]                          FLOAT (53)   NULL,
    [ive_tribe]                       FLOAT (53)   NULL,
    [plcmntyp]                        FLOAT (53)   NULL,
    [los]                             FLOAT (53)   NULL,
    [Gender]                          VARCHAR (1)  NULL,
    [DOB]                             DATETIME     NULL,
    [age_at_p]                        FLOAT (53)   NULL,
    [Hispanic]                        FLOAT (53)   NULL,
    [singlrac]                        FLOAT (53)   NULL,
    [aframany]                        FLOAT (53)   NULL,
    [natamany]                        FLOAT (53)   NULL,
    [program_type]                    FLOAT (53)   NULL,
    [program_type_min]                FLOAT (53)   NULL,
    [worker_los]                      FLOAT (53)   NULL,
    [q1a]                             FLOAT (53)   NULL,
    [q1b]                             FLOAT (53)   NULL,
    [q1c]                             FLOAT (53)   NULL,
    [q1d]                             FLOAT (53)   NULL,
    [q1e]                             FLOAT (53)   NULL,
    [q1f]                             FLOAT (53)   NULL,
    [q1g]                             FLOAT (53)   NULL,
    [q1h]                             FLOAT (53)   NULL,
    [q11a]                            FLOAT (53)   NULL,
    [q11b]                            FLOAT (53)   NULL,
    [R_q11b]                          FLOAT (53)   NULL,
    [D_BA]                            FLOAT (53)   NULL,
    [D_MA_MSW_Plus]                   FLOAT (53)   NULL,
    [D_Ed2]                           FLOAT (53)   NULL,
    [D_Ed3]                           FLOAT (53)   NULL,
    [D_Ed4]                           FLOAT (53)   NULL,
    [D_Ed5]                           FLOAT (53)   NULL,
    [D_Ed6]                           FLOAT (53)   NULL,
    [D_Ed7]                           FLOAT (53)   NULL,
    [q11c]                            FLOAT (53)   NULL,
    [q11d]                            FLOAT (53)   NULL,
    [q11e_years]                      FLOAT (53)   NULL,
    [q11e_months]                     FLOAT (53)   NULL,
    [Months_in_position]              FLOAT (53)   NULL,
    [Years_position]                  FLOAT (53)   NULL,
    [Tenure_Cat]                      FLOAT (53)   NULL,
    [q11f]                            FLOAT (53)   NULL,
    [Age_Cat]                         FLOAT (53)   NULL,
    [q11ga]                           FLOAT (53)   NULL,
    [q11gb]                           FLOAT (53)   NULL,
    [q11gc]                           FLOAT (53)   NULL,
    [q11gd]                           FLOAT (53)   NULL,
    [q11ge]                           FLOAT (53)   NULL,
    [q11gf]                           FLOAT (53)   NULL,
    [RaceCaucasian]                   FLOAT (53)   NULL,
    [RaceAA]                          FLOAT (53)   NULL,
    [RaceAI]                          FLOAT (53)   NULL,
    [RaceAA_PI]                       FLOAT (53)   NULL,
    [RaceHispanic]                    FLOAT (53)   NULL,
    [RaceOther_Mixed_Multiple]        FLOAT (53)   NULL,
    [Part1_Approach_Scale]            FLOAT (53)   NULL,
    [Office_Mean_Part1AppScale]       FLOAT (53)   NULL,
    [Scale1]                          FLOAT (53)   NULL,
    [Scale2]                          FLOAT (53)   NULL,
    [RScale2]                         FLOAT (53)   NULL,
    [Scale3]                          FLOAT (53)   NULL,
    [Scale4]                          FLOAT (53)   NULL,
    [Scale5]                          FLOAT (53)   NULL,
    [RScale5]                         FLOAT (53)   NULL,
    [Scale6]                          FLOAT (53)   NULL,
    [RScale6]                         FLOAT (53)   NULL,
    [Scale7]                          FLOAT (53)   NULL,
    [RScale7]                         FLOAT (53)   NULL,
    [Scale8]                          FLOAT (53)   NULL,
    [RScale8]                         FLOAT (53)   NULL,
    [Scale9]                          FLOAT (53)   NULL,
    [RScale9]                         FLOAT (53)   NULL,
    [Scale10]                         FLOAT (53)   NULL,
    [RScale10]                        FLOAT (53)   NULL,
    [Scale11]                         FLOAT (53)   NULL,
    [Scale12]                         FLOAT (53)   NULL,
    [Scale13]                         FLOAT (53)   NULL,
    [Scale14]                         FLOAT (53)   NULL,
    [Scale15]                         FLOAT (53)   NULL,
    [Scale16]                         FLOAT (53)   NULL,
    [Scale17]                         FLOAT (53)   NULL,
    [Scale18]                         FLOAT (53)   NULL,
    [Scale19]                         FLOAT (53)   NULL,
    [Scale20]                         FLOAT (53)   NULL,
    [RScale20]                        FLOAT (53)   NULL,
    [Scale21]                         FLOAT (53)   NULL,
    [RScale21]                        FLOAT (53)   NULL,
    [Scale22]                         FLOAT (53)   NULL,
    [RScale23]                        FLOAT (53)   NULL,
    [Scale24]                         FLOAT (53)   NULL,
    [Scale25]                         FLOAT (53)   NULL,
    [Scale26]                         FLOAT (53)   NULL,
    [Scale27]                         FLOAT (53)   NULL,
    [Scale28]                         FLOAT (53)   NULL,
    [Scale29]                         FLOAT (53)   NULL,
    [Scale30]                         FLOAT (53)   NULL,
    [CA_AREA]                         FLOAT (53)   NULL,
    [Recode_CA_Area_FVS]              FLOAT (53)   NULL,
    [Recode_CA_Area_CFWS]             FLOAT (53)   NULL,
    [Recode_CA_Area_FRS]              FLOAT (53)   NULL,
    [Recode_CA_Area_CPS]              FLOAT (53)   NULL,
    [Recode_CA_Area_Multiple]         FLOAT (53)   NULL,
    [IMP_pt1Scale1PercepSupSupp1]     FLOAT (53)   NULL,
    [IMP_pt1Scale2ObNewApp]           FLOAT (53)   NULL,
    [IMP_Rpt1Scale2ObNewApp]          FLOAT (53)   NULL,
    [IMP_pt1Scale3IncluFam]           FLOAT (53)   NULL,
    [IMP_pt1Scale4FamAssessProc]      FLOAT (53)   NULL,
    [IMP_pt1Scale5OrgChar]            FLOAT (53)   NULL,
    [IMP_Rpt1Scale5OrgChar]           FLOAT (53)   NULL,
    [IMP_pt1Scale6SerChar]            FLOAT (53)   NULL,
    [IMP_Rpt1Scale6SerChar]           FLOAT (53)   NULL,
    [IMP_pt1Scale7FosChar]            FLOAT (53)   NULL,
    [IMP_Rpt1Scale7FosChar]           FLOAT (53)   NULL,
    [IMP_pt1Scale8CourtChar]          FLOAT (53)   NULL,
    [IMP_Rpt1Scale8CourtChar]         FLOAT (53)   NULL,
    [IMP_pt1Scale9QuanDem]            FLOAT (53)   NULL,
    [IMP_Rpt1Scale9QuanDem]           FLOAT (53)   NULL,
    [IMP_pt1Scale10LearnDem]          FLOAT (53)   NULL,
    [IMP_Rpt1Scale10LearnDem]         FLOAT (53)   NULL,
    [IMP_pt1Scale11RoleClar]          FLOAT (53)   NULL,
    [IMP_pt1Scale12PosChall]          FLOAT (53)   NULL,
    [IMP_pt1Scale13SupportSuper]      FLOAT (53)   NULL,
    [IMP_pt1Scale14EmpowLead]         FLOAT (53)   NULL,
    [IMP_pt1Scale15TeamPsySafe]       FLOAT (53)   NULL,
    [IMP_pt1Scale16TeamClim]          FLOAT (53)   NULL,
    [IMP_pt1Scale17SocClim]           FLOAT (53)   NULL,
    [IMP_pt1Scale18PercepGroupWork]   FLOAT (53)   NULL,
    [IMP_pt1Scale19HRPrim]            FLOAT (53)   NULL,
    [IMP_pt1Scale20EmotExh]           FLOAT (53)   NULL,
    [IMP_Rpt1Scale20EmotExh]          FLOAT (53)   NULL,
    [IMP_pt1Scale21Deper]             FLOAT (53)   NULL,
    [IMP_Rpt1Scale21Deper]            FLOAT (53)   NULL,
    [IMP_pt1Scale22PersAccomp]        FLOAT (53)   NULL,
    [IMP_pt1Scale24TurnoverIntent]    FLOAT (53)   NULL,
    [IMP_q6yExpViol]                  FLOAT (53)   NULL,
    [IMP_Rq11a]                       FLOAT (53)   NULL,
    [IMP_D_Ed2]                       FLOAT (53)   NULL,
    [IMP_D_Ed3]                       FLOAT (53)   NULL,
    [IMP_D_Ed4]                       FLOAT (53)   NULL,
    [IMP_D_Ed5]                       FLOAT (53)   NULL,
    [IMP_D_Ed6]                       FLOAT (53)   NULL,
    [IMP_D_Ed7]                       FLOAT (53)   NULL,
    [IMP_D_MA_MSW_Plus]               FLOAT (53)   NULL,
    [IMP_years_position]              FLOAT (53)   NULL,
    [IMP_q11f]                        FLOAT (53)   NULL,
    [worker_los2]                     FLOAT (53)   NULL,
    [worker_count_max]                FLOAT (53)   NULL,
    [rmvsexab]                        FLOAT (53)   NULL,
    [rmvphyab]                        FLOAT (53)   NULL,
    [rmvnegl]                         FLOAT (53)   NULL,
    [rmvalabp]                        FLOAT (53)   NULL,
    [rmvdrabp]                        FLOAT (53)   NULL,
    [rmvalabc]                        FLOAT (53)   NULL,
    [rmvdrabc]                        FLOAT (53)   NULL,
    [rmvddc]                          FLOAT (53)   NULL,
    [rmvbvprc]                        FLOAT (53)   NULL,
    [rmvdeath]                        FLOAT (53)   NULL,
    [rmvjail]                         FLOAT (53)   NULL,
    [rmvddp]                          FLOAT (53)   NULL,
    [rmvaband]                        FLOAT (53)   NULL,
    [rmvihous]                        FLOAT (53)   NULL,
    [rmvmajab]                        FLOAT (53)   NULL,
    [rmvcan]                          FLOAT (53)   NULL,
    [rmvpsa]                          FLOAT (53)   NULL,
    [rmvcsa]                          FLOAT (53)   NULL,
    [q3r]                             FLOAT (53)   NULL,
    [RRq3r]                           FLOAT (53)   NULL,
    [q3s]                             FLOAT (53)   NULL,
    [new_los]                         FLOAT (53)   NULL,
    [PrimaryLast_ValidAssign]         FLOAT (53)   NULL,
    [PrimaryLast1]                    FLOAT (53)   NULL,
    [PrimaryLast2]                    FLOAT (53)   NULL,
    [imp_approach]                    FLOAT (53)   NULL,
    [imp_exhaust]                     FLOAT (53)   NULL,
    [imp_supsupport]                  FLOAT (53)   NULL,
    [RRq3b]                           FLOAT (53)   NULL,
    [RRq3c]                           FLOAT (53)   NULL,
    [q3e]                             FLOAT (53)   NULL,
    [q3f]                             FLOAT (53)   NULL,
    [q3h]                             FLOAT (53)   NULL,
    [q3d]                             FLOAT (53)   NULL,
    [q3l]                             FLOAT (53)   NULL,
    [q10a]                            FLOAT (53)   NULL,
    [q10c]                            FLOAT (53)   NULL,
    [q10e]                            FLOAT (53)   NULL,
    [q10h]                            FLOAT (53)   NULL,
    [q10i]                            FLOAT (53)   NULL,
    [imp_approach2]                   FLOAT (53)   NULL,
    [q3m]                             FLOAT (53)   NULL,
    [q3n]                             FLOAT (53)   NULL
);

