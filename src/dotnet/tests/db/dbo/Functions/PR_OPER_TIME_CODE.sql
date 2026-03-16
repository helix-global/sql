CREATE function [dbo].[PR_OPER_TIME_CODE](@aOperTimeID int)
returns nvarchar(50)
as
begin

  declare @res nvarchar(50)
  
  select @res = isnull(Q.OPERCODE,Q.OPERCODE)
  from PR_OPERATION_TIME A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPID
  left join PR_OPERATIONS S with (nolock) on S.ID = B.OPERTYPEID
  left join PR_OPERATIONS_GRQ Q with (nolock) on Q.VNESHID = S.OPERGRID and Q.QUALIFICATION = C.QUALIFICATION
  where A.ID = @aOperTimeID

  return @res

end;