-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[FC_FA_APPROVAL_RECIPIENTS] 
(
    @subscrId int
)
RETURNS nvarchar(max)
AS
BEGIN
    declare @ret nvarchar(max)
    set @ret=''

    select @ret=@ret + C.NAME + ', '
    from FC_FA_APPROVE_SUBSCRIPTION_P D
        join COM_EMPLOYEE C on D.EMPLOYEEID=C.ID
    
    if @ret<>''
        set @ret=SUBSTRING(@ret,1,len(@ret)-1)

    return @ret

END