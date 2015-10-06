﻿CREATE TABLE [annual_report].[ca_ncands_extracts] (
	[subyr] INT NULL
	,[staterr] CHAR(2) NULL
	,[rptid] INT NOT NULL
	,[chid] INT NOT NULL
	,[rptcnty] INT NULL
	,[rptdt] DATE NULL
	,[invdate] DATE NULL
	,[rptsrc] TINYINT NULL
	,[rptdisp] TINYINT NULL
	,[rptdisdt] DATE NULL
	,[notifs] TINYINT NULL
	,[chage] TINYINT NULL
	,[chbdate] DATE NULL
	,[chsex] TINYINT NULL
	,[chracai] TINYINT NULL
	,[chracas] TINYINT NULL
	,[chracbl] TINYINT NULL
	,[chracnh] TINYINT NULL
	,[chracwh] TINYINT NULL
	,[chracud] TINYINT NULL
	,[chethn] TINYINT NULL
	,[chcnty] INT NULL
	,[chlvng] TINYINT NULL
	,[chmil] TINYINT NULL
	,[chprior] TINYINT NULL
	,[chmal1] TINYINT NULL
	,[mal1lev] TINYINT NULL
	,[chmal2] TINYINT NULL
	,[mal2lev] TINYINT NULL
	,[chmal3] TINYINT NULL
	,[mal3lev] TINYINT NULL
	,[chmal4] TINYINT NULL
	,[mal4lev] TINYINT NULL
	,[maldeath] TINYINT NULL
	,[cdalc] TINYINT NULL
	,[cddrug] TINYINT NULL
	,[cdrtrd] TINYINT NULL
	,[cdemotnl] TINYINT NULL
	,[cdvisual] TINYINT NULL
	,[cdlearn] TINYINT NULL
	,[cdphys] TINYINT NULL
	,[cdbehav] TINYINT NULL
	,[cdmedicl] TINYINT NULL
	,[fcalc] TINYINT NULL
	,[fcdrug] TINYINT NULL
	,[fcrtrd] TINYINT NULL
	,[fcemotnl] TINYINT NULL
	,[fcvisual] TINYINT NULL
	,[fclearn] TINYINT NULL
	,[fcphys] TINYINT NULL
	,[fcmedicl] TINYINT NULL
	,[fcviol] TINYINT NULL
	,[fchouse] TINYINT NULL
	,[fcmoney] TINYINT NULL
	,[fcpublic] TINYINT NULL
	,[postserv] TINYINT NULL
	,[servdate] DATE NULL
	,[famsup] TINYINT NULL
	,[fampres] TINYINT NULL
	,[fostercr] TINYINT NULL
	,[rmvdate] DATE NULL
	,[juvpet] TINYINT NULL
	,[petdate] DATE NULL
	,[cochrep] TINYINT NULL
	,[adopt] TINYINT NULL
	,[casemang] TINYINT NULL
	,[counsel] TINYINT NULL
	,[daycare] TINYINT NULL
	,[educatn] TINYINT NULL
	,[employ] TINYINT NULL
	,[famplan] TINYINT NULL
	,[health] TINYINT NULL
	,[homebase] TINYINT NULL
	,[housing] TINYINT NULL
	,[transliv] TINYINT NULL
	,[inforef] TINYINT NULL
	,[legal] TINYINT NULL
	,[menthlth] TINYINT NULL
	,[pregpar] TINYINT NULL
	,[respite] TINYINT NULL
	,[ssdisabl] TINYINT NULL
	,[ssdelinq] TINYINT NULL
	,[subabuse] TINYINT NULL
	,[transprt] TINYINT NULL
	,[othersv] TINYINT NULL
	,[wrkrid] INT NULL
	,[suprvid] INT NULL
	,[per1id] INT NULL
	,[per1rel] TINYINT NULL
	,[per1prnt] TINYINT NULL
	,[per1cr] TINYINT NULL
	,[per1age] TINYINT NULL
	,[per1sex] TINYINT NULL
	,[p1racai] TINYINT NULL
	,[p1racas] TINYINT NULL
	,[p1racbl] TINYINT NULL
	,[p1racnh] TINYINT NULL
	,[p1racwh] TINYINT NULL
	,[p1racud] TINYINT NULL
	,[per1ethn] TINYINT NULL
	,[per1mil] TINYINT NULL
	,[per1pior] TINYINT NULL
	,[per1mal1] TINYINT NULL
	,[per1mal2] TINYINT NULL
	,[per1mal3] TINYINT NULL
	,[per1mal4] TINYINT NULL
	,[per2id] INT NULL
	,[per2rel] TINYINT NULL
	,[per2prnt] TINYINT NULL
	,[per2cr] TINYINT NULL
	,[per2age] TINYINT NULL
	,[per2sex] TINYINT NULL
	,[p2racai] TINYINT NULL
	,[p2racas] TINYINT NULL
	,[p2racbl] TINYINT NULL
	,[p2racnh] TINYINT NULL
	,[p2racwh] TINYINT NULL
	,[p2racud] TINYINT NULL
	,[per2ethn] TINYINT NULL
	,[per2mil] TINYINT NULL
	,[per2pior] TINYINT NULL
	,[per2mal1] TINYINT NULL
	,[per2mal2] TINYINT NULL
	,[per2mal3] TINYINT NULL
	,[per2mal4] TINYINT NULL
	,[per3id] INT NULL
	,[per3rel] TINYINT NULL
	,[per3prnt] TINYINT NULL
	,[per3cr] TINYINT NULL
	,[per3age] TINYINT NULL
	,[per3sex] TINYINT NULL
	,[p3racai] TINYINT NULL
	,[p3racas] TINYINT NULL
	,[p3racbl] TINYINT NULL
	,[p3racnh] TINYINT NULL
	,[p3racwh] TINYINT NULL
	,[p3racud] TINYINT NULL
	,[per3ethn] TINYINT NULL
	,[per3mil] TINYINT NULL
	,[per3pior] TINYINT NULL
	,[per3mal1] TINYINT NULL
	,[per3mal2] TINYINT NULL
	,[per3mal3] TINYINT NULL
	,[per3mal4] TINYINT NULL
	,[afcarsid] INT NULL
	,[inciddt] DATE NULL
	)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_pk_ca_ncands_extracts] ON [annual_report].[ca_ncands_extracts] (
	[rptid]
	,[chid]
	)
GO
