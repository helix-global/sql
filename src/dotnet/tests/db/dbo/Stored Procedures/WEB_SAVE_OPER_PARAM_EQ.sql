CREATE procedure [dbo].[WEB_SAVE_OPER_PARAM_EQ] @UserID int, @OperID int, @Name nvarchar(300), @EquipmentSN nvarchar(100), @EquipmentModelCode nvarchar(300)
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


declare @PrmID int
declare @PrmDataType int
declare @PrmKind int

select @PrmID = A.ID
      ,@PrmDataType = A.DATATYPE
      ,@PrmKind = A.PARAMKIND
from PR_MODELTYPE_PARAMS A with (nolock)
where A.TYPEID = @MtID
  and A.NAME = @Name
  
if @PrmID is null
begin
  set @err = 'Parameter "'+@Name+'" not found by item in operation '+str(@OperID)+'.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if @PrmKind = 2
begin
  set @err = 'Cannot save values to reference parameter "'+@Name+'".' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if @PrmDataType <> 13
begin
  set @err = 'Cannot use this method for any parameters except "Equipment" ones.' 
  raiserror(@err,16,1)
  set nocount off
  return
end


declare @saveVal sql_variant
declare @indexedValue nvarchar(250)

declare @eqID int   

if @PrmDataType in (13)  /*equipment*//*KB3346*/
begin

  
  select top 1 @eqID = E.ID 
    from EQ_EQUIPMENT E with(nolock) 
    left join EQ_MODELS B with(nolock) on B.ID = E.EQMODELID
   where E.SN = @EquipmentSN
     and E.EQMODELID in (select ID from dbo.WEB_GET_EQ_MODELS_4_PARAM(@OperID, @PrmID))
     and B.CODE = @EquipmentModelCode
   
  if @eqID is null  
  begin
    
    set @err = 'Equipment with serial number  "'+@EquipmentSN+'" not found.' 
	raiserror(@err,16,1)
	set nocount off
	return
  
  end
end


if (@PrmID in (select B.PRMID from PR_IMP_INDEX_PRMS B))
begin
  set @indexedValue = upper(@EquipmentSN)
end

update PR_OPERATION_PARAMS 
  set S_MR = @UserID
     ,S_MDT = getdate()
     ,PVALUE = @EquipmentSN
     ,INDEX_STR = @indexedValue
     ,EQID = @eqID
where OPERID = @OperID 
  and PARAMID = @PrmID

if @@rowcount = 0 
begin
  insert into PR_OPERATION_PARAMS (GID,S_CR,S_CDT,OPERID,PARAMID,PVALUE,INDEX_STR,EQID)
  values (newid(),@UserID,getdate(),@OperID,@PrmID,@EquipmentSN,@indexedValue,@eqID)
end  

set nocount off