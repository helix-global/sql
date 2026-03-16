CREATE function [dbo].[PR_DEVICE_PARAM_FILES_NOBLOB] (@aDeviceID int,@aParamID int)
returns @res table (ID int,FILENAME nvarchar(255),FILEDATE datetime, FILESIZE int, FSOURCE int, FILEPREVIEW image)
as 
begin


  declare @ParamKind int
  declare @ParamDataType int
  declare @swVerID int
  declare @DeviceRevisionID int
  
  select @ParamKind = A.PARAMKIND
        ,@ParamDataType = A.DATATYPE
  from PR_MODELTYPE_PARAMS A with (nolock)
  where A.ID = @aParamID
  
  if @ParamDataType = 10 /*SW&T*/ and @ParamKind = 2 /*ref.value*/
  begin
  
    select @swVerID = A.SWVERSIONID 
    from PR_DEVICE_SW A with (nolock)
    where A.DEVICEID = @aDeviceID
      and A.SWID = @aParamID
      
    insert into @res (ID,FILENAME,FILEDATE,FILESIZE,FSOURCE,FILEPREVIEW) 
    select A.ID,A.FILENAME,A.FILEDATE,A.FILESIZE,1,A.FILEPREVIEW
    from SW_TOOL_VER_FILES A with (nolock)
    where A.VERID = @swVerID
      and A.STID is null
    
    insert into @res (ID,FILENAME,FILEDATE,FILESIZE,FSOURCE,FILEPREVIEW) 
    select A.ID,BB.FILENAME,BB.FILEDATE,BB.FILESIZE,1,BB.FILEPREVIEW
    from SW_TOOL_VER_FILES A with (nolock)
    left join SW_STORAGE BB with (nolock) on BB.ID = A.STID
    where A.VERID = @swVerID
      and A.STID is not null
    
  
  end
  else if @ParamDataType in (7,8) /*file,picture*/ and @ParamKind = 2 /*ref.value*/
  begin
  
    select @DeviceRevisionID = A.REVID
    from PR_DEVICE A with (nolock) 
    where A.ID = @aDeviceID
    
    insert into @res (ID,FILENAME,FILEDATE,FILESIZE,FSOURCE,FILEPREVIEW) 
    select top 1 A.ID,A.FILENAME,A.FILEDATE,A.FILESIZE,2,FILEPREVIEW
    from PR_REV_FILES A with (nolock)
    where A.REVISIONID = @DeviceRevisionID
      and A.FILENAME = dbo.PR_DEVICE_PARAM(@aDeviceID, @aParamID)
    order by ID desc

  
  end
  else if @ParamDataType in (7,8) /*file,picture*/ and @ParamKind = 1 /*value*/
  begin
  
      declare @fname nvarchar(255)
      declare @operid int
  
	  select top 1 @fname = cast(A.PVALUE as nvarchar(255))
	            ,  @operid = A.OPERID
	  from PR_OPERATION_PARAMS A with (nolock)
	  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	  where B.DEVICEID = @aDeviceID
		and A.PARAMID = @aParamID
		and B.S_S in (1000013,1000019,1000116)
	  order by B.ID desc 
	  
      insert into @res (ID,FILENAME,FILEDATE,FILESIZE,FSOURCE,FILEPREVIEW) 
      select top 1 A.ID,A.FILENAME,A.FILEDATE,A.FILESIZE,3,FILEPREVIEW
      from PR_OPERATION_FILES A with (nolock)
      where A.OPERATIONID = @operid
        and A.FILENAME = @fname
      order by ID desc
	     
  
  end


  return

end