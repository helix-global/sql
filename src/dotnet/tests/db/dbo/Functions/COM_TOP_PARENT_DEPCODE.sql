CREATE function [dbo].[COM_TOP_PARENT_DEPCODE](@aDepID int)
returns nvarchar(100)
as
begin

declare @res nvarchar(100)

declare @depID int = @aDepID
declare @parentID int
declare @i int = 1

while 1=1
begin
    set @parentID = null

	select @res = A.CODE 
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
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[COM_TOP_PARENT_DEPCODE] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[COM_TOP_PARENT_DEPCODE] TO [EMEA\DEPCS]
    AS [dbo];

