CREATE FUNCTION dbo.fnSequence (@Limit INT)
RETURNS @Series TABLE(SeqNo INT)
AS
  BEGIN
    DECLARE  @Sequence  TABLE(
                              SeqNo INT    IDENTITY ( 1 , 1 ),
                              One   INT
                              )
    INSERT @Sequence
          (One)
    SELECT TOP ( @Limit ) 1
    FROM   sys.objects a
           CROSS JOIN sys.objects b
           CROSS JOIN sys.objects C
    
    INSERT @Series
    SELECT SeqNo
    FROM   @Sequence
    RETURN
  END
