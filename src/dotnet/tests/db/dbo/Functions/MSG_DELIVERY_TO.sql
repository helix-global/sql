CREATE function [dbo].[MSG_DELIVERY_TO](@aDeliveryID int,@aMsgCopy int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin

  declare @res nvarchar(max)
  set @res = '';
  select @res = @res + B.EMAIL + '; '
  from dbo.MSG_DELIVERYLIST_T A with (nolock)
  left join dbo.COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
  where A.VNESHID = @aDeliveryID
    and B.EMAIL is not null
    and (isnull(A.EMPCOPY,0) = @aMsgCopy or @aMsgCopy = 9999)
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  return @res;
end;