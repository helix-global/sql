CREATE procedure [dbo].[WEB_SAVE_OPER_BOMITEM] @UserID int, @OperID int, @BomName nvarchar(300), @PN nvarchar(20), @SN nvarchar(50), @BatchN nvarchar(100), @Qty decimal(20,10)
as 

set nocount on
declare @err nvarchar(max)
  
declare @MtID int
declare @ss int
declare @checkID int

select @MtID = C.TYPEID
      ,@ss = A.S_S 
      ,@checkID = A.ID
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
where A.ID = @OperID

if @checkID is null
begin
  raiserror('Operation not found.',16,1)
  set nocount off
  return
end

if @ss <> 1000031 /*inprogress*/
begin
  raiserror('Operation cannot be changed out of the "In Progress" state.',16,1)
  set nocount off
  return
end

declare @BomID int

select @BomID = A.ID
from PR_MODELTYPE_BOM A with (nolock)
where A.MTID = @MtID
  and A.NAME = @BomName
  
if @BomID is null
begin
  set @err = 'BOM Item "'+@Bomname+'" not found by item in operation '+str(@OperID)+'.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

/*KB4851*/
if ltrim(rtrim(ISNULL(@SN,''))) = ''
begin
  set @err = 'Serial number for BOM Item "'+@Bomname+'" should have a value.' 
  raiserror(@err,16,1)
  set nocount off
  return
end


declare @PartModelID int
select @PartModelID = A.ID from PR_MODELS A with (nolock) where A.CODE = @PN

if @PartModelID is null
begin
  set @err = 'Part number "'+@PN+'" not found.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

update PR_OPERATION_INSTALL set S_MR = @UserID, S_MDT = getdate(), PARTMODELID = @PartModelID, PARTQUANTITY = @Qty, SN = @SN, BATCHN = @BatchN
where OPERID = @OperID
  and BOMID = @BomID
  
if @@rowcount = 0  
begin
	insert into PR_OPERATION_INSTALL (GID,S_CR,S_CDT,OPERID,BOMID,PARTMODELID,PARTQUANTITY,SN,BATCHN)
	values (newid(),@UserID,getdate(),@OperID,@BomID,@PartModelID,@Qty,@SN,@BatchN)
end

set nocount off