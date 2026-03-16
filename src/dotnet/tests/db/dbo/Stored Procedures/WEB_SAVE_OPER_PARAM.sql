CREATE procedure [dbo].[WEB_SAVE_OPER_PARAM] @UserID int, @OperID int, @Name nvarchar(300), @ParamValue nvarchar(max), @ParamDec float, @ParamInt int, @ParamDT datetime
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


declare @saveVal sql_variant
declare @indexedValue nvarchar(250)

if @PrmDataType in (2)
begin
  set @saveVal = @ParamDT
end
else if @PrmDataType in (9)
begin
  set @saveVal = cast(@ParamDT as date)
end
else if @PrmDataType in (3)
begin
  set @saveVal = @ParamDec
end
else if @PrmDataType in (4)
begin
  set @saveVal = @ParamInt
end  
else if @PrmDataType in (12)
begin
  set @saveVal = cast(@ParamDT as time)
end  
else
  set @saveVal = cast(@ParamValue as nvarchar(1024)) /*!!!!!! есть ограничения */

declare @eqID int   

if @PrmDataType in (13)  /*equipment*//*KB3346*/
begin

  declare @eqSN nvarchar(100)
  set @eqSN = cast(@ParamValue as nvarchar(100))
  
  select top 1 @eqID = E.ID 
    from EQ_EQUIPMENT E with(nolock) 
   where E.SN = @eqSN
     and E.EQMODELID in (select ID from dbo.WEB_GET_EQ_MODELS_4_PARAM(@OperID, @PrmID))
   
  if @eqID is null  
  begin
    
    set @err = 'Equipment with serial number  "'+@eqSN+'" not found.' 
	raiserror(@err,16,1)
	set nocount off
	return
  
  end
end


if (@PrmID in (select B.PRMID from PR_IMP_INDEX_PRMS B))
begin
  set @indexedValue = upper(CAST(@saveVal AS nvarchar(250)))
end

update PR_OPERATION_PARAMS 
  set S_MR = @UserID
     ,S_MDT = getdate()
     ,PVALUE = @saveVal
     ,INDEX_STR = @indexedValue
     ,EQID = @eqID
where OPERID = @OperID 
  and PARAMID = @PrmID

if @@rowcount = 0 
begin
  insert into PR_OPERATION_PARAMS (GID,S_CR,S_CDT,OPERID,PARAMID,PVALUE,INDEX_STR,EQID)
  values (newid(),@UserID,getdate(),@OperID,@PrmID,@saveVal,@indexedValue,@eqID)
end  

set nocount off