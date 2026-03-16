CREATE procedure [dbo].[PR_CREATE_NEW_BATCH_ONSTART_IFNEED]  @aOperID int, @UserID int
as 
SET nocount on

declare @AccMode int
declare @orderType int
declare @orderID int
declare @deviceID int
declare @newDevID int
declare @qTopParent int
declare @now datetime
declare @crFlag int

set @now = getdate()

select @deviceID = A.DEVICEID
      ,@orderType = F.ORDERTYPE
      ,@AccMode = isnull(D.ACCMODE,0)
      ,@orderID = A.ORDERID
      ,@qTopParent = B.Q_TOPPARENT
      ,@crFlag = isnull(G.STARTNEWBATCH,0)
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
left join PR_MODELTYPE D with (nolock) on D.ID = C.TYPEID
left join PR_PRORDER F with (nolock) on F.ID = A.ORDERID
left join PR_MAP_OPER G with (nolock) on G.ID = A.REVOPERID
where A.ID = @aOperID


if @crFlag = 1 and @AccMode in (4,5) and @orderType = 0
begin

   if exists (select A.ID from PR_DEVICE A with (nolock) where Q_CREATEDBYOPERSTART = @aOperID) 
     return

   declare @nextSuff int
   declare @newSN nvarchar(50)
   
   if @AccMode = 4
   begin
      select @nextSuff = max(isnull(A.Q_SUFF,0)) from PR_DEVICE A with (nolock) where A.ORDERID = @orderID and A.Q_PARENT = @deviceID
      select @newSN = A.SN from PR_DEVICE A with (nolock) where A.ID = @deviceID
   end   
   else if @AccMode = 5
   begin
      select @nextSuff = max(isnull(A.Q_SUFF,0)) from PR_DEVICE A with (nolock) where A.ORDERID = @orderID 
      select @newSN = A.SN from PR_DEVICE A with (nolock) where A.ID = isnull(@qTopParent,@deviceID)
   end   
   
   set @nextSuff = isnull(@nextSuff,0) + 1
   set @newSN = @newSN + '-'+ltrim(rtrim(str(@nextSuff)))
   
   
   insert into PR_DEVICE (GID,S_S,S_CR,S_CDT,ORDERID,MODELID,REVID,MAPID,SORDERID
                          ,ORDERROWID,Q_SUFF,Q_PARENT,Q_OPERID,SN,Q_TOPPARENT
                          ,URGENCY,PRRESTTIME,Q_CREATEDBYOPERSTART)
   select newid(),A.S_S,@UserID,@now,A.ORDERID,A.MODELID,A.REVID,A.MAPID,A.SORDERID
          ,A.ORDERROWID,@nextSuff,A.ID,@aOperID,@newSN,isnull(A.Q_TOPPARENT,A.ID)
          ,URGENCY,PRRESTTIME,@aOperID
   from PR_DEVICE A
   where A.ID = @deviceID
   
   set @newDevID = @@identity
   
   insert into PR_PARENT_OPERATION (DEVICEID,OPERID)
   select @newDevID,M.ID
   from (
   select A.ID
   from PR_OPERATION A with (nolock)
   where A.DEVICEID = @deviceID
     and A.ORDERID = @orderID
     ) M
     where M.ID < @aOperID 
     
   insert into PR_PARENT_OPERATION (DEVICEID,OPERID)
   select @newDevID,A.OPERID
   from PR_PARENT_OPERATION A with (nolock)
   where A.DEVICEID = @deviceID
   
   insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CR,S_CDT,REVOPERID,OPLEVEL,Q_IN,Q_PARENT)
   select newid(),1000032,A.ORDERID,@newDevID,A.OPERTYPEID,A.S_MR,@now,A.REVOPERID,A.OPLEVEL,Q_IN,@aOperID 
   from PR_OPERATION A 
   where A.ID = @aOperID
   
end

  
SET nocount off