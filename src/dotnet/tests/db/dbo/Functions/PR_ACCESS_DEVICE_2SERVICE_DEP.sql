CREATE function [dbo].[PR_ACCESS_DEVICE_2SERVICE_DEP] (@DepID int)
returns @res table (ID int)
as 
begin

  --добавляются настройки MT Sharing для дочерних отделов
    declare @childDeps table (ID int)
    insert into @childDeps(ID)
    select ID 
        from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1)

    insert into @res (ID)
    select distinct SDEV.DEVICEID
        from PR_MODELTYPE_SHARING_DEPS SD 
            left join PR_MODELTYPE_SHARING S on SD.MTSHARINGID = S.ID
            left join PR_MODELTYPE_SHARING_DEVICE SDEV on SDEV.MTSHARINGID = S.ID
        where SD.DEPID in(select ID from @childDeps)

return

end