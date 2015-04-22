CREATE FUNCTION dbo.[fnc_CharCount]
               (@Text VARCHAR(MAX),
                @Char CHAR(1))
RETURNS INT
AS
  BEGIN
    DECLARE  @Occur INT
    
    SELECT @Occur = len(@Text) - len(replace(@Text,@Char,''))
    
    RETURN @Occur
  END