
CREATE function [dbo].[PR_MODELS_DEP_ACCESS](@aCR int,@aModelID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  select @DepID = B.DEPID from PR_MODELS B with (nolock) where B.ID = @aModelID
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end