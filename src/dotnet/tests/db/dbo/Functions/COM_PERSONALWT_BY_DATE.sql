

CREATE FUNCTION [dbo].[COM_PERSONALWT_BY_DATE]
(
    @date datetime, @empId int
)
RETURNS int
AS
BEGIN
    
    declare @ret int

    select top 1 @ret = H.PERSONALWT
        from COM_PERSONALWORKTIME_HISTORY H
            where H.EMPLOYEEID=@empId
                and H.DBEG<=@date
        order by H.DBEG desc

    return @ret

END