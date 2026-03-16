

CREATE FUNCTION [dbo].[PR_LAST_OPERATION_MODIFIED_BY_STATE]
(
    @deviceId int, @operFormId int
)
RETURNS nvarchar(200)
AS
BEGIN

    DECLARE @ret nvarchar(200)

    select @ret = U.FULLNAME
        from PR_OPERATION O with(nolock) 
            left join DEF_USERS U with(nolock) on O.S_MR=U.ID
        where O.ID=(select MAX(ID) from PR_OPERATION O1 with(nolock) where O1.DEVICEID=@deviceId and O1.OPERTYPEID=@operFormId and O1.COMPLETED_DT is not null)

    RETURN @ret

END