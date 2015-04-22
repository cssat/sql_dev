


CREATE function [dbo].[fn_ReturnStrTableFromList]
(@arrString varchar(8000), @distinct bit)
RETURNS @arrValues table (arrValue varchar(500))
AS
BEGIN
DECLARE @pos	int,		-- position of matching string
				@arrValue		varchar(500),	-- arrValues 
				@string		varchar(8000),	-- string to hold arrValues
				@unique_str	varchar(8000)	-- contains only unique arrValues string
	SELECT 	@unique_str = '',
					@string = replace (ltrim(rtrim(@arrString)), ',',' ')
	WHILE (@string IS NOT NULL) AND (@string <> '')
	BEGIN
		SELECT @pos = 	IIF(isnull(charindex(' ', @string), 0)=0,datalength(@string),charindex(' ', @string))
		SELECT @arrValue = rtrim(substring(@string, 1, @pos))
		IF (@distinct=1)
		BEGIN	IF isnull(patIndex ('% '+@arrValue+' %', @unique_str), 0) = 0		-- 
--update @unique_str with unique string
			BEGIN	SELECT @unique_str = rtrim(@unique_str) + ' ' + @arrValue + ' '
				INSERT @arrValues values (@arrValue)
			END
		END
		ELSE	INSERT @arrValues values (@arrValue)
		SELECT @string = ltrim(substring(@string, @pos + 1, datalength(@string)))	
	-- move to next value
	END
	RETURN
END


