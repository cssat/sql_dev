-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[cutoff_date]() RETURNS  datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @cutoff_date datetime

	-- Add the T-SQL statements to compute the return value here
	select @cutoff_date =cutoff_date from dbo.ref_last_dw_transfer

	-- Return the result of the function
	RETURN @cutoff_date

END
