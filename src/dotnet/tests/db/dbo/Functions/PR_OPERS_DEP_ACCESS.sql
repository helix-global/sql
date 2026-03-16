CREATE function [dbo].[PR_OPERS_DEP_ACCESS](@aOperTypeID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepIDGr int
  declare @DepIDType int
  
  select @DepIDGr = B.DEPARTMENTID 
        ,@DepIDType = C.DEPARTMENTID 
  from  PR_OPERATIONS A with (nolock) 
  left join PR_OPERATIONS_GR B with (nolock) on B.ID = A.OPERGRID
  left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
  where A.ID = @aOperTypeID

  if dbo.COM_DEP_ACCESS(null,@DepIDGr,@aMode,@aUser,@aDate) = 1
    return 1

  if dbo.COM_DEP_ACCESS(null,@DepIDType,@aMode,@aUser,@aDate) = 1
    return 1
    
  return 0
end