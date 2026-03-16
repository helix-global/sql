CREATE function [dbo].[FC_REPORT_ATT_COUNT](@aID int)
returns int as 
begin

  declare @res int
  declare @res2 int
  select @res = count(FF.ID) from FC_REPORT_FILES FF where FF.VNESHID = @aID 
  select @res2 = count(AF.ID) from FC_ANALYSIS_FILES AF where AF.VNESHID = @aID
  
  set @res = ISNULL(@res,0) + ISNULL(@res2,0)
  
  if @res > 0
    return @res
    
    
  return null  

end