create function [dbo].[PR_DEVICE_SRV_PACKAGE_SIZE](@DeviceID int, @SrvPackageID int)
returns int as 
begin
  
  declare @res int
  
  select @res = sum(B.FILESIZE)
  from PR_DEVICE A with (nolock)
  left join PR_MODELS A2 with (nolock) on A2.ID = A.MODELID
  left join PR_MODELTYPE_PARAMS A3 with (nolock) on A3.TYPEID = A2.TYPEID
  cross apply dbo.PR_DEVICE_PARAM_FILES (A.ID,A3.ID) B
  where A.ID = @DeviceID
    and A3.DATATYPE in (7,8,10) /*file,pict,SW&T*/
    and A3.ID in (select BB.PARAMID from CS_SRV_PACKAGE_T BB where BB.VNESHID = @SrvPackageID)   
  
  return @res;  

end