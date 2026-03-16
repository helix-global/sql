create function [dbo].[EQ_NEXT_MNT_OPER_DATE](@aEqID int, @aMode int)
returns datetime as 
begin

   declare @res datetime
   
   select @res = MIN(GA.NEXTDATE) 
   from MNT_PLAN_EQ GA with (nolock) 
   left join MNT_PLAN GB with (nolock) on GB.ID = GA.VNESHID 
   where GA.EQID = @aEqID 
     and GB.S_S = 1 
     and GB.CRMODE in (3,4)
   
   return @res 

end