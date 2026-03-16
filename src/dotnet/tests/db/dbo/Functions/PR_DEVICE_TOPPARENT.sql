create function [dbo].[PR_DEVICE_TOPPARENT](@DeviceID int)
returns int as 
begin

  declare @res int = @DeviceID
  declare @i int = 1
  declare @parentID int 
  
  while 1=1
  begin
     
     set @i = @i + 1
  
     select @parentID = A.PARENTID from PR_DEVICE A with (nolock) where A.ID = @res
     
     if @parentID is null
       return @res
       
     if @i > 30
       break
       
     set @res = @parentID    
  
  end
  
  return @res  

end