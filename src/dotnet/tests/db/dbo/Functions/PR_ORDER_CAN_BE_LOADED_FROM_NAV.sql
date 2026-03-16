-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PR_ORDER_CAN_BE_LOADED_FROM_NAV] 
(
    @orderNumber nvarchar(100),
    @orderState nvarchar(20),
    @UserId int
)
RETURNS int
AS
BEGIN
    
    declare @ret int = 0, @depId int

    set @depId = dbo.COM_USER_DEPARTMENT(@UserId)

    if exists(select * from PR_SUPPLY_PREFIX_DEP_STATE D 
                    join PR_SUPPLY_PREFIX S on D.PREFIXID=S.ID
                where D.DEPID=@depId and @orderNumber like S.PREFIX + '%')
    begin
        if exists(select P.ID
            from PR_SUPPLY_PREFIX_DEP_STATE P
                join PR_SUPPLY_PREFIX S on P.PREFIXID=S.ID
                join PR_SUPPLY_STATE T on P.STATE=T.ID
            where P.DEPID=@depId and @orderNumber like S.PREFIX + '%' and LOWER(T.STATE)=LOWER(@orderState))
            set @ret=1
    end
    else
    begin
        if exists(select P.ID
            from PR_SUPPLY_PREFIX_STATE P
                join PR_SUPPLY_PREFIX S on P.PREFIXID=S.ID
                join PR_SUPPLY_STATE T on P.STATE=T.ID
            where @orderNumber like S.PREFIX + '%' and LOWER(T.STATE)=LOWER(@orderState))
            set @ret=1
    end

    return @ret
END