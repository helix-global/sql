CREATE function [dbo].[PR_VIEWMODEL](@aModID int,@aUser int,@aDate datetime)
returns int as 
begin

  if dbo.PR_MODELS_DEP_ACCESS(null,@aModID,1,@aUser,@aDate) = 1
    return 1


  declare @EmpID int
  declare @DepID int
  
  select @EmpID = A.EMPLOYEEID
        ,@DepID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B on B.ID = A.EMPLOYEEID 
  where A.ID = @aUser
  
  
  declare @ModelDep int
  declare @AllShare int
  select @ModelDep = B.DEPARTMENTID
        ,@AllShare = isnull(A.SHARETOALL,0)
  from PR_MODELS A with (nolock)
  left join PR_MODELTYPE B on B.ID = A.TYPEID
  where A.ID = @aModID
   
  /*модель принадлежит отделу*/
  if (@DepID = @ModelDep)
    return 1
    
  if (@AllShare = 1)
    return 1
    
  if exists (select H.ID from PR_MODEL_SHARINGR H with (nolock) where H.MODELID = @aModID and H.DEPARTMENTID = @DepID and H.RULETYPE = 0)
    return 1
  
  declare @tmp int   
  select @tmp = dbo.DEF_F_ACCESS(A.ARC,null,1000040,@aDate,@aUser,0) 
  from COM_DEPARTMENTS A with (nolock) where A.ID = @ModelDep
  if @tmp = 1 
    return 1

  return 0;
end