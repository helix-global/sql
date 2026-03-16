CREATE function [dbo].[PR_PRORDER_SNS](@aOrderID int)
returns nvarchar(max)
as
begin

  declare @res nvarchar(max)
  set @res = '';
  select @res = @res + A.SN + CHAR(13)+CHAR(10)
  from PR_DEVICE A with (nolock)
  where A.ORDERID = @aOrderID
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  return @res;
end;