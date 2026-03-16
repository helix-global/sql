CREATE function [dbo].[MSG_DELIVERYTYPE_INDEP_RECIPIENTS](@aDeliveryType int,@aDepID int,@mode int)
returns nvarchar(max)
as
begin
/*
@mode=1 возвращает всех адресатов в одной строке
так надо для KB3715, но можно расширять режимы
*/

  declare @dlistID int
  declare @res nvarchar(max)
  
  select top 1 @dlistID = A.ID  
    from MSG_DELIVERYLIST A with (nolock)
   where A.DELIVERYTYPE = @aDeliveryType 
     and A.DEPID = @aDepID
   
  if @dlistID is null
    return null
    
  if @mode = 1
  begin
    
    select @res = dbo.MSG_DELIVERY_TO(@dlistID,9999)
    return @res    
  
  end
   
    
  return null;
end;