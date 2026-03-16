CREATE function [dbo].[WEB_CHECKPARAM] (@DeviceID int, @MtID int, @Name nvarchar(300), @ParamValue nvarchar(max), @ParamDec float, @ParamInt int, @ParamDT datetime)
returns int
as 
begin

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
	  return -1

	if @PrmDataType in (2)
	begin
	  if dbo.PR_DEVICE_PARAM_DATE(@DeviceID,@PrmID) = @ParamDT
	    return 1
	end
	else if @PrmDataType in (9)
	begin
	  if dbo.PR_DEVICE_PARAM_DATE(@DeviceID,@PrmID) = @ParamDT
	    return 1
	end
	else if @PrmDataType in (3)
	begin
	  if dbo.PR_DEVICE_PARAM_FLOAT(@DeviceID,@PrmID) = @ParamDec
	    return 1
	end
	else if @PrmDataType in (4)
	begin
	  if dbo.PR_DEVICE_PARAM_INT(@DeviceID,@PrmID) = @ParamInt
	    return 1
	end  
	else if @PrmDataType in (12)
	begin
	  if dbo.PR_DEVICE_PARAM_DATE(@DeviceID,@PrmID) = @ParamDT
	    return 1
	end  
	else
	begin
	  if dbo.PR_DEVICE_PARAM_STR(@DeviceID,@PrmID) = @ParamValue
	    return 1
    end
     
   return -2  

end