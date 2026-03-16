create function [dbo].[PR_NAV_PN_REPLACE](@aCode nvarchar(16),@aReplace int )
returns nvarchar(16) with schemabinding as 
begin
  
  if isnull(@aReplace,0) = 1
  begin
    
    declare @res nvarchar(16)
    set @res = substring(@aCode,1,len(@aCode)-1) + 'X'
    return @res
  
  end  
    
  return @aCode

end