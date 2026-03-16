create function [dbo].[LDM_SETTING_INT](@aLabel nvarchar(50), @aPrm int)
returns int as 
begin
  
  declare @res int
  
  if isnull(@aPrm,0) > 0
     select @res = A.VALUEINT from LDM_SETTINGS A with (nolock) where A.LABEL = @aLabel and A.PRM = @aPrm
  else   
     select @res = A.VALUEINT from LDM_SETTINGS A with (nolock) where A.LABEL = @aLabel 
     
  return @res   

end