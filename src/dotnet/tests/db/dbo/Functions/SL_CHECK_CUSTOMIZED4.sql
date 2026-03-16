create function [dbo].[SL_CHECK_CUSTOMIZED4](@aProductType int, @aCustomGroup int, @aCustomerID int)
returns int
as
begin

  if @aProductType <> 2 
    return 1

  if exists (select A.ID from COM_CUST_GROUP_T A with (nolock) where A.VNESHID = @aCustomGroup and A.CUSTID = @aCustomerID)
     return 1
  
  return 0
  
end;