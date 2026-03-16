CREATE FUNCTION [dbo].[MSG_PLANNEDDATECHANGE_TEXT](@DeviceID int,@dOld datetime,@dNew datetime)
RETURNS nvarchar(max)
AS
BEGIN
   
declare @res nvarchar(max)

declare @SN nvarchar(50)
declare @SOrderN nvarchar(50)
declare @ModelName nvarchar(200)
declare @CustomerName nvarchar(200)
declare @readiness decimal(10,1)

select @SN = A.SN
      ,@SOrderN = isnull(O.ND,'NA')
      ,@ModelName = C.NAME
      ,@CustomerName = F.NAME
      ,@readiness = dbo.PR_READINESS(A.ID,A.ORDERID)
from PR_DEVICE A with (nolock)
left join PR_SUPPLY O with (nolock) on O.ID = A.SORDERID
left join PR_MODELS C with (nolock) on C.ID = A.MODELID
left join PR_PRORDER D with (nolock) on D.ID = A.ORDERID
left join COM_CUSTOMER F with (nolock) on F.ID = isnull(O.CUSTOMERID,D.CUSTOMERID)
where A.ID = @DeviceID

/*<th>SN</th><th>Supply Order</th><th>Model</th><th>Customer</th><th>Previous Planed Date</th><th>New Planned Date</th>*/

set @res = '<tr><td>'+@SN+'</td><td>'+@SOrderN+'</td><td>'+@ModelName+'</td><td>'+@CustomerName+'</td>'
set @res = @res + '<td>'+ convert(nvarchar,@dOld,104)+'</td>'
set @res = @res + '<td><b>'+ convert(nvarchar,@dNew,104)+'</b></td>'
set @res = @res + '<td>'+ convert(nvarchar,@readiness)+'</td>'
set @res = @res + '</tr>'

return @res

END