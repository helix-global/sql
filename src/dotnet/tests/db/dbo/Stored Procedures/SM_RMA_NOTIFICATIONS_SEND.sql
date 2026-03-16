CREATE PROCEDURE [dbo].[SM_RMA_NOTIFICATIONS_SEND] @UserID int, @aMode int
AS
BEGIN
set nocount on

	declare @ids table (ID int not null, MSGTO nvarchar(1024), DEPID int)
	
	insert into @ids (ID, MSGTO, DEPID)
	select A.ID
	      ,C.EMAIL  
	      ,C.DEPID
	from SM_RMA_NOTIFICATIONS A with (nolock) 
	left join DEF_USERS B with (nolock) on B.ID = A.REQUEST_CR
	left join COM_EMPLOYEE C with (nolock) on C.ID = B.EMPLOYEEID 
	where A.S_S = 1
	  
	  
	if not exists (select * from @ids)
	begin
      set nocount off	
      return
	end  
    
    declare @id int
    declare @To nvarchar(1024)
    declare @dddID int
    
    declare nxx cursor local read_only for 
    select ID, MSGTO, DEPID from @ids where MSGTO is not null
    
    open nxx 
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM nxx INTO @id, @To, @dddID;
        IF @@FETCH_STATUS<>0 BREAK;
        
        declare @mess nvarchar(max)
        /*set @mess = dbo.SM_RMA_NOTIFICATION_TEXT(@id, @UserID, @aMode)*/
        set @mess = dbo.SM_RMA_NOTIFICATION_TEXT2(@id, @UserID, @aMode)
        
        declare @subj nvarchar(1024)
        set @subj = dbo.SM_RMA_NOTIFICATION_SUBJ(@id, @UserID, @aMode)
        
        declare @messID int
        set @messID = null
        
	    declare @additionalCC nvarchar(max)/*KB3730*/
        select @additionalCC = dbo.MSG_DELIVERYTYPE_INDEP_RECIPIENTS(2401,@dddID,1)
        
        INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGCC/*KB3730*/) 
        /*values (1, NEWID(), @To, 'RMA/SC request processed', @mess, GETDATE(), @UserID) */
        values (1, NEWID(), @To, @subj, @mess, GETDATE(), @UserID, @additionalCC/*KB3730*/)
        
        set @messID = @@identity
    
        update SM_RMA_NOTIFICATIONS set MSGID = @messID, S_S = 2000015 /*processed*/ where ID = @id 
        
    END
    close nxx;
    deallocate nxx;    	
	
    update SM_RMA_NOTIFICATIONS set S_S = 2000015 /*processed*/ where ID in (select ID from @ids) and S_S = 1
    
set nocount off
END