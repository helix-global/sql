CREATE function [dbo].[COM_TURN_START](@aEmplID int, @aDT datetime)
returns datetime as 
begin
  
   declare @res datetime
   declare @baseDate date = cast(@aDT as date)  
   declare @baseDT datetime = @baseDate
   declare @wtID int
   
   select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@aEmplID,@aDT)   
     
   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A with (nolock) where A.EMPLID = @aEmplID and A.DD = @baseDate
   
   set @wturn = ISNULL(@wturn,1)
   
   declare @TurnBeg time 
   
   select @TurnBeg = min(cast(A.TFROM as time))
     from COM_WORKTIME_BR A with (nolock) 
    where A.VNESHID = @wtID 
      and A.WTURN = @wturn 

   
   set @res = @baseDate
   set @res = @res + cast(@TurnBeg as datetime)
      
   return @res
  
end