CREATE procedure [dbo].[WEB_SAVE_OPER_EXT_PARAM] @UserID int, @OperID int, @Name nvarchar(300), @BomI1 nvarchar(300), @BomI2 nvarchar(300),@BomI3 nvarchar(300),  @ParamValue nvarchar(max), @ParamDec float, @ParamInt int, @ParamDT datetime
as 

set nocount on
declare @err nvarchar(max)
  
declare @MtID int
declare @ss int
declare @checkID int
declare @deviceID int

select @MtID = C.TYPEID
      ,@ss = A.S_S 
      ,@checkID = A.ID
      ,@deviceID = A.DEVICEID
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

declare @BomItem1 int
declare @BomPositionID1 int

set @BomItem1 = dbo.PR_DEVICE_BMITEM_BYNAME(@deviceID,@BomI1)
select @BomPositionID1 = A.ID
from PR_MODELTYPE_BOM A with (nolock) 
where A.MTID = @MtID
  and A.NAME = @BomI1
  
if @BomItem1 is null  
begin
  raiserror('Item from first BOM position not found to store external parameter value.',16,1)
  set nocount off
  return
end
if @BomPositionID1 is null  
begin
  raiserror('First BOM position not found to store external parameter value.',16,1)
  set nocount off
  return
end

declare @BomItem2 int
declare @BomPositionID2 int
declare @MtID2 int

if nullif(@BomI2,'') is not null 
begin

	set @BomItem2 = dbo.PR_DEVICE_BMITEM_BYNAME(@BomItem1,@BomI2)
	
	select @BomPositionID2 = C.ID
	      ,@MtID2 = B.TYPEID
    from PR_DEVICE A with (nolock) 
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    left join PR_MODELTYPE_BOM C with (nolock) on C.MTID = B.TYPEID
    where A.ID = @BomItem2
      and C.NAME = @BomI2	

	if @BomItem2 is null  
	begin
	  raiserror('Item from second BOM position not found to store external parameter value.',16,1)
	  set nocount off
	  return
	end
	if @BomPositionID2 is null  
	begin
	  raiserror('Second BOM position not found to store external parameter value.',16,1)
	  set nocount off
	  return
	end


end

declare @BomItem3 int
declare @BomPositionID3 int
declare @MtID3 int

if nullif(@BomI3,'') is not null 
begin

	set @BomItem3 = dbo.PR_DEVICE_BMITEM_BYNAME(@BomItem2,@BomI3)
	select @BomPositionID3 = C.ID
	      ,@MtID3 = B.TYPEID
    from PR_DEVICE A with (nolock) 
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    left join PR_MODELTYPE_BOM C with (nolock) on C.MTID = B.TYPEID
    where A.ID = @BomItem3
      and C.NAME = @BomI3	

	if @BomItem3 is null  
	begin
	  raiserror('Item from third BOM position not found to store external parameter value.',16,1)
	  set nocount off
	  return
	end
	if @BomPositionID3 is null  
	begin
	  raiserror('Third BOM position not found to store external parameter value.',16,1)
	  set nocount off
	  return
	end

end


declare @PrmID int
declare @PrmDataType int
declare @PrmKind int

select @PrmID = A.ID
      ,@PrmDataType = A.DATATYPE
      ,@PrmKind = A.PARAMKIND
from PR_MODELTYPE_PARAMS A with (nolock)
where A.TYPEID = coalesce(@MtID3,@MtID2,@MtID)
  and A.NAME = @Name
  and A.ALLOWEDIT = 1
  
if @PrmID is null
begin
  set @err = 'Parameter "'+@Name+'" not found by external item in operation '+str(@OperID)+'.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if @PrmKind = 2
begin
  set @err = 'Cannot save external values to reference parameter "'+@Name+'".' 
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

if (@PrmID in (select B.PRMID from PR_IMP_INDEX_PRMS B with (nolock)))
begin
  set @indexedValue = upper(CAST(@saveVal AS nvarchar(250)))
end

declare @TargetDeviceID int
set @TargetDeviceID = coalesce(@BomItem3,@BomItem2,@BomItem1)

update PR_OPERATION_EXT_PARAMS 
  set S_MR = @UserID
     ,S_MDT = getdate()
     ,PVALUE = @saveVal
     ,INDEX_STR = @indexedValue
     ,DEVICEID = @TargetDeviceID
     ,BOMID = @BomItem1
     ,BOMID2 = isnull(@BomItem2,0)
     ,BOMID3 = isnull(@BomItem3,0)
where OPERID = @OperID 
  and PARAMID = @PrmID

if @@rowcount = 0 
begin
  insert into PR_OPERATION_EXT_PARAMS (GID,S_CR,S_CDT,OPERID,PARAMID,PVALUE,INDEX_STR,DEVICEID,BOMID,BOMID2,BOMID3)
  values (newid(),@UserID,getdate(),@OperID,@PrmID,@saveVal,@indexedValue,@TargetDeviceID,@BomItem1,isnull(@BomItem2,0),isnull(@BomItem3,0))
end  

set nocount off