
CREATE PROCEDURE [dbo].[COM_CREATE_TRAINING_PREPARATORIES]
    @trId int, @UserID int
AS
BEGIN

    declare @prepId int, @empId int, @userTrId int, @preOperId int
    declare @NewOpID int

    select @empId=T.EMPLOYEEID, @userTrId=dbo.COM_USER_BY_EMPL(T.EMPLOYEEID)
        from COM_TRAINING T
        where ID=@trId
    
    declare cur_COM_CREATE_TRAINING_PREPARATORIES cursor for
    select P.ID, T.OPERID
        from COM_TRAINING_PREPARATORY P
            join PR_PREPARATORY T on P.PREPARATORY_ID=T.ID
        where P.TRAINING_ID=@trId
            and P.OPERID is null
        
                    
    open cur_COM_CREATE_TRAINING_PREPARATORIES

    fetch next from cur_COM_CREATE_TRAINING_PREPARATORIES into @prepId, @preOperId

    while @@fetch_status=0
    begin
    
        insert into PR_OPERATION (GID,S_CDT,S_CR,S_S,OPERTYPEID,OPLEVEL,USERINPROGRESS,USERINTRAINING)
            values (newid(),getdate(),@UserID,1000032,@preOperId,-1,@userTrId,@userTrId)
        
        set @NewOpID = SCOPE_IDENTITY()

        update COM_TRAINING_PREPARATORY set OPERID=@NewOpID
            where ID=@prepId
                
         fetch next from cur_COM_CREATE_TRAINING_PREPARATORIES into @prepId, @preOperId
    end

    close cur_COM_CREATE_TRAINING_PREPARATORIES
    deallocate cur_COM_CREATE_TRAINING_PREPARATORIES


END