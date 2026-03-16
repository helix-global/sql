
CREATE FUNCTION [dbo].[PR_FP_CHECK_DEVICEID_UNIQ]
(   
)
RETURNS int
AS
BEGIN
    declare @ret int = 0

    if exists(select count(P.ID)
                from PR_FP_PLANNING_ITEMS P
                where P.DEVICEID<>0
                group by P.DEVICEID
                having count(P.ID)>1)
        set @ret = 1


    return @ret

END