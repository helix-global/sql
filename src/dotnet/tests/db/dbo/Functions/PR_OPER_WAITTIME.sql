CREATE function [dbo].[PR_OPER_WAITTIME](@aOperID int,@aOperState int, @aCDT datetime)
returns int
as
begin
  if @aOperState not in (1000031,1000032) /*in progress, pending*/
     return null
  return datediff(MINUTE,@aCDT,getdate())
end;