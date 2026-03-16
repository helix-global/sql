-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[FC_FA_APPROVAL_DEPARTMENTS] 
(
    @subscrId int
)
RETURNS nvarchar(max)
AS
BEGIN
    declare @ret nvarchar(max)
    set @ret=''

    select @ret=@ret + C.NAME + ', '
    from FC_FA_APPROVE_SUBSCRIPTION_D D
        join COM_DEPARTMENTS C on D.DEPARTMENTID=C.ID
    
    if @ret<>''
        set @ret=SUBSTRING(@ret,1,len(@ret)-1)
    
    return @ret

END