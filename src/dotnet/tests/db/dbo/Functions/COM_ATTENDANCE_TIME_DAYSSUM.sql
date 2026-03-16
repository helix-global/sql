create function [dbo].[COM_ATTENDANCE_TIME_DAYSSUM](@aUserID int,@aEmplID int,@aDBeg date,@aDEnd date)
returns int as 
begin
 
  declare @res int

  select @res = sum(dbo.COM_ATTENDANCE_TIME(@aUserID,@aEmplID,A.DDATE)) 
  from dbo.COM_DAY_PERIOD(@aDBeg,@aDEnd) A

  return @res

end