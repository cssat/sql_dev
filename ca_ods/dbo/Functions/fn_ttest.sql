
create function [dbo].[fn_ttest]
    (@sum1 numeric(18, 9),
     @sum2 numeric(18, 9),
     @sd1 numeric(18, 9),
     @sd2 numeric(18, 9),
     @n1 int,
     @n2 int,
     @z float = 1.96)
     returns smallint
     as
     begin
         declare @equal_means bit;
         if((@sd1 <= 0)
             OR (@sd2 <= 0)
             OR (@n1 = 0)
             OR (@n2 = 0))
         set @equal_means = -1
         else if abs(@sum1 / @n1 - @sum2 / @n2) /
             (sqrt(((@n1 - 1) * power(@sd1, 2) + (@n2 - 1) * power(@sd2, 2)) / (@n1 + @n2 - 2)) *
                 sqrt(1 / @n1 + 1 / @n2)) < @z
         set @equal_means = 1
         else set @equal_means = 0
         return @equal_means
     end