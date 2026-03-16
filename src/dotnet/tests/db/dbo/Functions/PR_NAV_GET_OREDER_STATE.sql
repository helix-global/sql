create function [dbo].[PR_NAV_GET_OREDER_STATE](@orderId int)
returns int as 
begin
  
  declare @res int

  select @res = NAVSTATE
  from PR_NAV_SOSTATES with (nolock)
  where ORDERID=@orderId
    
  return @res

end