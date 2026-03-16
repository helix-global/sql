create function [dbo].[PR_OPER_JOINED](@aOperID int,@aUserID int)
returns int
as
begin
  if exists (select A.ID from PR_OPERATION_TIME A with (nolock) 
              where A.OPERID = @aOperID
                and A.USERID = @aUserID
                and A.DEND is null)
     return 1;
                     
  return null;
end;