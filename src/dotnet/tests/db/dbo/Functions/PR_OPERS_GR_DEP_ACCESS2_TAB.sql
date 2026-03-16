CREATE function [dbo].[PR_OPERS_GR_DEP_ACCESS2_TAB](@aMode int,@aUser int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  insert into @res (ID)
  select A.ID 
  from PR_OPERATIONS_GR A with (nolock) 
  where dbo.COM_DEP_ACCESS(null,A.DEPARTMENTID,@aMode,@aUser,@aDate) = 1

  /*050315 видеть группы по моделям других отделов, которые разрешено производить в своем*/  
  
  insert into @res (ID)
  select distinct C.OPERGRID
    from PR_MODELS A with (nolock)
     left join PR_MODEL_SHARINGR B with (nolock) on B.MODELID = A.ID
     left join PR_OPERATIONS C with (nolock) on C.MTID = A.TYPEID
    where B.RULETYPE = 1
      and dbo.COM_DEP_ACCESS(null,B.DEPARTMENTID,1,@aUser,@aDate) = 1
      and C.OPERGRID not in (select ID from @res)
    
  return
  
end