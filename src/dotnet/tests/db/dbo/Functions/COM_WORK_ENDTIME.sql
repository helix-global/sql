CREATE function [dbo].[COM_WORK_ENDTIME](@aWorkTimeID int, @now datetime, @aMode int)
returns datetime as 
begin

   declare @baseDate datetime = cast(@now as date)

   declare @res datetime

   select @res = TTO 
   from (
   select 
        dateadd(day,addday,@baseDate) + cast(TTO as datetime) as TTO
   from (
   select TTO
         ,case when /*datepart(hour,TTO) < 3*/ TTO < TFROM or TDEXTDAY = 1 then 1 else 0 end as addday
   from (
   select cast(A.TTO as time) as TTO
      ,cast(A.TFROM as time) as TFROM
      ,isnull(A.TDEXTDAY,0) as TDEXTDAY
   from COM_WORKTIME_BR A with (nolock)
   where A.VNESHID = @aWorkTimeID
   ) M
   ) M2
   ) M3
     
   return @res  

end