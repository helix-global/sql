CREATE PROCEDURE [dbo].[WEB_OPERATION_COPY_MT] 
  @UserID int, @aMTName nvarchar(300) , @aModelCode nvarchar(16), @aSN nvarchar(50), @aOrder nvarchar(50), @aOperationCode nvarchar(50)
AS
BEGIN
declare @OperIDToCopy int
set @OperIDToCopy = dbo.WEB_FIND_OPERATION_2_COPY_MT(@UserID, @aMTName, @aModelCode, @aSN, @aOrder, @aOperationCode)
  
if isnull(@OperIDToCopy,0) > 0
begin
   declare @pendingOperationId int 
   select @pendingOperationId = A.ID
   from PR_OPERATION A 
   left join PR_OPERATION B on B.DEVICEID = A.DEVICEID 
   where A.ID = @OperIDToCopy and B.S_S in (1000031, 1000032) -- in progress, pending
   /*
   if @pendingOperationId is not null
   begin
	  raiserror('Can`t copy operation, because there are not finished operations.', 15, 0)
	  return
   end
   */
   declare @newID int 
   
   insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,OPLEVEL,OPERGR,Q_IN)
   select newid(),1000032,A.ORDERID,A.DEVICEID,A.OPERTYPEID,getdate(),A.REVOPERID,A.OPLEVEL,A.OPERGR,Q_IN
   from PR_OPERATION A 
   where A.ID = @OperIDToCopy
   set @newID = @@identity
   
   select @newID
end  
END