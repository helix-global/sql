-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[COM_TRAINING_OPERATION_CAN_CREATE_NEXT]
(
    @DoneOperID int, @userID int
)
RETURNS int
AS
BEGIN
    
    DECLARE @ret int = 0

    declare @mapOperID int, @mapToOperID int, @deviceID int

    select @mapOperID=O.REVOPERID, @deviceID=O.DEVICEID
        from PR_OPERATION O
        where ID=@DoneOperID
        
    select @mapToOperID=M.OP_TO
    from PR_MAP_FLOW M
    where M.OP_FROM=@mapOperID

    declare @tMapOperations table (ID int)

    insert into @tMapOperations (ID)
    select M.OP_FROM
    from PR_MAP_FLOW M
    where M.OP_TO=@mapToOperID 

    if not exists(select M.ID
        from @tMapOperations M
            join PR_OPERATION O on M.ID=O.REVOPERID and O.DEVICEID=@deviceID
            join COM_TRAINING_OPERATIONS T on O.ID=T.OPERID
        where T.TRAINING_STATE is null and 
            ((O.USERINTRAINING<>@userID and O.ID<>@DoneOperID) or
            (O.USERINTRAINING=@userID and O.ID=@DoneOperID)))
        set @ret=1

    RETURN @ret

END