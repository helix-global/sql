CREATE function [dbo].[PR_MODELTYPE_CAN_USEINDESIGN] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin

/*выдает типы моделей (в т.ч. чужие) для которых можно создавать свои объекты (формы, отчеты, карты ...)*/

insert into @res (ID)
select ID 
from PR_MODELTYPE A with (nolock)
where A.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,5,@aDate))
union
select distinct C.TYPEID
 from PR_MODEL_SHARINGR B with (nolock)
 left join PR_MODELS C with (nolock) on C.ID = B.MODELID
 left join PR_MODELTYPE MT with (nolock) on MT.ID = C.TYPEID
where B.RULETYPE = 2
  and MT.DEPARTMENTID = C.DEPID
  and B.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate))
union 
select A.ID
from PR_MODELTYPE A with (nolock)
where dbo.DEF_F_ACCESS2(A.ARC,null,2000017/*designer*/,@aDate,@aUserID,0) = 1
union 
select distinct G.VNESHID
from PR_MODELTYPE_SHARINGR G with (nolock)
where G.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate))
  and G.RULETYPE = 2

return 

end