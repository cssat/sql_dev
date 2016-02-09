-- =============================================
-- Author:		Brian Waismeyer
-- Create date: 1-25-2016
-- Description:	Crosswalk for ICD-10 to EPH Injury Flag
-- =============================================
CREATE PROCEDURE [rodis].[load_xwalk_icd_10_to_eph]
AS
/* 
This script creates a crosswalk that can be used to
identify how ICD-10 diagnoses are categorized for EPH
work/replications. It is used in the creation of the
"rodis.birth_child_hospital" (BCH) and 
"rodis.birth_child_death" (BCD) tables.

The table was constructed using a modified version of the
official CDC table. The modified version is printed in
EPH's 2011 Injury Deat paper. The original can be 
retrieved here: 
http://www.cdc.gov/nchs/data/ice/icd10_transcode.pdf

The modified table excludes injuries related to terrorism,
medical/surgical complications, or suicide/self-harm.

IMPORTANT NOTES
* The table is NOT appropriate for use with ICD-9 codes.
    ICD-9 codes do have an analagous matrix (here:
    http://www.cdc.gov/nchs/data/injury/icd9_external.pdf).
    However, this table only works for E codes and none of
    our WA records used E codes. In other words, we have
    no identical crosswalk for ICD-9 codes and work with
    those codes needs to be simplified (e.g., codes beginning
    with 8 or 9 are "injury" related codes but we have
    no indicators of intent).
* The table is NOT a 1:1 crosswalk. Instead, the foreign key
    column (icd_10_head) is designed to match the first three
    alphanumeric characters in an ICD-10 code. You will want
    to use the "LIKE" operator (if using SQL) or some other
    matching logic when using this table.
*/
TRUNCATE TABLE rodis.xwalk_icd_10_to_eph

-- Make a collection of the letters we want.

;WITH letters AS (
    SELECT 'V' [letter]
	UNION ALL
    SELECT 'W' [letter]
	UNION ALL
    SELECT 'X' [letter]
	UNION ALL
    SELECT 'Y' [letter]
	)

-- And a table of the base number range (1 - 9).
,numbers AS (
	SELECT 0 [number]
	UNION ALL
	SELECT number + 1 [number]
	FROM numbers
	WHERE number <= 8
)

-- Combine these to get our actual target range.
,raw_codes AS (
	SELECT CONCAT(l.letter, n1.number, n2.number) [icd_10_head]
		,l.letter [letters]
		,CONVERT(INT, CONCAT(CONVERT(VARCHAR(2), n1.number), CONVERT(VARCHAR(2), n2.number))) [numbers]
	FROM numbers n1
	CROSS JOIN numbers n2
	CROSS JOIN letters l
	)

-- Next we drop those 'Y' codes with values outside
-- our target numeric range (i.e., greater than 36
-- unless 85-86; note that 87 and 89 need fuller 
-- specification).
, raw_codes_drops AS (
	SELECT rc.*
		,CASE 
			WHEN rc.letters = 'Y'
				AND rc.numbers IN (
					85
					,86
					)
				THEN 1
			WHEN rc.letters = 'Y'
				AND rc.numbers > 36
				THEN 0
			WHEN rc.letters = 'V'
				AND rc.numbers = 0
				THEN 0
			ELSE 1
			END [in_range_fl]
	FROM raw_codes AS rc
	)

-- Grab those ICD-10 codes that are in our target range.
,clean_codes AS (
	SELECT rcd.*
	FROM raw_codes_drops rcd
	WHERE in_range_fl = 1
	UNION ALL
	-- Y87 and Y89 need to be specified out to the third value.
	SELECT CONCAT(rcd.icd_10_head, CONVERT(VARCHAR(5), n.number))
		,rcd.letters
		,rcd.numbers
		,1
	FROM raw_codes_drops rcd
	CROSS JOIN numbers n
	WHERE rcd.icd_10_head IN ('Y87', 'Y89')
	)

-- Create the EPH flags.
,pre_load AS (
	SELECT cc.icd_10_head
		,CASE 
			WHEN cc.icd_10_head IS NOT NULL
				THEN 1
			END AS eph_all_injury_fl
		,CASE 
			WHEN cc.letters = 'X'
				AND cc.numbers >= 85
				THEN 1
			WHEN cc.letters = 'Y'
				AND cc.numbers < 10
				THEN 1
			WHEN cc.icd_10_head = 'Y871'
				THEN 1
			ELSE 0
			END [eph_intentional_injury_fl]
		,CASE 
			WHEN cc.letters = 'V'
				AND cc.numbers >= 1
				THEN 1
			WHEN cc.letters = 'X'
				AND cc.numbers <= 59
				THEN 1
			WHEN icd_10_head IN ('Y85', 'Y86')
				THEN 1
			ELSE 0
			END [eph_unintentional_injury_fl]
		,CASE 
			WHEN cc.letters = 'Y'
				AND (
					cc.numbers >= 10
					AND cc.numbers <= 34
					)
				THEN 1
			WHEN cc.icd_10_head IN ('Y872', 'Y899')
				THEN 1
			ELSE 0
			END [eph_undetermined_injury_fl]
	FROM clean_codes AS cc
	)

-- Table repopulation.
INSERT rodis.xwalk_icd_10_to_eph (
	icd_10_head
	,eph_all_injury_fl
	,eph_intentional_injury_fl
	,eph_unintentional_injury_fl
	,eph_undetermined_injury_fl
	)
SELECT icd_10_head
	,eph_all_injury_fl
	,eph_intentional_injury_fl
	,eph_unintentional_injury_fl
	,eph_undetermined_injury_fl
FROM pre_load
