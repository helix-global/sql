CREATE FUNCTION [dbo].[MSG_OPERATION_TIME_VIOLATION_TEXT](@OperID int,@EmplID int,@ManHour decimal(12,4),@Norm decimal(12,4),@Fact decimal(12,4))
RETURNS nvarchar(max)
AS
BEGIN
   
declare @res nvarchar(max)

declare @OperName nvarchar(400)
declare @SN nvarchar(50)
declare @OrderN nvarchar(50)
declare @ModelName nvarchar(400)

select @OperName = C.NAME 
      ,@SN = B.SN
      ,@OrderN = isnull(O.NN,'NA')
      ,@ModelName = M.NAME
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
left join PR_MODELS M with (nolock) on M.ID = B.MODELID
left join PR_OPERATIONS C with (nolock) on C.ID = A.OPERTYPEID
where A.ID = @OperID

set @res = '<tr><td>'+@ModelName+'</td><td>'+@SN+'</td><td>'+@OrderN+'</td><td>'+@OperName+'</td>'
set @res = @res + '<td>'+ dbo.COM_FORMAT_DHM(@ManHour,1)+'</td>'
set @res = @res + '<td>'+ dbo.COM_FORMAT_DHM(@Fact,1)+'</td>'
declare @EmplName nvarchar(400)
if @EmplID is not null
begin
    select @EmplName = A.NAME
    from COM_EMPLOYEE A with (nolock) 
    where A.ID = @EmplID
end
if @EmplName is null
  set @EmplName = ''
set @res = @res + '<td>'+@EmplName+'</td>'
set @res = @res + '<td><a href = "a2l:\\Link=doc.pr_device_operation.'+LTRIM(rtrim(str(@OperID)))+'">open</a></td>'
set @res = @res + '</tr>'


if LEN(@res) < 1
  return null

return @res

END