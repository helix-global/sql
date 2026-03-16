create FUNCTION [dbo].[MSG_LOG_ROWTABLE](@LogID int,@aMode int)
RETURNS nvarchar(max)
AS
BEGIN
   
declare @res nvarchar(max)

select @res = '<tr><td>'+convert(nvarchar,A.DD,108)+'</td><td>'+B.FULLNAME+'</td><td>'+D.CODE+'</td><td>'+A.CAPTION+'</td></tr>'
from DEF_LOG A with (nolock)
left join DEF_USERS B with (nolock) on B.ID = A.S_USERID
left join COM_EMPLOYEE C with (nolock) on C.ID = B.EMPLOYEEID
left join COM_DEPARTMENTS D with (nolock) on D.ID = C.DEPID
where A.ID = @LogID

if LEN(@res) < 1
  return null

return @res

END