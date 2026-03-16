
CREATE FUNCTION [dbo].[PR_LAST_OPERATION_DATE_BY_STATE]
(
    @deviceId int, @operFormId int
)
RETURNS datetime
AS
BEGIN

    DECLARE @ret datetime

    select @ret = O.COMPLETED_DT
        from PR_OPERATION O with(nolock) 
        where O.ID=(select MAX(ID) from PR_OPERATION O1 with(nolock) where O1.DEVICEID=@deviceId and O1.OPERTYPEID=@operFormId and O.COMPLETED_DT is not null)

    RETURN @ret

END