CREATE function [dbo].[PR_OPER_TIME_NORM](@aOperID int)
returns decimal(18,4)
as
begin

  declare @res decimal(18,4)
  
  select @res = isnull(F.MANHOUR2,C.MANHOUR) 
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  left join PR_OPERATIONS C with (nolock) on C.ID = A.OPERTYPEID
  left join PR_REV_OVER_MH F with (nolock) on F.OPERID = C.ID and F.REVID = B.REVID
  where A.ID = @aOperID

  return @res

end;