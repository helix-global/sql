CREATE function [dbo].[PR_ACCESS_MODELS_TO_CHANGE] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin
  /* модели изделий, по которым можно менять модель  */

/* 1 свои и по своим типам моделей  */
insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )
union
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where B.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )

/* 2 те, на которые даны разрешения */
insert into @res (ID) 
select distinct A.MODELID 
from PR_DEV_MODEL_CH_SETTINGS_T A with (nolock) 
left join PR_DEV_MODEL_CH_SETTINGS B with (nolock) on B.ID = A.VNESHID
where B.ALLOWTODEP in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )


return

end