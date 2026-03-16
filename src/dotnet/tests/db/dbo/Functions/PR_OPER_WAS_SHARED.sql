create function [dbo].PR_OPER_WAS_SHARED(@aOperID int,@aEmplID int)
returns int
as
begin
  if exists (select A.ID from PR_OPERATION_TIME A with (nolock) 
              where A.OPERID = @aOperID
                and A.EMPID <> @aEmplID )
     return 1;
                     
  return null;
end;