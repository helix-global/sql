
CREATE FUNCTION [dbo].[COM_WORK_STARTTIME]
(
    @empId int
    , @date datetime
)
RETURNS datetime
AS
BEGIN
    declare @dt datetime, @dtTmp datetime

    set @dtTmp = cast(@date as date)

    select @dt=min(DBEG) from dbo.COM_WORKPERIODS5(@dtTmp,@dtTmp+1,1,dbo.COM_WORKTABLE_BY_DATE(@dtTmp,@empId),@empId)

    return @dt 
END