CREATE function [dbo].[PR_MODELTYPE_DEP_ACCESS](@aModelTypeID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  select @DepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) 
   where A.ID = @aModelTypeID
  
  return 0
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end