create function [dbo].[COM_WORK_DAYS2](@dBeg datetime,@dEnd datetime,@aCalendarID int,@wtID int)
returns int as 
begin
   
   declare @res int
   
   select @res = count(*) from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
   where dbo.COM_IS_WORKDAY2(A.DDATE,@aCalendarID,@wtID) = 1
     
   return @res 

end