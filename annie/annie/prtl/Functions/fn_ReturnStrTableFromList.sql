CREATE FUNCTION [prtl].[fn_ReturnStrTableFromList] (
	@arrString VARCHAR(8000)
	,@distinct BIT
	)
RETURNS @arrValues TABLE (arrValue VARCHAR(500))
AS
BEGIN
	DECLARE @pos INT -- position of matching string
		,@arrValue VARCHAR(500) -- arrValues
		,@string VARCHAR(8000) -- string to hold arrValues
		,@unique_str VARCHAR(8000) -- contains only unique arrValues string

	SELECT @unique_str = ''
		,@string = REPLACE(LTRIM(RTRIM(@arrString)), ',', ' ')

	WHILE (@string IS NOT NULL)
		AND (@string <> '')
	BEGIN
		SELECT @pos = IIF(ISNULL(CHARINDEX(' ', @string), 0) = 0, DATALENGTH(@string), CHARINDEX(' ', @string))

		SELECT @arrValue = RTRIM(SUBSTRING(@string, 1, @pos))

		IF (@distinct = 1)
		BEGIN
			IF ISNULL(PATINDEX('% ' + @arrValue + ' %', @unique_str), 0) = 0
				--update @unique_str with unique string
			BEGIN
				SELECT @unique_str = rtrim(@unique_str) + ' ' + @arrValue + ' '

				INSERT @arrValues
				VALUES (@arrValue)
			END
		END
		ELSE
			INSERT @arrValues
			VALUES (@arrValue)

		SELECT @string = LTRIM(SUBSTRING(@string, @pos + 1, DATALENGTH(@string)))
			-- move to next value
	END

	RETURN
END
GO

