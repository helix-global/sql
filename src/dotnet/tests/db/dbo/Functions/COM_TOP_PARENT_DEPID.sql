create function [dbo].[COM_TOP_PARENT_DEPID](@aDepID int)
returns int
as
begin

declare @res int

declare @depID int = @aDepID
declare @parentID int
declare @i int = 1

while 1=1
begin
    set @parentID = null

	select @res = A.ID 
		  ,@parentID = A.PARENTDEPARTMENT
	from COM_DEPARTMENTS A with (nolock) 
	where A.ID = @depID

    if (@parentID is null)
       return @res
       
    if (@depID  = @parentID)
       return @res

    set @depID = @parentID
    set @i = @i + 1
    
    if (@i > 50)
      return null
    
end
     
return @res  

end;