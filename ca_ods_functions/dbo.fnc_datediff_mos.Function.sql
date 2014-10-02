USE [CA_ODS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnc_datediff_mos]    Script Date: 10/1/2014 2:37:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER function [dbo].[fnc_datediff_mos](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

--DECLARE @BEGIN_DATE DATETIME = '2012-03-15 21:36:43.997'
--	,@END_DATE DATETIME = '2014-04-12 07:39:02.730'

DECLARE @diff int
if (@BEGIN_DATE<=@END_DATE)
begin
IF day(@END_DATE) < day(@BEGIN_DATE)

	SET @diff = datediff(mm,@BEGIN_DATE,@END_DATE) - 1

ELSE

	SET @diff = datediff(mm,@BEGIN_DATE,@END_DATE)
end
--PRINT @diff
RETURN @diff

end




