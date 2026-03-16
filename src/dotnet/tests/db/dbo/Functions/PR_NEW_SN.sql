CREATE function [dbo].[PR_NEW_SN](@ModelID int)
returns int as 
begin
  declare @res int
  select @res = max(SN) from PR_DEVICE /*where MODELID =@ModelID*/
  return isnull(@res,0) + 1  
end