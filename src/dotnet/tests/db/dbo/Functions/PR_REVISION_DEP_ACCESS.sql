create function [dbo].[PR_REVISION_DEP_ACCESS](@aCR int,@aRevisionID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  select @DepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) 
   where A.ID = (select B.TYPEID from PR_MODELS B with (nolock) 
     where B.ID = (select C.MODELID from PR_REVISION C with (nolock) 
        where C.ID = @aRevisionID
                   )
                )
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end