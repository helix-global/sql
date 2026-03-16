CREATE function [dbo].[SYNC2_MODELS_BACK] (@aRemoteCode nvarchar(10),@aSourceCode nvarchar(10))
returns @res table (ID int)
as 
begin

/*
модели, которые нужно "вернуть" в тот location, который предоставил типы моделей
в @aRemoteCode - location моделей
в @aSourceCode - location типов моделей 
*/

insert into @res (ID)
select A.ID 
  from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID   
where A.DEPID in (select LL.ID from dbo.COM_GETREMOTE_DEPARTMENTS(@aRemoteCode) LL)
  and B.DEPARTMENTID in (select LF.ID from dbo.COM_GETREMOTE_DEPARTMENTS(@aSourceCode) LF)



return

end