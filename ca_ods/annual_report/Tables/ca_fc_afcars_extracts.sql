CREATE TABLE [annual_report].[ca_fc_afcars_extracts] (
	[st] INT NULL
	,[repdat] INT NOT NULL
	,[fipscode] INT NULL
	,[recnumbr] INT NOT NULL
	,[pedrevdt] DATE NULL
	,[dob] DATE NULL
	,[sex] TINYINT NULL
	,[amiakn] TINYINT NULL
	,[asian] TINYINT NULL
	,[blkafram] TINYINT NULL
	,[hawaiipi] TINYINT NULL
	,[white] TINYINT NULL
	,[untodetm] TINYINT NULL
	,[hisorgin] TINYINT NULL
	,[clindis] TINYINT NULL
	,[mr] TINYINT NULL
	,[vishear] TINYINT NULL
	,[phydis] TINYINT NULL
	,[dsmiii] TINYINT NULL
	,[othermed] TINYINT NULL
	,[everadpt] TINYINT NULL
	,[ageadopt] TINYINT NULL
	,[rem1dt] DATE NULL
	,[totalrem] TINYINT NULL
	,[dlstfcdt] DATE NULL
	,[latremdt] DATE NULL
	,[remtrndt] DATE NULL
	,[cursetdt] DATE NULL
	,[numplep] TINYINT NULL
	,[manrem] TINYINT NULL
	,[phyabuse] TINYINT NULL
	,[sexabuse] TINYINT NULL
	,[neglect] TINYINT NULL
	,[daparent] TINYINT NULL
	,[aaparent] TINYINT NULL
	,[dachild] TINYINT NULL
	,[aachild] TINYINT NULL
	,[childis] TINYINT NULL
	,[chbehprb] TINYINT NULL
	,[prtsdied] TINYINT NULL
	,[prtsjail] TINYINT NULL
	,[nocope] TINYINT NULL
	,[abandmnt] INT NULL
	,[relinqsh] INT NULL
	,[housing] INT NULL
	,[curplset] TINYINT NULL
	,[placeout] TINYINT NULL
	,[casegoal] TINYINT NULL
	,[ctkfamst] TINYINT NULL
	,[ctk1yr] INT NULL
	,[ctk2yr] INT NULL
	,[tprdaddt] DATE NULL
	,[tprmomdt] DATE NULL
	,[fosfamst] TINYINT NULL
	,[fcctk1yr] INT NULL
	,[fcctk2yr] INT NULL
	,[rf1amakn] TINYINT NULL
	,[rf1asian] TINYINT NULL
	,[rf1blkaa] TINYINT NULL
	,[rf1nhopi] TINYINT NULL
	,[rf1white] TINYINT NULL
	,[rf1utod] TINYINT NULL
	,[hofcctk1] TINYINT NULL
	,[rf2amakn] TINYINT NULL
	,[rf2asian] TINYINT NULL
	,[rf2blkaa] TINYINT NULL
	,[rf2nhopi] TINYINT NULL
	,[rf2white] TINYINT NULL
	,[rf2utod] TINYINT NULL
	,[hofcctk2] TINYINT NULL
	,[dodfcdt] DATE NULL
	,[dodtrndt] DATE NULL
	,[disreasn] TINYINT NULL
	,[ivefc] INT NULL
	,[ifeaa] INT NULL
	,[ivaafdc] INT NULL
	,[ivdchsup] INT NULL
	,[xixmedcd] INT NULL
	,[ssiother] INT NULL
	,[noa] INT NULL
	,[fcmnpay] INT NULL
	)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_pk_ca_fc_afcars_extracts] ON [annual_report].[ca_fc_afcars_extracts] (
	[repdat]
	,[recnumbr]
	)
GO
