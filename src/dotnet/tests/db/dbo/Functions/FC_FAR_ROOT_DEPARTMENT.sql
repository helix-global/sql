
CREATE FUNCTION [dbo].[FC_FAR_ROOT_DEPARTMENT]
(
    @FarID int
)
RETURNS int
AS
BEGIN
    
    DECLARE @ret int;

    with s (ID, PARENTID, MODELID)
    as
        (
            select ID, PARENTID, R.MODELID
                from FC_REPORT R
                where ID=@FarID
            union all
            select R1.ID, R1.PARENTID, R1.MODELID
                from FC_REPORT R1
                    join s R2 on R1.ID=R2.PARENTID)
    select @ret=M.DEPID from s 
            join PR_MODELS M on s.MODELID=M.ID
        where PARENTID is null


    RETURN @ret

END