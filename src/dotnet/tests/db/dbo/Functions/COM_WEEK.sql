CREATE function [dbo].[COM_WEEK] (@dd datetime)
returns @res table (YY int, MM int ,DD int, DDATE date, DDATE_PLUS1 date, DAYN int )
as 
begin

   declare @iDD date = cast(@dd as date)
   declare @dayOfW int = dbo.COM_DAY_OF_WEEK(@iDD)
   set @iDD = dateadd(day,1-@dayOfW,@iDD)
   declare @nn int = 1
   
   while @nn <= 7
   begin   
      
     insert into @res (YY, MM, DD, DDATE, DDATE_PLUS1, DAYN)
     values (year(@iDD), month(@iDD), day(@iDD), @iDD, dateadd(day,1,@iDD), dbo.COM_DAY_OF_WEEK(@iDD))
     
     set @nn = @nn + 1 
     set @iDD = dateadd(day,1,@iDD) 
   
   end
   
   return

end