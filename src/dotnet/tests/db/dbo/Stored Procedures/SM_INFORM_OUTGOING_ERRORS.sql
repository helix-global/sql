CREATE PROCEDURE [dbo].[SM_INFORM_OUTGOING_ERRORS] @UserID int, @aMode int
AS
BEGIN
set nocount on

declare @now datetime = getdate()
declare @searchFrom datetime = dateadd(day,-3,@now)

declare @errs table (ID int)

insert into @errs (ID)
select A.ID
from SM_OUTGOING A with (nolock)
where A.S_S = 1000203 /*err*/
  and A.S_CDT > @searchFrom
  and A.ERRINFOID is null
  and A.ERRINFOID2 is null
  and A.ERRINFODONE is null  /*KB2124*/
  and A.S_CR > 0

declare @id int
declare @msgID int
declare @msg nvarchar(max)
declare @authorID int
declare @boxEmail nvarchar(100)
declare @msgID2 int

declare nxx cursor local read_only for select ID from @errs
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @id;
    IF @@FETCH_STATUS<>0 BREAK;
    
    set @msg = 'Dear All,<br><br>Email from outgoing service call was not sent:<br><br>'
    set @authorID = -1
    
    select @authorID = A.S_CR
          ,@boxEmail = E.EMAIL
          ,@msg = @msg + 'Subject: '+isnull(A.MSGSUBJ,'NA')+'<br>'+
           'Service case: '+isnull(C.ND,'NA')+'<br>'+
           'Requestor: '+isnull(D.NAME,'NA')+'<br>'+
           '<br><b>Error description: '+isnull(cast(A.ERRLOG as nvarchar(max)),'NA')+'</b>'
    from SM_OUTGOING A with (nolock)
    left join SM_SERVICECALL B with (nolock) on B.ID = A.SERVICECALLID
    left join SM_SERVICECASE C with (nolock) on C.ID = B.CASEID
    left join COM_CUSTOMER D with (nolock) on D.ID = C.CUSTID
    left join SM_EMAIL_BOXES E with (nolock) on E.ID = A.BOXID
    where A.ID = @id
    
    set @msg = @msg +'<br><br>This e-mail was created automatically. Please do not respond.<br>Production Database<br>'
    
    exec MSG_SEND_TOUSER @UserID, @authorID, 'EMail from outgoing service call was not sent', @msg
    set @msgID = @@identity
    
    exec MSG_SEND @UserID, @boxEmail, null, 'EMail from outgoing service call was not sent', @msg
    set @msgID2 = @@identity
    
    update SM_OUTGOING set ERRINFODONE = 1, ERRINFOID = @msgID, ERRINFOID2 = @msgID2 where ID = @id
    
END
close nxx;
deallocate nxx;

    
    
set nocount off
END