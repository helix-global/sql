-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[COM_OPERATION_IS_IN_TRAINING]
(
    @operID int
)
RETURNS nvarchar(3)
AS
BEGIN
    declare @ret nvarchar(3)

    set @ret = null

    if exists(select * 
                from COM_TRAINING_OPERATIONS O
                    join COM_TRAINING T on O.TRAININGID=T.ID
                    where O.OPERID=@operID and T.S_S>1)
    begin
        set @ret='Yes'
    end
    else
    begin
        if exists(select * 
                from COM_TRAINING_PREPARATORY O
                    join COM_TRAINING T on O.TRAINING_ID=T.ID
                    where O.OPERID=@operID and T.S_S>1)
            set @ret='Yes'
    end

    return @ret

END