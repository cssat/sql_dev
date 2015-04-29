USE CA_ODS
GO

/****** Object:  UserDefinedFunction [dbo].[fnc_datediff_yrs]    Script Date: 8/26/2014 12:16:27 PM ******/
DROP FUNCTION [dbo].[fnc_datediff_yrs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnc_datediff_yrs]    Script Date: 8/26/2014 12:16:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fnc_datediff_yrs](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

DECLARE @diff int

IF cast(datepart(m,@END_DATE) as int) > cast(datepart(m,@BEGIN_DATE) as int)

SET @diff = cast(datediff(yyyy,@BEGIN_DATE,@END_DATE) as int)

else

		IF cast(datepart(m,@END_DATE) as int) = cast(datepart(m,@BEGIN_DATE) as int)

		IF datepart(d,@END_DATE) >= datepart(d,@BEGIN_DATE)

			SET @diff = cast(datediff(yyyy,@BEGIN_DATE,@END_DATE) as int)

		ELSE

		SET @diff = cast(datediff(yyyy,@BEGIN_DATE,@END_DATE) as int) -1

	ELSE

	SET @diff = cast(datediff(yyyy,@BEGIN_DATE,@END_DATE) as int) - 1

RETURN @diff

end



GO


