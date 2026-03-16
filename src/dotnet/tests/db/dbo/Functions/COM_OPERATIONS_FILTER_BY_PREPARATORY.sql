
-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_OPERATIONS_FILTER_BY_PREPARATORY]
(
    @prepID int, @empId int
)
RETURNS @tRes TABLE (ID INT)
AS
BEGIN
    declare @userId int
    set @userId = dbo.COM_USER_BY_EMPL(@empId)

    insert into @tRes (ID)
    select O.ID 
        from PR_OPERATION O with (nolock) 
            left join PR_PREPARATORY P with (nolock)  on O.OPERTYPEID=P.OPERID 
            left join PR_OPERATION_TIME T with (nolock)  on O.ID=T.OPERID
        where P.ID=@prepID 
            and ((O.S_S in(1000032/*pending*/,1000031/*in progress*/) and isnull(O.USERINPROGRESS,@userId)=@userId and isnull(O.USERINTRAINING,@userId)=@userId) or
                (O.S_S in(1000013/*completed*/) and T.EMPID=@empId 
                    and not exists(select G.OPERID from COM_TRAINING_PREPARATORY G with (nolock) where G.OPERID=O.ID)  and O.COMPLETED_DT>DATEADD(WEEK,-1,GETDATE())))
            
    RETURN 
END