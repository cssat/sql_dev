CREATE TABLE [ref].[zip_school_xwalk_usa] (
    [MX_ID]                VARCHAR (255) NULL,
    [NCES_DISID]           VARCHAR (255) NULL,
    [NCES_SCHID]           VARCHAR (255) NULL,
    [SCH_NAME]             VARCHAR (255) NULL,
    [totPopSZ]             REAL          NULL,
    [totHUnitsSZ]          REAL          NULL,
    [SchoolZoneArea]       REAL          NULL,
    [Zipcode]              INT           NULL,
    [pctSchoolZoneInZip]   REAL          NULL,
    [pctZipInSchoolZone]   REAL          NULL,
    [weightByLandArea]     REAL          NULL,
    [weightByPopulation]   REAL          NULL,
    [weightByHousingUnits] REAL          NULL
);

