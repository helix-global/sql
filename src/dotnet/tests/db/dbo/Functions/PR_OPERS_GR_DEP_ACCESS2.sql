CREATE function [dbo].[PR_OPERS_GR_DEP_ACCESS2](@aOperGrID int, @aDepID int, @aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  
  if @aDepID is not null
     set @DepID = @aDepID
  else
     select @DepID = B.DEPARTMENTID from PR_OPERATIONS_GR B with (nolock) where B.ID = @aOperGrID
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  if @res = 1
    return 1
    
  /*050315 видеть группы по моделям других отделов, которые разрешено производить в своем*/  
  
  if exists(select A.ID 
              from PR_MODELS A with (nolock)
         left join PR_MODEL_SHARINGR B with (nolock) on B.MODELID = A.ID
         left join PR_OPERATIONS C with (nolock) on C.MTID = A.TYPEID
             where C.OPERGRID = @aOperGrID
               and B.RULETYPE = 1
               and dbo.COM_DEP_ACCESS(null,B.DEPARTMENTID,1,@aUser,@aDate) = 1
               )
   return 1               
    
  return 0  
end