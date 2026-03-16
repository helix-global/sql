create function [dbo].[PR_DEVICE_PARAM_IN_LIST_NAME](@DeviceID int, @ParamN int)
returns nvarchar(300) as 
begin
  declare @prmName nvarchar(300)
  select top 1 @prmName = A.NAME
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = (select M.TYPEID 
                      from PR_MODELS M with (nolock)  
                     where M.ID = (select D.MODELID 
                                     from PR_DEVICE D with (nolock)
                                    where D.ID = @DeviceID))
     and A.USEINLIST = @ParamN
  
  return @prmName
end