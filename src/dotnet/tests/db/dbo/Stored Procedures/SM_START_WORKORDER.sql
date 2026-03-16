CREATE procedure [dbo].[SM_START_WORKORDER] @DocID int, @UserID int
as 
SET nocount on

declare @now datetime = getdate()

declare @rowID int
declare @newOperID int

declare nxx cursor local read_only for 
select A.ID from SM_WORKORDER_TASKS A where A.VNESHID = @DocID and A.OPERID is null
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @rowID;
    IF @@FETCH_STATUS<>0 BREAK;
    
    set @newOperID = null
    
    insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,S_CR,TODOTEXT,Q_IN,USERINPROGRESS,WORKORDERID)
    select newid(),1000032,C.SORDERID,C.DEVICEID,B.OPERFORMID,@now,@UserID,A.REMARK,isnull(D.RESQUANTITY,1),@UserID,C.ID
	from SM_WORKORDER_TASKS A 
	left join SM_SERVICETASKS B with (nolock) on B.ID = A.TASKID
	left join SM_WORKORDER C with (nolock) on C.ID = A.VNESHID
	left join PR_DEVICE D with (nolock) on D.ID = C.DEVICEID
	where A.ID = @rowID
	
	select @newOperID = @@identity
	
	update SM_WORKORDER_TASKS set OPERID = @newOperID where ID = @rowID
    
END
close nxx;
deallocate nxx;



SET nocount off