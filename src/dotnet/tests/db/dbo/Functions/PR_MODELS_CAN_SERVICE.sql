CREATE function [dbo].[PR_MODELS_CAN_SERVICE] (@aDepID int)
returns @res table (ID int)
as 
begin
/* возвращает модели, которые можно запускать в сервис в отделе */

/* 1 свои */
insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.DEPID = @aDepID
   or B.DEPARTMENTID = @aDepID


/* 2 разрешенные типы моделей */

insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_SERVICE_DEPARTMENTS C with (nolock) on C.MTID = A.TYPEID
where C.DEPID = @aDepID


return

end