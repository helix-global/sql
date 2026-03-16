CREATE function [dbo].[PR_OPERS_GR_DEP_ACCESS](@aOperGrID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  select @DepID = B.DEPARTMENTID from PR_OPERATIONS_GR B with (nolock) where B.ID = @aOperGrID
                    
                   
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end