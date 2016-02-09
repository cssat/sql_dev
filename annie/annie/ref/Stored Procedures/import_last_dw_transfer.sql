CREATE PROCEDURE [ref].[import_last_dw_transfer]
AS
TRUNCATE TABLE ref.last_dw_transfer

INSERT ref.last_dw_transfer (
	cutoff_date
	)
SELECT
	cutoff_date
FROM CA_ODS.dbo.ref_last_dw_transfer
