CREATE function [dbo].[SM_PROTOCOL_PARAM_V](@aMode int, @aID int)
returns sql_variant as 
begin

  declare @res sql_variant
  
  if (@aMode = 2) /* Param Value */
  begin
     select @res = A.PVALUE
     from PR_OPERATION_PARAMS A with (nolock)
     where A.ID = @aID
  end
  
  return @res
  
end