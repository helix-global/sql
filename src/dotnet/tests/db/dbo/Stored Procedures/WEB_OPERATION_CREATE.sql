CREATE PROCEDURE [dbo].[WEB_OPERATION_CREATE] 
  @UserID int, @DeviceId int, @OperationFormId int
AS
BEGIN

   insert into PR_OPERATION (GID,S_S,S_CDT,ORDERID,DEVICEID,OPERTYPEID)
   select newid(),1000032,getdate(),A.ORDERID,A.ID,@OperationFormId
   from PR_DEVICE A 
   where A.ID = @DeviceId
   
   select @@identity

END