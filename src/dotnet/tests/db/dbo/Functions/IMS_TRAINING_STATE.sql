
CREATE FUNCTION [dbo].[IMS_TRAINING_STATE]
(
    @aEmplID int, @aPlanID int
)
RETURNS int
AS
BEGIN
    
    declare @ret int = 0
    declare @d date

    set @d = dbo.IMS_TRAININGPLAN_CERTIFIED(@aEmplID,@aPlanID,GETDATE(),0)

    if YEAR(@d)>=4000
    begin

        declare @d1 date

        select @d1 = dbo.IMS_PLAN_TRAINING_DATE(@aEmplID,@aPlanID,T.COMPLETED_D,GETDATE())
            from IMS_TRAINING_PLAN P
                join IMS_TRAINING T on T.TRAININGPLANID=P.ID
            where P.ID=@aPlanID
        
        if dateadd(month,-3,@d1)<=GETDATE() and @d1>=GETDATE()
            set @ret = -32768 --orange
        else
            set @ret = -16744448 --green

    end
        
    if YEAR(@d)=1990 and MONTH(@d)=12 and DAY(@d)=12
        set @ret = -65536 --red

    if @ret=0
    begin

        if dateadd(month,-3,@d)>GETDATE()
            set @ret = -16744448 --green

        if dateadd(month,-3,@d)<=GETDATE() and @d>=GETDATE()
            set @ret = -32768 --orange
        else
            set @ret = -65536 --red

    end
    

    return @ret

END