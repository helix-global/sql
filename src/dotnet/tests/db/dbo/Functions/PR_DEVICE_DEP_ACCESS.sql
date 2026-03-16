

CREATE function [dbo].[PR_DEVICE_DEP_ACCESS](@aCR int,@aModelID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  select @DepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) 
   where A.ID = (select B.TYPEID from PR_MODELS B with (nolock) where B.ID = @aModelID)
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,4,@aUser,@aDate)
  return @res
end