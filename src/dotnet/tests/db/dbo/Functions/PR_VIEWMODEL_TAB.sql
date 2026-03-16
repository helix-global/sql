CREATE function [dbo].[PR_VIEWMODEL_TAB](@aUser int,@aDate datetime)
returns @res table (ID int) as 
begin

  declare @EmpID int
  declare @DepID int
  
  select @EmpID = A.EMPLOYEEID
        ,@DepID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID 
  where A.ID = @aUser
  

  insert into @res(ID)
  select ID from dbo.PR_ACCESS_MODELS(@aUser,1,@aDate)
  union
  select A.ID from PR_MODELS A with (nolock) where A.SHARETOALL = 1
  union 
  select A.ID 
    from PR_MODELS A with (nolock) 
    left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
    where isnull(A.SHARETOALL,0) = 0
      and A.DEPID <> B.DEPARTMENTID
      --and B.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,1,@aDate))
      and dbo.COM_DEP_ACCESS2(B.DEPARTMENTID,1,@aUser,@aDate)  = 1
  union
  select A.MODELID 
  from PR_MODEL_SHARINGR A with (nolock)
  where A.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,3,@aDate))

    
  return 
end