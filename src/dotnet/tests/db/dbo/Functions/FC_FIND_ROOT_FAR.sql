CREATE function [dbo].[FC_FIND_ROOT_FAR](@aFarID int)
returns int
as
begin

declare @res int

declare @farID int = @aFarID
declare @parentID int
declare @i int = 1

while 1=1
begin
    set @parentID = null

	select @parentID = A.PARENTID
	from FC_REPORT A with (nolock) 
	where A.ID = @farID

    if (@parentID is null)
       return @res
       
    set @res = @parentID   
    set @farID = @parentID
    set @i = @i + 1
    
    if (@i > 50)
      return null
    
end
     
return @res  

end;