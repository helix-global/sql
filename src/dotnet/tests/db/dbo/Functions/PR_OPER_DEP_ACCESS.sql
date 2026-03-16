CREATE function [dbo].[PR_OPER_DEP_ACCESS](@aOperID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  if dbo.PR_OPER_QUALIFICATION(@aOperID,@aUser,getdate()) = 1
     return 1
     
  declare @DepID int
  select @DepID = B.DEPID from PR_MODELS B with (nolock) 
     where B.ID = (select C.MODELID from PR_DEVICE C with (nolock) 
       where C.ID = (select D.DEVICEID from PR_OPERATION D with (nolock) 
         where D.ID = @aOperID
                    )
                   )
                  
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end