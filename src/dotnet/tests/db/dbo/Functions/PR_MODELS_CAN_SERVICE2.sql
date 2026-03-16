CREATE function [dbo].[PR_MODELS_CAN_SERVICE2] (@aDepID int)
returns @res table (MODELID int, CUSTOMERID int)
as 
begin
/* возвращает модели, которые можно запускать в сервис в отделе */

  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@aDepID,1)

/* 1 свои */
insert into @res (MODELID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.DEPID = @aDepID
   or B.DEPARTMENTID = @aDepID


/* 2 разрешенные типы моделей */

insert into @res (MODELID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_SERVICE_DEPARTMENTS C with (nolock) on C.MTID = A.TYPEID
where C.DEPID = @aDepID

/* 3 разрешенные типы моделей/заказчиков */

insert into @res (MODELID, CUSTOMERID)
select A.ID,null
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.DEPID = @aDepID
   or B.DEPARTMENTID = @aDepID
  union
select A.ID,null
from PR_MODELS A with (nolock) 
left join PR_SERVICE_DEPARTMENTS C with (nolock) on C.MTID = A.TYPEID
where C.DEPID = @aDepID
  union
select SM.MODELID,SC.CUSTOMERID
from PR_MODELTYPE_SHARING_DEPS SD with (nolock)
left join PR_MODELTYPE_SHARING S with (nolock) on S.ID=SD.MTSHARINGID
left join PR_MODELTYPE_SHARING_MODELS SM with (nolock) on SM.MTSHARINGID=S.ID
left join PR_MODELTYPE_SHARING_CUSTOMERS SC with (nolock) on SC.MTSHARINGID=S.ID
where SD.DEPID in(select ID from @childDeps)

return

end