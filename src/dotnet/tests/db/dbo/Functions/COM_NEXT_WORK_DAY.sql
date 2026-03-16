create function [dbo].[COM_NEXT_WORK_DAY](@dToday date,@dEnd date,@EmplID int)
returns date as 
begin
   
   
   declare @aCalendarID int
   declare @wtID int
   
   select @wtID = dbo.COM_WORKTABLE_BY_DATE2(@dToday,@EmplID)
   
   select @aCalendarID = A.CALENDAR 
   from COM_WORKTIME A with(nolock)
   where A.ID = @wtID
   
   declare @res date
   
   select top 1 @res = A.DDATE 
   from dbo.COM_DAY_PERIOD(@dToday,@dEnd) A
   where dbo.COM_IS_WORKDAY2(A.DDATE,@aCalendarID,@wtID) = 1
     and A.DDATE > @dToday
   order by A.DDATE
     
   return @res 

end