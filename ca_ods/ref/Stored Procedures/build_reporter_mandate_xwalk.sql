CREATE PROCEDURE [ref].[build_reporter_mandate_xwalk]
AS
TRUNCATE TABLE ref.reporter_mandate_xwalk

-- get the unique reporter codes and their text descriptions
-- and add these to the table
INSERT ref.reporter_mandate_xwalk (
	cd_rptr_dscr
	,tx_rptr_dscr
	)
SELECT iad.CD_RPTR_DSCR [cd_rptr_dscr]
	,iad.TX_RPTR_DSCR [tx_rptr_dscr]
FROM dbo.INTAKE_ATTRIBUTE_DIM iad
GROUP BY iad.CD_RPTR_DSCR
	,iad.TX_RPTR_DSCR
ORDER BY iad.CD_RPTR_DSCR

-- update the table to link the reporter codes to mandate
UPDATE ref.reporter_mandate_xwalk
SET tx_rptr_mandate = CASE 
		WHEN tx_rptr_dscr = 'Anonymous'
			OR tx_rptr_dscr = 'Friend / Neighbor'
			OR tx_rptr_dscr = 'Parent /Guardian'
			OR tx_rptr_dscr = 'Other'
			OR tx_rptr_dscr = 'Other Relative'
			OR tx_rptr_dscr = 'Subject'
			OR tx_rptr_dscr = 'Victim and/or Self'
			THEN 'voluntary'
		ELSE 'mandatory'
		END
