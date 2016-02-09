﻿CREATE TABLE [annual_report].[ca_afcars_source_data] (
	[recnumbr] INT NULL
	,[fipscode] INT NULL
	,[county_cd] TINYINT NULL
	,[county_desc] VARCHAR(14) NULL
	,[region_cd] TINYINT NULL
	,[region_6_cd] TINYINT NULL
	,[region_6_tx] VARCHAR(18) NULL
	,[dob] DATE NULL
	,[sex] TINYINT NULL
	,[amiakn] TINYINT NULL
	,[asian] TINYINT NULL
	,[blkafram] TINYINT NULL
	,[hawaiipi] TINYINT NULL
	,[white] TINYINT NULL
	,[untodetm] TINYINT NULL
	,[hisorgin] TINYINT NULL
	,[raceeth] TINYINT NULL
	,[totalrem] TINYINT NULL
	,[rem1dt] DATE NULL
	,[dlstfcdt] DATE NULL
	,[latremdt] DATE NULL
	,[cursetdt] DATE NULL
	,[dodfcdt] DATE NULL
	,[tprmomdt] DATE NULL
	,[tprdaddt] DATE NULL
	,[numplep] TINYINT NULL
	,[curplset] TINYINT NULL
	,[childid] INT NULL
	,[repdat] INT NULL
	,[dtreportbeg] DATE NULL
	,[dtreportend] DATE NULL
	,[dtreportendfinal] DATE NULL
	,[dtreportbeg1] DATE NULL
	,[next6moreport] DATE NULL
	,[timebetweenreports] INT NULL
	,[dq_dropped] TINYINT NULL
	,[dq_idnomatchnext6mo] TINYINT NULL
	,[dq_missdob] TINYINT NULL
	,[dq_missdtlatremdt] TINYINT NULL
	,[dq_missnumplep] TINYINT NULL
	,[dq_dobgtlatremdt] TINYINT NULL
	,[dq_dobgtdodfcdt] TINYINT NULL
	,[dq_gt21dobtodtlatrem] TINYINT NULL
	,[dq_gt21dobtodtdisch] TINYINT NULL
	,[dq_gt21dtdischtodtlatrem] TINYINT NULL
	,[dq_dodfcdteqletremdt] TINYINT NULL
	,[dq_dodfcdtltletremdt] TINYINT NULL
	,[dq_missdisreasn] TINYINT NULL
	,[dq_totalrem1] TINYINT NULL
	,[entryyr] INT NULL
	,[exityr] INT NULL
	,[agenmos] TINYINT NULL
	,[agenmosyrscat] TINYINT NULL
	,[agenyears] TINYINT NULL
	,[agenmosyrs] INT NULL
	,[agexmos] INT NULL
	,[agexmosyrscat] INT NULL
	,[agexyrs] INT NULL
	,[agexmosyrs] INT NULL
	,[disreasn1] INT NULL
	,[disreasn2] INT NULL
	,[tremcat] TINYINT NULL
	)
 