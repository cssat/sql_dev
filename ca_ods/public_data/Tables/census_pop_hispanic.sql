CREATE TABLE [public_data].[census_pop_hispanic] (
    [source_year]                      INT          NULL,
    [county_cd]                        INT          NOT NULL,
    [pk_gndr]                          INT          NOT NULL,
    [census_hispanic_latino_origin_cd] INT          NOT NULL,
    [age_grouping_cd]                  INT          NOT NULL,
    [measurement_year]                 INT          NULL,
    [pop_cnt]                          VARCHAR (50) NULL
);

