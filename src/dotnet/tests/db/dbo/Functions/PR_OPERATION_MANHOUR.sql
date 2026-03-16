CREATE function [dbo].[PR_OPERATION_MANHOUR](@OperID int)
returns decimal(16,4)
as
begin

  declare @res decimal(16,4)   
  declare @deviceID int
  declare @OperTypeID int

  select @res = isnull(D.MANHOUR2,C.MANHOUR)
        ,@deviceID = A.DEVICEID
        ,@OperTypeID = A.OPERTYPEID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  left join PR_OPERATIONS C with (nolock) on C.ID = A.OPERTYPEID
  left join PR_REV_OVER_MH D with (nolock) on D.REVID = B.REVID and D.OPERID = C.ID
  where A.ID = @OperID
  
  declare @res2 decimal(16,4)   
  
  select @res2 = SUM(A.MANHOUR2) 
  from PR_OPER_ADD_MH A with (nolock) 
  where A.OPERID = @OperTypeID
    and A.OPTID in (select B.OPTID from PR_DEVICE_OPT B with (nolock) where B.DEVICEID = @deviceID) 
  
  return @res + isnull(@res2,0)

end;