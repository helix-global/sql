
CREATE function [dbo].[COM_HASNOGC](@UserID int)
returns bit as 
begin
 
    declare @value bit = 0
    
    select @value = ISNULL(E.NOGREENCARD,0)
        from COM_EMPLOYEE E with (nolock)
        where E.ID = dbo.DEF_EMPLOYEE(@UserID)

    return @value

end