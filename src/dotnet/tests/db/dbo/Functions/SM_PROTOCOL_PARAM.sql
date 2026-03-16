create function [dbo].[SM_PROTOCOL_PARAM](@aMode int, @aID int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  
  if (@aMode = 1) /* Param Name */
  begin
     select @res = B.NAME
     from PR_OPERATION_PARAMS A with (nolock)
     left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.PARAMID
     where A.ID = @aID
  end
  
  return @res
  
end