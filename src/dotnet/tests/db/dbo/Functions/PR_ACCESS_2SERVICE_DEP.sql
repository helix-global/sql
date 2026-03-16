CREATE function [dbo].[PR_ACCESS_2SERVICE_DEP] (@DepID int)
returns @res table (MODELID int, CUSTOMERID int)
as 
begin


  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1)
  
  insert into @res (MODELID, CUSTOMERID)
  select A.ID,null
  from PR_MODELS A with (nolock) 
  left join PR_MODELTYPE B on B.ID = A.TYPEID
  where A.DEPID=@DepID or B.DEPARTMENTID = @DepID
    union
  select A.ID,null 
  from PR_MODELS A with (nolock) 
  left join PR_SERVICE_DEPARTMENTS B with (nolock) on B.MTID = A.TYPEID
  where B.DEPID=@DepID
    union
  select SM.MODELID,SC.CUSTOMERID
  from PR_MODELTYPE_SHARING_DEPS SD 
  left join PR_MODELTYPE_SHARING S on S.ID=SD.MTSHARINGID
  left join PR_MODELTYPE_SHARING_MODELS SM on SM.MTSHARINGID=S.ID
  left join PR_MODELTYPE_SHARING_CUSTOMERS SC on SC.MTSHARINGID=S.ID
  where SD.DEPID in(select ID from @childDeps)

  return

end