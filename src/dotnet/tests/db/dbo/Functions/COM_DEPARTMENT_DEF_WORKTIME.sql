
CREATE FUNCTION [dbo].[COM_DEPARTMENT_DEF_WORKTIME]
(
    @depId int
)
RETURNS int
AS
BEGIN
    
    declare @ret int

    select @ret = W.ID
        from COM_WORKTIME W
        where W.DEPID=@depId 
            and W.WTDEFAULT=1

    return @ret
END