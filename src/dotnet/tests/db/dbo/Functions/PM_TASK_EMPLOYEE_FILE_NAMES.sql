
CREATE FUNCTION [dbo].[PM_TASK_EMPLOYEE_FILE_NAMES]
(
    @bundleId int
)
RETURNS nvarchar(max)
AS
BEGIN
    
    DECLARE @ret nvarchar(max) = ''

    select @ret = @ret + F.FILENAME + char(10) + char(13)
        from PM_TASK_EMPLOYEE_FILES F
        where F.VNESHID = @bundleId

    if @ret<>''
        set @ret = left(@ret, len(@ret)-2)
    
    RETURN @ret
END