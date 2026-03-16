CREATE function [dbo].[PR_DEVICE_DEP_ACCESS3](@aModelTypeID int,@aUser int,@aDate datetime)
returns int as 
begin

  declare @DepID int
  select @DepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) where A.ID = @aModelTypeID

  return dbo.COM_DEP_ACCESS(null,@DepID,4,@aUser,@aDate)

end