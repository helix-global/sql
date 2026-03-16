CREATE function [dbo].[COM_EMPLOYEE_IN_DEP_MINUTES](@EmployeeID int, @DepID int, @DateStart datetime, @DateEnd datetime, @whID int, @calendar int, @includeChildDeps bit)
returns 
decimal(12, 2)
begin
  
  declare @res decimal(12, 2)

  select @res=sum(dbo.COM_WORK_MINUTS5(DBEG,DEND,@whID,@calendar,@EmployeeID))
  from dbo.COM_EMPLOYEE_IN_DEP_RANGE(@EmployeeID, @DepID, @DateStart, @DateEnd, @includeChildDeps)

  return @res

end