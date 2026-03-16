CREATE FUNCTION [dbo].[MSG_OPERATION_FAILURE_TEXT](@OperID int)
RETURNS nvarchar(max)
AS
BEGIN
   
declare @res nvarchar(max)

declare @OperName nvarchar(400)
declare @SN nvarchar(50)
declare @OrderN nvarchar(50)
declare @userName nvarchar(200)
declare @ErrText nvarchar(200)

select @OperName = C.NAME 
      ,@SN = B.SN
      ,@OrderN = isnull(O.NN,'NA')
      ,@userName = J.FULLNAME
      ,@ErrText = cast(A.REPAIRREASON as nvarchar(200))
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
left join PR_OPERATIONS C with (nolock) on C.ID = A.OPERTYPEID
left join DEF_USERS J on J.ID = A.S_MR
where A.ID = @OperID

set @res = '<tr><td>'+@SN+'</td><td>'+@OrderN+'</td><td>'+@OperName+'</td><td><span style="color:red">'+ @ErrText+'</span></td><td>'+ @userName
set @res = @res + '<td><a href = "a2l:\\Link=doc.pr_device_operation.'+LTRIM(rtrim(str(@OperID)))+'">open</a></td>'
set @res = @res + '</tr>'

if LEN(@res) < 1
  return null

return @res

END