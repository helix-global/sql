CREATE function [dbo].[WEB_DEVICE_FINDINDEX](@aParamName nvarchar(300),@aMTName nvarchar(250), @ParamValue nvarchar(max), @ParamDec float, @ParamInt int, @ParamDate datetime)
returns @res table (ID int)
begin
  declare @PrmID int
  declare @DataType int
  declare @mtid int
  
  select @PrmID = B.ID
        ,@DataType = B.DATATYPE
        ,@mtid = A.ID
  from PR_MODELTYPE A with (nolock) 
  left join PR_MODELTYPE_PARAMS B with (nolock) on B.TYPEID = A.ID
  where A.NAME = @aMTName
    and B.NAME = @aParamName
  
  if @PrmID is null
    return
    
 
  declare @index nvarchar(250)
  declare @indexUC nvarchar(250)
  
  if @ParamInt is not null
     set @index = upper(CAST(@ParamInt AS nvarchar(250)))
  else if @ParamDate is not null
     set @index = upper(CAST(@ParamDate AS nvarchar(250)))
  else if @ParamDec is not null
     set @index = upper(CAST(@ParamDec AS nvarchar(250)))
  else
     set @index = CAST(@ParamValue AS nvarchar(250))
     
  set @indexUC = upper(@index)
  
  insert into @res
  select B.DEVICEID 
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARAMID = @PrmID
    and A.INDEX_STR = @indexUC
    
  insert into @res
  select A.DEVICEID 
  from PR_OPERATION_EXT_PARAMS A with (nolock)
  where A.PARAMID = @PrmID
    and A.INDEX_STR = @indexUC
    
  insert  into @res
  select I.DEVICEID 
  from PR_DEVICE_IN_VALUES I with (nolock)
  where I.PARAMID = @PrmID
    and I.INDEX_STR = @indexUC

  delete from @res
  where cast(dbo.PR_DEVICE_PARAM(ID, @PrmID) as nvarchar(250)) <> @index
    
  return 
end