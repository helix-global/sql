create function [dbo].[PR_DEVICE_PARAM_FILEID](@DeviceID int, @ParamID int)
returns int as 
begin
/*
  Возвращает ID файла из PR_OPERATION_FILES 
*/
  declare @fileID int
  declare @fileName sql_variant
  declare @operID int

  select top 1 @fileName = A.PVALUE 
              ,@operID = B.ID
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where B.DEVICEID = @DeviceID
	and A.PARAMID = @ParamID
	and B.S_S in (1000013,1000019,1000116)
  order by B.ID desc


  if (@operID is not null)
  begin
  
     select top 1 @fileID = A.ID
     from PR_OPERATION_FILES A with (nolock)
     where A.OPERATIONID = @operID
       and A.PARAMID = @ParamID
     order by A.ID desc
     
     
     if @fileID is null
     begin
     
        select top 1 @fileID = A.ID
          from PR_OPERATION_FILES A with (nolock)
         where A.OPERATIONID = @operID
           and A.FILENAME = @fileName
         order by A.ID desc
     
     end
  
  end
  
  return @fileID
end