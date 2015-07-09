CREATE TABLE [prtl].[ia_trends]
(
    [qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATE NOT NULL, 
    [start_year] INT NOT NULL, 
    [cd_reporter_type] INT NOT NULL, 
    [filter_access_type] INT NOT NULL, 
    [filter_allegation] INT NOT NULL, 
    [filter_finding] INT NOT NULL, 
    [cd_sib_age_group] INT NULL, 
    [cd_race_census] INT NULL, 
    [census_hispanic_latino_origin_cd] INT NOT NULL, 
    [county_cd] INT NOT NULL, 
    [cnt_start_date] INT NULL, 
    [cnt_opened] INT NULL, 
    [cnt_closed] INT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends] 
    ON [prtl].[ia_trends] ([qry_type], [date_type], [start_date])
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_param_sets_ia] 
    ON [prtl].[ia_trends] ([cd_reporter_type], [filter_access_type], [filter_allegation], [filter_finding])
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_param_sets_demog] 
    ON [prtl].[ia_trends] ([cd_sib_age_group], [cd_race_census])
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_param_sets_geog] 
    ON [prtl].[ia_trends] ([county_cd])
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_aggr_insert]
	ON [prtl].[ia_trends] ([cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[start_date])
INCLUDE ([qry_type],[cd_sib_age_group],[cd_race_census],[county_cd],[cnt_start_date],[cnt_opened],[cnt_closed])
GO
