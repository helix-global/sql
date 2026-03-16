CREATE function [dbo].[PR_ACCESS_CUSTOMERS_2SERVICE] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

declare @deps table (ID int)
insert into @deps (ID)
select ID 
from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 
  
  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select a.ID 
    from @deps d cross apply
        dbo.COM_GETCHILD_DEPARTMENTS2(d.ID,1) a

insert into @res (ID)
select distinct SC.CUSTOMERID
from PR_MODELTYPE_SHARING_DEPS SD 
left join PR_MODELTYPE_SHARING S on SD.MTSHARINGID = S.ID
left join PR_MODELTYPE_SHARING_CUSTOMERS SC on SC.MTSHARINGID = S.ID
where SD.DEPID in (select ID from @childDeps)

return

end