create function [dbo].COM_WORK_DAYS(@dBeg datetime,@dEnd datetime,@aCalendarID int)
returns int as 
begin
   
   declare @res int
   
   select @res = count(*) from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
   where dbo.COM_IS_WORKDAY(A.DDATE,@aCalendarID) = 1
     
   return @res 

end