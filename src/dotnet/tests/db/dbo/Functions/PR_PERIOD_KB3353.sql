CREATE function [dbo].[PR_PERIOD_KB3353](@deviceID int, @opertypeID int,@aPeriodType int)
returns date as 
/* KB3353 */
begin
  declare @aDD datetime
  
  select top 1 @aDD = A.COMPLETED_DT 
  from PR_OPERATION A with(nolock) 
  where A.DEVICEID = @deviceID 
    and A.OPERTYPEID = @opertypeID
    and A.COMPLETED_DT is not null
  
  declare @res date
  
  if (@aPeriodType = 1) /*day*/
  begin
     
     set @res = cast(@aDD as date)
  
  end
  else if (@aPeriodType = 2) /*week*/
  begin
  
	 set @res = cast(@aDD as date)
     set @res = dbo.COM_WEEKDAY(@res,1)
  
  end
  else if (@aPeriodType = 3) /*month*/
  begin
  
     set @res = cast(@aDD as date)
     set @res = dateadd(day,-datepart(day,@res)+1,@res)
  
  end

  return @res;
end