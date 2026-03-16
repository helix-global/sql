create function [dbo].[COM_WORKTABLE_BY_EMPL](@EmplID int)
returns int as 
begin
   
   declare @res int
   
   select @res = ISNULL(A.PERSONALWT,B.ID)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @EmplID;
        
   return @res 

end