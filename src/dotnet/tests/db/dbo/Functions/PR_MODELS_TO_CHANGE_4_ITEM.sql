CREATE function [dbo].[PR_MODELS_TO_CHANGE_4_ITEM] (@aUserID int, @aItemID int, @aDate datetime)
returns @res table (ID int)
as 
begin
  /* модели на которые можно поменять модель изделия @aItemID*/

declare @mtid int
declare @oldModelID int

select @mtid = B.TYPEID
      ,@oldModelID = A.MODELID
from PR_DEVICE A with (nolock) 
left join PR_MODELS B on B.ID = A.MODELID
where A.ID = @aItemID


/* 1 свои и своих типов*/
insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )
  and A.TYPEID = @mtid
union
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.TYPEID = @mtid
  and B.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )
  

/* 2 те, на которые можно менять в соотв с разрешениями */
insert into @res (ID) 
select distinct A.TOMODELID 
from PR_DEV_MODEL_CH_SETTINGS_T A with (nolock) 
left join PR_DEV_MODEL_CH_SETTINGS B with (nolock) on B.ID = A.VNESHID
where B.ALLOWTODEP in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,4/*view devices*/,@aDate) )
  and A.MODELID = @oldModelID

return

end