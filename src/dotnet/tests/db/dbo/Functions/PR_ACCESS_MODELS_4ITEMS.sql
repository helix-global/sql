CREATE function [dbo].[PR_ACCESS_MODELS_4ITEMS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

/*
27.08.18 скопирована из PR_ACCESS_MODELS и добавлены модели из PR_ACCESS_MODELS_2SERVICE
*/

declare @deps table (ID int)
insert into @deps (ID)
select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.DEPID in (select ID from @deps)
   or B.DEPARTMENTID in (select ID from @deps )

if @aMode = 4 /*devices*/
begin
  /*09.02.2017 пришлось срочно давать права видеть фрязинские изделия отделу FCM-MM не по подразделению MMC_R, а по типу модели "Cladding mode absorber"*/
  
  insert into @res (ID)
  select A.ID from PR_MODELS A with (nolock)
  where A.TYPEID in (select B.ID from PR_MODELTYPE B with (nolock) where dbo.DEF_F_ACCESS2(B.ARC,B.S_CR,1000268,@aDate,@aUserID,0) = 1)
    and not exists (select C.ID from @res C where C.ID = A.ID)
    
  /* по виртуальной группе доступа "Model Type Owner" */
  insert into @res (ID) 
  select A.ID 
    from PR_MODELS A with (nolock) 
    left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
    left join COM_DEPARTMENTS C with (nolock) on C.ID = A.DEPID
  where A.DEPID <> B.DEPARTMENTID
    and B.DEPARTMENTID in (select ID from @deps)
    and dbo.DEF_FUNC_ACCESS(C.ARC,1000099/*view dep devices*/,'MTOwn',@aDate) = 1
    and not exists (select C.ID from @res C where C.ID = A.ID)
    
  
end

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
left join PR_SERVICE_DEPARTMENTS B with (nolock) on B.MTID = A.TYPEID
where B.DEPID in (select ID from @deps )

return

end