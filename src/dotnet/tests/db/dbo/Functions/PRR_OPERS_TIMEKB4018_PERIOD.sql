CREATE function [dbo].[PRR_OPERS_TIMEKB4018_PERIOD](@aEmplID int, @dd datetime, @dend datetime, @SpecOperType int)
returns decimal(18,2)
as
begin

  declare @res decimal(18,2)
  
 
  
  select @res = sum(isnull((case when A.ELAPSEDCORR < 0 then 0 else A.ELAPSEDCORR end),A.ELAPSED_D)) 
  from PR_OPERATION_TIME A with(nolock)
  left join PR_OPERATION B with(nolock) on B.ID = A.OPERID
  left join PR_OPERATIONS C with(nolock) on C.ID = B.OPERTYPEID
  where A.EMPID = @aEmplID
    and B.COMPLETED_DT >= @dd
    and B.COMPLETED_DT < @dend
    and C.OPERTYPE = @SpecOperType  
  
  
  return isnull(@res,0);
  
end;